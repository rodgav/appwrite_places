import 'package:appwrite_places/app/constants.dart';
import 'package:appwrite_places/app/dependency_injection.dart';
import 'package:appwrite_places/domain/model/type_business.dart';
import 'package:appwrite_places/intl/generated/l10n.dart';
import 'package:appwrite_places/presentation/main/main_viewmodel.dart';
import 'package:appwrite_places/presentation/resources/color_manager.dart';
import 'package:appwrite_places/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final _viewModel = instance<MainViewModel>();

  @override
  void initState() {
      _viewModel.start();
    super.initState();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
        body: StreamBuilder<LatLng>(
            stream: _viewModel.outputLatLong,
            builder: (_, snapshot) {
              final latLng = snapshot.data;
              //print('latLng ${latLng?.latitude} ${latLng?.longitude}');
              return latLng != null
                  ? Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: MapboxMap(
                              onMapCreated: _viewModel.onMapCreated,
                              scrollGesturesEnabled: true,
                              zoomGesturesEnabled: true,
                              accessToken: Constant.mapboxAccessToken,
                              initialCameraPosition: CameraPosition(
                                  target: latLng, zoom: AppSize.s14)),
                        ),
                        _filter(s)
                      ],
                    )
                  : const SizedBox();
            }));
  }

  Widget _filter(S s) {
    return Positioned(
      top: AppSize.s40,
      left: AppSize.s40,
      child: StreamBuilder<TypeBusiness>(
          stream: _viewModel.outputTypeBusinessSel,
          builder: (_, snapshot) {
            final typeBusinessSel = snapshot.data;
            return SizedBox(
              width: AppSize.s140,
              child: StreamBuilder<List<TypeBusiness>>(
                  stream: _viewModel.outputTypeBusiness,
                  builder: (_, snapshot) {
                    final actives = snapshot.data;
                    return actives != null && actives.isNotEmpty
                        ? Container(
                            color: ColorManager.white,
                            child: DropdownButtonFormField<TypeBusiness>(
                                dropdownColor: ColorManager.white,
                                isExpanded: true,
                                decoration: InputDecoration(
                                    label: Text(s.typeBusiness)),
                                hint: Text(s.typeBusiness),
                                items: actives
                                    .map((e) => DropdownMenuItem(
                                          child: Text(e.name),
                                          value: e,
                                        ))
                                    .toList(),
                                value: typeBusinessSel,
                                onChanged: _viewModel.changeTypeBusinessSel),
                          )
                        : const SizedBox();
                  }),
            );
          }),
    );
  }
}
