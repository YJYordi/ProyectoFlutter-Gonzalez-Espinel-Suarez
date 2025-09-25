import 'package:get/get.dart';
import 'package:proyecto/features/auth/domain/entities/user.dart';
import 'package:proyecto/features/auth/domain/usecases/login_usecase.dart';
import 'package:proyecto/features/auth/domain/usecases/register_usecase.dart';

class AuthController extends GetxController {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthController({required this.loginUseCase, required this.registerUseCase});

  var user = Rxn<UserEntity>();
  var isLoading = false.obs;

  bool get isLoggedIn => user.value != null;

  Future<void> login(String username, String password) async {
    try {
      isLoading.value = true;
      final result = await loginUseCase(username, password);
      if (result != null) {
        user.value = result;
      } else {
        Get.snackbar("Error", "Usuario o contraseña incorrectos");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({
    required String name,
    required String username,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      await registerUseCase(name: name, username: username, password: password);
      Get.snackbar("Éxito", "Usuario registrado correctamente");
    } catch (e) {
      Get.snackbar("Error en registro", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    user.value = null;
  }
}
