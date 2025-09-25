import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/usecases/authentication_usecase.dart';

class AuthController extends GetxController {
  final AuthenticationUseCase authentication;
  final logged = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  AuthController(this.authentication);

  @override
  Future<void> onInit() async {
    super.onInit();
    logInfo('AuthenticationController initialized');
    // Verificar si ya hay un token válido al inicializar
    await checkAuthStatus();
  }

  bool get isLogged => logged.value;
  bool get loading => isLoading.value;
  String get error => errorMessage.value;

  Future<void> checkAuthStatus() async {
    try {
      isLoading.value = true;
      final isValid = await authentication.validateToken();
      logged.value = isValid;
    } catch (e) {
      logError('Error checking auth status: $e');
      logged.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      logInfo('AuthenticationController: Login $email');
      
      final result = await authentication.login(email, password);
      logged.value = result;
      
      if (result) {
        Get.snackbar('Éxito', 'Inicio de sesión exitoso');
        Get.offAllNamed('/home');
      }
      
      return result;
    } catch (e) {
      logError('Login error: $e');
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Error al iniciar sesión: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      logInfo('AuthenticationController: Sign Up $email');
      
      final result = await authentication.signUp(email, password);
      
      if (result) {
        Get.snackbar('Éxito', 'Registro exitoso. Por favor verifica tu email.');
        Get.offAllNamed('/');
      }
      
      return result;
    } catch (e) {
      logError('SignUp error: $e');
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Error al registrarse: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logOut() async {
    try {
      isLoading.value = true;
      logInfo('AuthenticationController: Log Out');
      
      await authentication.logOut();
      logged.value = false;
      
      Get.snackbar('Éxito', 'Sesión cerrada exitosamente');
      Get.offAllNamed('/');
    } catch (e) {
      logError('Logout error: $e');
      Get.snackbar('Error', 'Error al cerrar sesión: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await authentication.forgotPassword(email);
      Get.snackbar('Éxito', 'Se ha enviado un email para restablecer la contraseña');
    } catch (e) {
      logError('Forgot password error: $e');
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Error al enviar email: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    errorMessage.value = '';
  }
}
