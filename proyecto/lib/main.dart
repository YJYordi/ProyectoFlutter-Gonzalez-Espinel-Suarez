import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/data/datasources/persistent_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'central.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dataSource = PersistentDataSource();
  await dataSource.initialize();

  final authRepo = AuthRepositoryImpl(dataSource);

  Get.put(
    AuthController(
      loginUseCase: LoginUseCase(authRepo),
      registerUseCase: RegisterUseCase(authRepo),
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Clases App',
      debugShowCheckedModeBanner: false,
      home: const Central(),
    );
  }
}
