import 'package:appwrite_places/app/dependency_injection.dart';
import 'package:appwrite_places/intl/generated/l10n.dart';
import 'package:appwrite_places/presentation/common/state_render/state_render_impl.dart';
import 'package:appwrite_places/presentation/request_permission/request_permission_viewmodel.dart';
import 'package:appwrite_places/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';

class RequestPermissionView extends StatefulWidget {
  const RequestPermissionView({Key? key}) : super(key: key);

  @override
  State<RequestPermissionView> createState() => _RequestPermissionViewState();
}

class _RequestPermissionViewState extends State<RequestPermissionView> {
  final _viewModel = instance<RequestPermissionViewModel>();

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _viewModel.requestPermission(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
        body: StreamBuilder<FlowState>(
            stream: _viewModel.outputState,
            builder: (context, snapshot) =>
            snapshot.data
                ?.getScreenWidget(context, _getContentWidget(s), () {
              _viewModel.inputState.add(ContentState());
            }, () {
              _viewModel.requestPermission(context);
            }) ??
                _getContentWidget(s)));
  }
  _getContentWidget (S s){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            s.requestPermission,
            style: Theme.of(context)
                .textTheme
                .headline1!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSize.s10),
          ElevatedButton(
              onPressed: () => _viewModel.requestPermission(context),
              child: Text(s.requestPermission))
        ],
      ),
    );
  }
}
