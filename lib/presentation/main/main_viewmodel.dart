import 'dart:typed_data';

import 'package:appwrite_places/app/app_preferences.dart';
import 'package:appwrite_places/app/functions.dart';
import 'package:appwrite_places/data/data_source/local_data_source.dart';
import 'package:appwrite_places/data/services/locator.dart';
import 'package:appwrite_places/domain/model/place.dart';
import 'package:appwrite_places/domain/model/type_business.dart';
import 'package:appwrite_places/domain/usecase/main_usecase.dart';
import 'package:appwrite_places/presentation/base/base_viewmodel.dart';
import 'package:appwrite_places/presentation/common/state_render/state_render.dart';
import 'package:appwrite_places/presentation/common/state_render/state_render_impl.dart';
import 'package:appwrite_places/presentation/resources/assets_manager.dart';
import 'package:appwrite_places/presentation/resources/routes_manager.dart';
import 'package:appwrite_places/presentation/resources/strings_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:rxdart/rxdart.dart';

class MainViewModel extends BaseViewModel
    with MainViewModelInputs, MainViewModelOutputs {
  final MainUseCase _mainUseCase;
  final AppPreferences _appPreferences;
  final LocalDataSource _localDataSource;
  final LocatorInfo _locatorInfo;

  MainViewModel(this._mainUseCase, this._appPreferences, this._localDataSource,
      this._locatorInfo);

  final _positionStreCtrl = BehaviorSubject<LatLng>();
  final _placesStreCtrl = BehaviorSubject<List<Place>>();
  final _typeBusinessStreCtrl = BehaviorSubject<List<TypeBusiness>>();
  final _typeBusinessSelStreCtrl = BehaviorSubject<TypeBusiness>();
  LatLng? latLng;
  MapboxMapController? _mapController;

  //start and dispose override
  @override
  void start() {
    getPosition();
    super.start();
  }

  @override
  void dispose() async {
    await _positionStreCtrl.drain();
    _positionStreCtrl.close();
    await _placesStreCtrl.drain();
    _placesStreCtrl.close();
    await _typeBusinessStreCtrl.drain();
    _typeBusinessStreCtrl.close();
    await _typeBusinessSelStreCtrl.drain();
    _typeBusinessSelStreCtrl.close();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Sink get inputLatLong => _positionStreCtrl.sink;

  @override
  Sink get inputPlaces => _placesStreCtrl.sink;

  @override
  Sink get inputTypeBusiness => _typeBusinessStreCtrl.sink;

  @override
  Sink get inputTypeBusinessSel => _typeBusinessSelStreCtrl.sink;

  @override
  Stream<LatLng> get outputLatLong =>
      _positionStreCtrl.stream.map((latLong) => latLong);

  @override
  Stream<List<Place>> get outputPlaces =>
      _placesStreCtrl.stream.map((places) => places);

  @override
  Stream<List<TypeBusiness>> get outputTypeBusiness =>
      _typeBusinessStreCtrl.stream.map((typeBusiness) => typeBusiness);

  @override
  Stream<TypeBusiness> get outputTypeBusinessSel =>
      _typeBusinessSelStreCtrl.stream.map((typeBusiness) => typeBusiness);

  @override
  onMapCreated(MapboxMapController controller) async {
    _mapController = controller;
    _addImageFromAsset('pin', ImageAssets.pin);
    _mapController?.onSymbolTapped.add((symbol) {
      print('symbol ${symbol.options.textField} '
          '${symbol.options.geometry?.latitude} ${symbol.options.geometry?.longitude}');
    });
  }

  getPosition() async {
    final position = await _locatorInfo.currentPosition;
    //print('position $position');
    latLng = LatLng(position.latitude, position.longitude);
    inputLatLong.add(latLng);
    _typeBusiness();
  }

  @override
  deleteSession(BuildContext context) async {
    inputState.add(LoadingState(
        stateRendererType: StateRendererType.fullScreenLoadingState,
        message: AppStrings.empty));
    final sessionId = _appPreferences.getSessionId();
    (await _mainUseCase.execute(MainDeleteSessionUseCaseInput(sessionId))).fold(
        (f) {
      inputState
          .add(ErrorState(StateRendererType.fullScreenErrorState, f.message));
    }, (r) async {
      await _appPreferences.logout();
      _localDataSource.clearCache();
      GoRouter.of(context).go(Routes.splashRoute);
      inputState.add(ContentState());
    });
  }

  @override
  places(String typeBusiness) async {
    if (latLng != null) {
      //8 is kilometers
      final north =
          toNorthPosition(LatLng(latLng!.latitude, latLng!.longitude), 8);
      final east =
          toEastPosition(LatLng(latLng!.latitude, latLng!.longitude), 8);
      final south =
          toSouthPosition(LatLng(latLng!.latitude, latLng!.longitude), 8);
      final west =
          toWestPosition(LatLng(latLng!.latitude, latLng!.longitude), 8);
      (await _mainUseCase.places(
              MainUseCaseInputPlace(north, east, south, west, typeBusiness)))
          .fold((l) => null, (places) {
        inputPlaces.add(places);
        List<SymbolOptions> symbols = [];
        for (var element in places) {
          symbols.add(SymbolOptions(
              geometry: LatLng(element.latitude, element.longitude),
              iconImage: 'pin',
              textField: element.name,
              textOffset: const Offset(0, -2)));
        }
        Future.delayed(const Duration(seconds: 5), () {
          _mapController?.clearSymbols();
          _mapController?.clearLines();
          _mapController?.addSymbols(symbols);
          _mapController?.addLine(LineOptions(geometry: [
            LatLng(north.latitude, north.longitude),
            LatLng(east.latitude, east.longitude)
          ]));
          _mapController?.addLine(LineOptions(geometry: [
            LatLng(east.latitude, east.longitude),
            LatLng(south.latitude, south.longitude)
          ]));
          _mapController?.addLine(LineOptions(geometry: [
            LatLng(south.latitude, south.longitude),
            LatLng(west.latitude, west.longitude)
          ]));
          _mapController?.addLine(LineOptions(geometry: [
            LatLng(west.latitude, west.longitude),
            LatLng(north.latitude, north.longitude)
          ]));
        });
      });
    }
  }

  @override
  changeTypeBusinessSel(TypeBusiness? typeBusiness) {
    inputTypeBusinessSel.add(typeBusiness);
    places(typeBusiness?.name ?? '');
  }

  _typeBusiness() async {
    (await _mainUseCase.typeBusiness(null)).fold((l) => null, (r) {
      inputTypeBusiness.add(r);
      inputTypeBusinessSel.add(r.first);
      places(r.first.name);
    });
  }

  _addImageFromAsset(String name, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    _mapController!.addImage(name, list);
  }
}

abstract class MainViewModelInputs {
  Sink get inputLatLong;

  Sink get inputPlaces;

  Sink get inputTypeBusiness;

  Sink get inputTypeBusinessSel;

  onMapCreated(MapboxMapController controller);

  deleteSession(BuildContext context);

  places(String typeBusiness);

  changeTypeBusinessSel(TypeBusiness typeBusiness);
}

abstract class MainViewModelOutputs {
  Stream<LatLng> get outputLatLong;

  Stream<List<Place>> get outputPlaces;

  Stream<List<TypeBusiness>> get outputTypeBusiness;

  Stream<TypeBusiness> get outputTypeBusinessSel;
}
