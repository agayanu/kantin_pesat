import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  Future<void> clearStorage() async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      await preferences.clear();
    } catch (e) {
      if (kDebugMode) {
        print("[clear storage] Error Occurred $e");
      }
    }
  }

  Future<void> setString(String key, String value) async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      await preferences.setString(key, value);
    } catch (e) {
      if (kDebugMode) {
        print("[setString] Error Occurred $e");
      }
    }
  }

  Future<void> setInt(String key, int value) async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      await preferences.setInt(key, value);
    } catch (e) {
      if (kDebugMode) {
        print("[setInt] Error Occurred $e");
      }
    }
  }

  Future<void> setDouble(String key, bool value) async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      await preferences.setBool(key, value);
    } catch (e) {
      if (kDebugMode) {
        print("[setBool] Error Occurred $e");
      }
    }
  }

  Future<String?> getString(String key) async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final data = preferences.getString(key);

      return data;
    } catch (e) {
      if (kDebugMode) {
        print("[getString] Error Occurred $e");
      }
      return null;
    }
  }

  Future<int?> getInt(String key) async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final data = preferences.getInt(key);

      return data;
    } catch (e) {
      if (kDebugMode) {
        print("[getInt] Error Occurred $e");
      }
      return null;
    }
  }

  Future<double?> getDouble(String key) async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final data = preferences.getDouble(key);

      return data;
    } catch (e) {
      if (kDebugMode) {
        print("[getDouble] Error Occurred $e");
      }
      return null;
    }
  }

  Future<bool?> getBool(String key) async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final data = preferences.getBool(key);

      return data;
    } catch (e) {
      if (kDebugMode) {
        print("[getDouble] Error Occurred $e");
      }
      return null;
    }
  }
}
