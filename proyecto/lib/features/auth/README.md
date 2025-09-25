# Feature Auth - Sistema de Autenticación

Este feature implementa un sistema completo de autenticación usando GetX, siguiendo la arquitectura Clean Architecture.

## Estructura

```
auth/
├── domain/
│   ├── entities/
│   │   └── authentication_user.dart
│   ├── repositories/
│   │   └── i_auth_repository.dart
│   └── usecases/
│       └── authentication_usecase.dart
├── data/
│   ├── datasources/
│   │   ├── i_authentication_source.dart
│   │   └── authentication_source_service.dart
│   └── repositories/
│       └── auth_repository.dart
├── presentation/
│   ├── controllers/
│   │   └── auth_controller.dart
│   ├── pages/
│   │   └── auth_page.dart
│   └── routes/
│       └── auth_routes.dart
├── di/
│   └── auth_dependencies.dart
└── auth.dart (export principal)
```

## Características

- ✅ Login y Signup en la misma vista
- ✅ Validación de formularios
- ✅ Manejo de errores
- ✅ Estados de carga
- ✅ Recuperación de contraseña
- ✅ Verificación de token
- ✅ Logout
- ✅ Interfaz moderna y responsiva

## Configuración

### 1. Dependencias

Las siguientes dependencias ya están agregadas al `pubspec.yaml`:

```yaml
dependencies:
  get: ^4.6.6
  http: ^1.1.0
  loggy: ^1.0.0
  shared_preferences: ^2.2.2
```

### 2. Inicialización

En tu `main.dart`:

```dart
import 'package:get/get.dart';
import 'features/auth/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar dependencias
  AuthDependencies.init();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mi App',
      initialRoute: '/login',
      getPages: AuthRoutes.routes,
      // ... otras rutas
    );
  }
}
```

### 3. Uso del Controlador

```dart
// Obtener el controlador
final authController = Get.find<AuthController>();

// Verificar si está logueado
if (authController.isLogged) {
  // Usuario autenticado
}

// Login
await authController.login('email@example.com', 'password');

// Signup
await authController.signUp('email@example.com', 'password');

// Logout
await authController.logOut();

// Recuperar contraseña
await authController.forgotPassword('email@example.com');
```

## API Endpoints

El sistema está configurado para usar la API:

**Base URL:** `https://roble-api.openlab.uninorte.edu.co/auth/proyectoflutter_c35bbd8fbe`

### Endpoints disponibles:

- `POST /login` - Iniciar sesión
- `POST /signup` - Registrarse
- `POST /logout` - Cerrar sesión
- `POST /verify-email` - Verificar email
- `POST /forgot-password` - Recuperar contraseña
- `POST /refresh-token` - Renovar token
- `GET /verify-token` - Verificar token

## Navegación

### Rutas disponibles:

- `/login` - Página de login/signup
- `/signup` - Página de signup (misma vista que login)

### Navegación programática:

```dart
// Ir a login
Get.toNamed('/login');

// Ir a home después del login
Get.offAllNamed('/home');

// Cerrar sesión y volver a login
Get.offAllNamed('/login');
```

## Estados del Controlador

El `AuthController` expone los siguientes estados observables:

```dart
// Estado de autenticación
bool isLogged = authController.isLogged;

// Estado de carga
bool isLoading = authController.loading;

// Mensaje de error
String error = authController.error;
```

## Personalización

### Cambiar la URL base:

Edita el archivo `authentication_source_service.dart`:

```dart
final String baseUrl = 'tu-nueva-url-base';
```

### Personalizar la UI:

Modifica el archivo `auth_page.dart` para cambiar:
- Colores
- Iconos
- Textos
- Validaciones
- Estilos

## Middleware de Autenticación

Para proteger rutas, puedes usar el middleware de GetX:

```dart
GetMaterialApp(
  routingCallback: (routing) {
    final authController = Get.find<AuthController>();
    if (routing?.current != '/login' && !authController.isLogged) {
      Get.offAllNamed('/login');
    }
  },
)
```

## Ejemplo de Integración Completa

Ver el archivo `main_getx_example.dart` para un ejemplo completo de integración.
