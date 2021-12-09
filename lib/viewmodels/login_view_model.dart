import 'package:flutter/material.dart';
import 'package:kantin_pesat/locator.dart';
import 'package:kantin_pesat/services/alert_service.dart';
import 'package:kantin_pesat/services/api_service.dart';
import 'package:kantin_pesat/services/navigation_service.dart';
import 'package:kantin_pesat/services/storage_service.dart';
import 'package:kantin_pesat/ui/route_name.dart';
import 'package:kantin_pesat/viewmodels/base_model.dart';

class LoginViewModel extends BaseModel {
  final NavigationService _navigationService = locator<NavigationService>();
  final ApiService _apiService = locator<ApiService>();
  final StorageService _storageService = locator<StorageService>();
  final AlertService _alertService = locator<AlertService>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // void navigateToSignUpView() {
  //   _navigationService.navigateTo(SignUpViewRoute);
  // }

  void logginAccount(BuildContext context) async {
    setBusy(true);
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      final data = await _apiService.newLogin(
          emailController.text.trim(), passwordController.text.trim());

      if (data != null) {
        if (data.data.role == '0') {
          await _storageService.setString('id', data.data.id.toString());
          await _storageService.setString('name', data.data.name);
          await _storageService.setString('email', data.data.email);
          await _storageService.setString('role', data.data.role);
          await _storageService.setString('gambar', data.data.gambar);
          await _storageService.setString('token', data.accessToken);

          _navigationService.replaceTo(dashboardViewRoute);
        } else if (data.data.role == '2') {
          await _storageService.setString('id', data.data.id.toString());
          await _storageService.setString('name', data.data.name);
          await _storageService.setString('email', data.data.email);
          await _storageService.setString('role', data.data.role);
          await _storageService.setString('gambar', data.data.gambar);
          await _storageService.setString('token', data.accessToken);

          _navigationService.replaceTo(adminViewRoute);
        } else {
          _alertService.showAlert(
              context, 'Error', 'Akun tidak terdaftar', _navigationService.pop);
        }
      } else {
        _alertService.showAlert(context, 'Error',
            'Incorrect username or password', _navigationService.pop);
      }
    } else {
      _alertService.showAlert(
          context, 'Warning', 'fill all field', _navigationService.pop);
    }
    setBusy(false);
  }
}
