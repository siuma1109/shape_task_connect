import 'package:get_it/get_it.dart';
import 'auth_service.dart';
import 'database_service.dart';
import '../repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  final prefs = await SharedPreferences.getInstance();

  // Register SharedPreferences first
  locator.registerSingleton<SharedPreferences>(prefs);

  // Register services in order of dependency
  locator.registerLazySingleton(() => DatabaseService());
  locator
      .registerLazySingleton(() => UserRepository(locator<DatabaseService>()));
  locator.registerLazySingleton(
    () => AuthService(locator<UserRepository>(), locator<SharedPreferences>()),
  );
}
