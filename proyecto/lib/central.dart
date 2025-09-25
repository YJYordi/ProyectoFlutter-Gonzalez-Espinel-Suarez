import 'package:get/get.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

class AuthController extends GetxController {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthController({required this.loginUseCase, required this.registerUseCase});

  // Variable observable
  final RxBool logged = false.obs;

  bool get isLogged => logged.value;

  void login(String email, String password) async {
    final result = await loginUseCase.call(email, password);
    if (result) logged.value = true;
  }

  void logout() {
    logged.value = false;
  }
}
