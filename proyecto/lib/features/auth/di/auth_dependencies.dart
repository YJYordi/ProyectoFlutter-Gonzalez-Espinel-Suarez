import 'package:get/get.dart';

import '../../../core/data/datasources/local_preferences_service.dart';
import '../data/datasources/authentication_source_service.dart';
import '../data/repositories/auth_repository.dart';
import '../domain/usecases/authentication_usecase.dart';
import '../presentation/controllers/auth_controller.dart';

class AuthDependencies {
  static void init() {
    // Local Preferences
    Get.lazyPut<LocalPreferencesService>(() => LocalPreferencesService());

    // Data Sources
    Get.lazyPut<AuthenticationSourceService>(() => AuthenticationSourceService());

    // Repositories
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find<AuthenticationSourceService>()));

    // Use Cases
    Get.lazyPut<AuthenticationUseCase>(() => AuthenticationUseCase(Get.find<AuthRepository>()));

    // Controllers
    Get.lazyPut<AuthController>(() => AuthController(Get.find<AuthenticationUseCase>()));
  }
}
