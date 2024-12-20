import 'package:get_it/get_it.dart';
import '../repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/task_repository.dart';
import '../repositories/comment_repository.dart';
import 'location_service.dart';
import 'photo_service.dart';
import 'public_holiday_service.dart';
import 'auth_service.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  final prefs = await SharedPreferences.getInstance();

  // Register SharedPreferences first
  locator.registerSingleton<SharedPreferences>(prefs);

  // Register services in order of dependency
  locator.registerLazySingleton(() => UserRepository());
  locator.registerLazySingleton(() => TaskRepository());
  locator.registerLazySingleton(() => CommentRepository());

  // Register LocationService
  GetIt.instance.registerLazySingleton(() => LocationService());

  // Register PhotoService
  GetIt.instance.registerLazySingleton(() => PhotoService());

  // Register PublicHolidayService
  locator.registerLazySingleton(() => PublicHolidayService());

  // Register AuthService
  GetIt.instance.registerSingleton<AuthService>(
      AuthService(locator<UserRepository>(), locator<SharedPreferences>()));
}
