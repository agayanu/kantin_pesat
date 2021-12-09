import 'dart:async';

import 'package:kantin_pesat/locator.dart';
import 'package:kantin_pesat/services/navigation_service.dart';
import 'package:kantin_pesat/services/storage_service.dart';
import 'package:kantin_pesat/ui/route_name.dart';
import 'package:kantin_pesat/viewmodels/base_model.dart';

class StartUpViewModel extends BaseModel {
  final StorageService _storageService = locator<StorageService>();
  final NavigationService _navigationService = locator<NavigationService>();

  Future handleStartUpLogic() async {
    // final data = await _storageService.getString('guid');
    final role = await _storageService.getString('role');

    _navigationService.replaceTo(loginViewRoute);

    if (role == null) {
      _navigationService.replaceTo(loginViewRoute);
    } else {
      if (role == '0') {
        // _navigationService.replaceTo(dashboardPembeliViewRoute);
      } else if (role == '1') {
        // _navigationService.replaceTo(dashboardPenjualViewRoute);
      } else if (role == '3') {
        // _navigationService.replaceTo(dashboardAdminViewRoute);
      } else {
        _navigationService.replaceTo(loginViewRoute);
      }
    }
  }

  startUpTimer() async {
    var _duration = const Duration(seconds: 2);
    return Timer(_duration, handleStartUpLogic);
  }
}
