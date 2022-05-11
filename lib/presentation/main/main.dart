import 'package:appwrite_places/app/dependency_injection.dart';
import 'package:appwrite_places/presentation/main/main_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:appwrite_places/domain/model/latitude_longitude.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<LatLng>(
            stream: _viewModel.outputLatLong,
            builder: (_, snapshot) {
              final latLng = snapshot.data;
              return latLng != null
                  ? Center(
                      child: Text('${latLng.latitude}, ${latLng.longitude}'),
                    )
                  : const SizedBox();
            }));
  }
}
