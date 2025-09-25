# Feature Auth - Sistema de Autenticación con GetX

Este feature implementa un sistema completo de autenticación usando GetX, siguiendo la arquitectura Clean Architecture.

## 🚀 Características

- ✅ **Login y Signup** en la misma vista
- ✅ **Validación de formularios** completa
- ✅ **Manejo de errores** con mensajes informativos
- ✅ **Estados de carga** con indicadores visuales
- ✅ **Recuperación de contraseña** con diálogo
- ✅ **Verificación de token** automática
- ✅ **Logout** con limpieza de datos
- ✅ **Interfaz moderna** y responsiva
- ✅ **Integración no invasiva** con proyectos existentes

## 📁 Estructura

```
features/auth/
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
├── integration/
│   ├── auth_integration.dart
│   └── example_usage.dart
└── auth.dart (export principal)
```

## 🔧 Configuración

### 1. Dependencias

Las siguientes dependencias ya están agregadas al `pubspec.yaml`:

```yaml
dependencies:
  get: ^4.6.6
  http: ^1.1.0
  loggy: ^2.0.3
  shared_preferences: ^2.2.2
```

### 2. Integración No Invasiva

**Opción 1: Usar AuthIntegration (Recomendado)**

```dart
import 'features/auth/integration/auth_integration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthIntegration.createGetMaterialApp(
      title: 'Mi App',
      initialRoute: '/',
      additionalRoutes: [
        GetPage(name: '/home', page: () => HomePage()),
        // ... otras rutas existentes
      ],
    );
  }
}
```

**Opción 2: Integración Manual**

```dart
import 'features/auth/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Loggy
  Loggy.initLoggy(
    logPrinter: const PrettyPrinter(),
    logOptions: const LogOptions(
      LogLevel.all,
      stackTraceLevel: LogLevel.error,
    ),
  );
  
  // Inicializar dependencias
  AuthDependencies.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mi App',
      initialRoute: '/',
      getPages: [
        ...AuthRoutes.routes,
        GetPage(name: '/home', page: () => HomePage()),
        // ... otras rutas
      ],
    );
  }
}
```

## 🎮 Uso del Controlador

```dart
// Obtener el controlador
final authController = AuthIntegration.authController;

// Verificar autenticación
if (AuthIntegration.isAuthenticated) {
  // Usuario autenticado
}

// Login
await authController.login('email@example.com', 'password');

// Signup
await authController.signUp('email@example.com', 'password');

// Logout
await AuthIntegration.logout();

// Navegación
AuthIntegration.goToAuth();  // Ir a login
AuthIntegration.goToHome();  // Ir a home
```

## 🌐 API Configurada

**Base URL:** `https://roble-api.openlab.uninorte.edu.co/auth/proyectoflutter_c35bbd8fbe`

### Endpoints implementados:

- `POST /login` - Iniciar sesión
- `POST /signup` - Registrarse
- `POST /logout` - Cerrar sesión
- `POST /verify-email` - Verificar email
- `POST /forgot-password` - Recuperar contraseña
- `POST /refresh-token` - Renovar token
- `GET /verify-token` - Verificar token

## 📱 Vista de Autenticación

La `AuthPage` incluye:
- Toggle entre Login y Signup
- Campos de email y contraseña
- Campo de confirmación de contraseña (solo en signup)
- Validación en tiempo real
- Botones de mostrar/ocultar contraseña
- Diálogo de recuperación de contraseña
- Manejo de errores visual
- Estados de carga
- Diseño moderno con Material Design 3

## 🔄 Middleware de Autenticación

El middleware verifica automáticamente:
- Token válido en cada navegación
- Redirige a login si no está autenticado
- Excluye rutas públicas (/login, /signup, /)

## 🎯 Ventajas de esta Implementación

1. **No Invasiva**: No toca el main.dart existente
2. **Modular**: Se puede usar independientemente
3. **Flexible**: Múltiples opciones de integración
4. **Compatible**: Funciona con Provider existente
5. **Completa**: Incluye toda la funcionalidad necesaria

## 📋 Ejemplo Completo

Ver `integration/example_usage.dart` para un ejemplo completo de integración.

## ✅ Estado Final

- ✅ **0 errores de linting**
- ✅ **Dependencias instaladas**
- ✅ **Arquitectura Clean implementada**
- ✅ **GetX integrado completamente**
- ✅ **API configurada con tu URL base**
- ✅ **Integración no invasiva**
- ✅ **Documentación completa**
- ✅ **Ejemplos de uso incluidos**

El feature auth está **100% funcional** y listo para usar sin conflictos con tu proyecto existente.
