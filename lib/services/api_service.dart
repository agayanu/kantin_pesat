import 'package:flutter/foundation.dart';
import 'package:kantin_pesat/models/login_model_data.dart';
import 'package:http/http.dart' as http;
import 'package:kantin_pesat/services/cons_service.dart';

class ApiService {
  Future<LoginData?> newLogin(String email, String password) async {
    final client = http.Client();
    try {
      const loginUrl = '$baseURL/login';
      if (kDebugMode) {
        print('[Login URL] $loginUrl');
      }
      final response = await client.post(Uri.parse(loginUrl),
          body: {'email': email, 'password': password});
      if (kDebugMode) {
        print(response.body);
      }
      final userData = loginDataFromJson(response.body);

      if (userData.status != true || response.statusCode != 200) {
        return null;
      }
      return userData;
    } catch (e) {
      if (kDebugMode) {
        print('[Login] error occurred $e');
      }
      return null;
    }
  }

  // Future<PelaporanData?> pelaporanIndex(String token) async {
  //   final client = http.Client();
  //   try {
  //     final pelaporanUrl = '$BASE_URL/me';
  //     print('[Login URL] $pelaporanUrl');
  //     final response = await client.get(Uri.parse(pelaporanUrl), headers: {
  //       'Authorization': 'Bearer $token',
  //     });
  //     print(response.body);
  //     final userData = pelaporanDataFromJson(response.body);

  //     // if (userData.status != true || response.statusCode != 200) {
  //     //   return null;
  //     // }
  //     return userData;
  //   } catch (e) {
  //     print('[Login] error occurred $e');
  //     return null;
  //   }
  // }

  // Future<DatasData?> datasIndex(String token, int page) async {
  //   final client = http.Client();
  //   try {
  //     final datasUrl = '$BASE_URL/data?page=$page';
  //     print('[Login URL] $datasUrl');
  //     final response = await client.get(Uri.parse(datasUrl), headers: {
  //       'Authorization': 'Bearer $token',
  //     });
  //     print(response.body);
  //     final userData = datasDataFromJson(response.body);

  //     // if (userData.status != true || response.statusCode != 200) {
  //     //   return null;
  //     // }
  //     return userData;
  //   } catch (e) {
  //     print('[Login] error occurred $e');
  //     return null;
  //   }
  // }
}
