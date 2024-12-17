import 'package:get_it/get_it.dart';
import 'auth_service.dart';
import 'database_service.dart';
import '../repositories/user_repository.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => DatabaseService());
  locator.registerLazySingleton(() => UserRepository(locator()));
  locator.registerLazySingleton(() => AuthService(locator()));
}
