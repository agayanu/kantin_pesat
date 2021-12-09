import 'package:get_it/get_it.dart';
import 'package:kantin_pesat/services/alert_service.dart';
import 'package:kantin_pesat/services/api_service.dart';
import 'package:kantin_pesat/services/navigation_service.dart';
import 'package:kantin_pesat/services/storage_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => ApiService());
  // locator.registerLazySingleton(() => GeolocatorService());
  // locator.registerLazySingleton(() => LocationService());
  locator.registerLazySingleton(() => AlertService());
  locator.registerLazySingleton(() => StorageService());
}
