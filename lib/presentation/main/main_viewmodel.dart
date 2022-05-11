import 'package:appwrite_places/app/app_preferences.dart';
import 'package:appwrite_places/app/functions.dart';
import 'package:appwrite_places/data/data_source/local_data_source.dart';
import 'package:appwrite_places/data/services/locator.dart';
import 'package:appwrite_places/domain/model/place.dart';
import 'package:appwrite_places/domain/usecase/main_usecase.dart';
import 'package:appwrite_places/presentation/base/base_viewmodel.dart';
import 'package:appwrite_places/presentation/common/state_render/state_render.dart';
import 'package:appwrite_places/presentation/common/state_render/state_render_impl.dart';
import 'package:appwrite_places/presentation/resources/routes_manager.dart';
import 'package:appwrite_places/presentation/resources/strings_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:appwrite_places/domain/model/latitude_longitude.dart';
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
    super.dispose();
  }

  @override
  Sink get inputLatLong => _positionStreCtrl.sink;

  @override
  Sink get inputPlaces => _placesStreCtrl.sink;

  @override
  Stream<LatLng> get outputLatLong =>
      _positionStreCtrl.stream.map((latLong) => latLong);

  @override
  Stream<List<Place>> get outputPlaces =>
      _placesStreCtrl.stream.map((places) => places);

  getPosition() async {
    final position = await _locatorInfo.currentPosition;
    //print('position $position');
    final latLng = LatLng(position.latitude, position.longitude);
    inputLatLong.add(latLng);
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
  places(LatLng latLng, String typeBusinnes) async {
    //10 is kilometers
    final north =
        toNorthPosition(LatLng(latLng.latitude, latLng.longitude), 10);
    final east = toEastPosition(LatLng(latLng.latitude, latLng.longitude), 10);
    final south =
        toSouthPosition(LatLng(latLng.latitude, latLng.longitude), 10);
    final west = toWestPosition(LatLng(latLng.latitude, latLng.longitude), 10);
    (await _mainUseCase.places(
            MainUseCaseInputPlace(north, east, south, west, typeBusinnes)))
        .fold((l) => null,
            (places) => inputPlaces.add(places));
  }
}

abstract class MainViewModelInputs {
  Sink get inputLatLong;

  Sink get inputPlaces;

  deleteSession(BuildContext context);

  places(LatLng latLng, String typeBusinnes);
}

abstract class MainViewModelOutputs {
  Stream<LatLng> get outputLatLong;

  Stream<List<Place>> get outputPlaces;
}
