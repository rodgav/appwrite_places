import 'package:appwrite_places/data/services/permissions.dart';
import 'package:appwrite_places/presentation/base/base_viewmodel.dart';
import 'package:appwrite_places/presentation/common/state_render/state_render.dart';
import 'package:appwrite_places/presentation/common/state_render/state_render_impl.dart';
import 'package:appwrite_places/presentation/resources/routes_manager.dart';
import 'package:appwrite_places/presentation/resources/strings_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class RequestPermissionViewModel extends BaseViewModel
    with RequestPermissionViewModelInputs, RequestPermissionViewModelOutputs {
  final Permissions _permissions;

  RequestPermissionViewModel(this._permissions);

  @override
  requestPermission(BuildContext context) async {
    inputState.add(LoadingState(
        stateRendererType: StateRendererType.fullScreenLoadingState,
        message: AppStrings.empty));
    final statusPermission = await _permissions.locationPermission();
    if (statusPermission) {
      GoRouter.of(context).go(Routes.mainRoute);
    } else {
      inputState.add(ContentState());
    }
  }
}

abstract class RequestPermissionViewModelInputs {
  requestPermission(BuildContext context);
}

abstract class RequestPermissionViewModelOutputs {}
