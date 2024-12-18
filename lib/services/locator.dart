import 'package:get_it/get_it.dart';
import 'auth_service.dart';
import 'database_service.dart';
import '../repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/task_repository.dart';
import '../repositories/comment_repository.dart';
import 'location_service.dart';
<<<<<<< HEAD
import 'photo_service.dart';
=======
>>>>>>> 3e1315a607208a29c8f9fb13fe65837df8dc7e86

final locator = GetIt.instance;

Future<void> setupLocator() async {
  final prefs = await SharedPreferences.getInstance();

  // Register SharedPreferences first
  locator.registerSingleton<SharedPreferences>(prefs);

  // Register services in order of dependency
  locator.registerLazySingleton(() => DatabaseService());
  locator
      .registerLazySingleton(() => UserRepository(locator<DatabaseService>()));
  locator
      .registerLazySingleton(() => TaskRepository(locator<DatabaseService>()));
  locator.registerLazySingleton(
    () => AuthService(locator<UserRepository>(), locator<SharedPreferences>()),
  );
  locator.registerLazySingleton(
      () => CommentRepository(locator<DatabaseService>()));

  // Register LocationService
  GetIt.instance.registerLazySingleton(() => LocationService());
<<<<<<< HEAD

  // Register PhotoService
  GetIt.instance.registerLazySingleton(() => PhotoService());
=======
>>>>>>> 3e1315a607208a29c8f9fb13fe65837df8dc7e86
}
