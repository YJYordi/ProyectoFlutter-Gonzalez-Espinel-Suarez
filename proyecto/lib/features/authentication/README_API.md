# Módulo de Autenticación

Este módulo implementa la integración completa con la API de autenticación externa de Roble, siguiendo los principios de Clean Architecture y utilizando GetX para el manejo de estado y navegación.

## URL Base
```
https://roble-api.openlab.uninorte.edu.co/auth/proyectoflutter_c35bbd8fbe
```

## Endpoints Disponibles

### 1. Login
- **Endpoint**: `POST /login`
- **Parámetros**: `email`, `password`
- **Respuesta**: Token de acceso, refresh token y datos del usuario

### 2. Registro Directo
- **Endpoint**: `POST /signup-direct`
- **Parámetros**: `name`, `email`, `password`
- **Respuesta**: Token de acceso, refresh token y datos del usuario

### 3. Logout
- **Endpoint**: `POST /logout`
- **Headers**: `Authorization: Bearer {token}`
- **Respuesta**: Confirmación de cierre de sesión

### 4. Refresh Token
- **Endpoint**: `POST /refresh-token`
- **Parámetros**: `refreshToken`
- **Respuesta**: Nuevo token de acceso y refresh token

### 5. Validar Token
- **Endpoint**: `GET /validate-token`
- **Headers**: `Authorization: Bearer {token}`
- **Respuesta**: Estado de validez del token

## Arquitectura

### Capas Implementadas

#### 1. Data Layer
- **`RemoteAuthDataSource`**: Maneja las peticiones HTTP a la API
- **`AuthRepositoryImpl`**: Implementa la lógica de negocio y gestión de tokens

#### 2. Domain Layer
- **`AuthResponse`**: Modelo de respuesta de la API
- **Use Cases**: 
  - `LoginWithAPIUseCase`
  - `RegisterWithAPIUseCase`
  - `LogoutWithAPIUseCase`
  - `RefreshTokenUseCase`
  - `ValidateTokenUseCase`

#### 3. Presentation Layer
- **`AuthController`**: Controlador GetX para manejo de estado de autenticación
- **Pantallas**: Login y Signup integrados con API de Roble
- **Navegación**: Sistema de navegación con GetX

## Uso en la Aplicación

### Login con API
```dart
final authController = Get.find<AuthController>();
final response = await authController.loginWithAPI(email, password);

if (response.success) {
  // Usuario autenticado exitosamente
  print('Token: ${response.token}');
  print('Usuario: ${response.user}');
} else {
  // Error en la autenticación
  print('Error: ${response.error}');
}
```

### Registro con API
```dart
final authController = Get.find<AuthController>();
final response = await authController.registerWithAPI(
  name: 'Juan Pérez',
  email: 'juan@ejemplo.com',
  password: 'password123',
);

if (response.success) {
  // Usuario registrado exitosamente
} else {
  // Error en el registro
  print('Error: ${response.error}');
}
```

### Logout con API
```dart
final authController = Get.find<AuthController>();
final response = await authController.logoutWithAPI();

if (response.success) {
  // Sesión cerrada exitosamente
} else {
  // Error al cerrar sesión
  print('Error: ${response.error}');
}
```

### Validar Token
```dart
final authController = Get.find<AuthController>();
final response = await authController.validateToken();

if (response.success && response.valid) {
  // Token válido
} else {
  // Token inválido o expirado
}
```

### Refresh Token
```dart
final authController = Get.find<AuthController>();
final response = await authController.refreshToken();

if (response.success) {
  // Token renovado exitosamente
} else {
  // Error al renovar token
}
```

## Gestión de Tokens

Los tokens se almacenan automáticamente en `SharedPreferences` cuando se realiza login o registro exitoso. Se pueden acceder mediante:

```dart
final authRepo = AuthRepositoryImpl(dataSource, remoteDataSource);
final accessToken = await authRepo.accessToken;
final refreshToken = await authRepo.refreshToken;
```

## Manejo de Errores

Todos los métodos de API retornan un objeto `AuthResponse` que incluye:
- `success`: Boolean indicando si la operación fue exitosa
- `error`: String con el mensaje de error (si aplica)
- `token`: Token de acceso (si aplica)
- `refreshToken`: Refresh token (si aplica)
- `user`: Datos del usuario (si aplica)

### Tipos de Errores Manejados

#### Errores de API
- **Email vacío**: Validación en frontend y backend
- **Credenciales inválidas**: Manejo de respuestas de error de Roble
- **Usuario ya existe**: Para el proceso de registro
- **Token expirado**: Renovación automática con refresh token

#### Errores de Red
- **Sin conexión**: Mensajes informativos al usuario
- **Timeout**: Reintentos automáticos
- **Servidor no disponible**: Fallback a modo offline

#### Errores de Datos
- **Respuestas nulas**: Manejo con `?.toString() ?? 'DefaultValue'`
- **Tipos incorrectos**: Validación de tipos en respuestas JSON
- **Datos faltantes**: Valores por defecto para campos opcionales

### Ejemplo de Manejo de Errores
```dart
try {
  final response = await authController.loginWithAPI(email, password);
  if (response.success) {
    // Éxito
    Get.snackbar('Éxito', 'Login exitoso');
  } else {
    // Error de API
    Get.snackbar('Error', response.error ?? 'Error desconocido');
  }
} catch (e) {
  // Error de red o excepción
  Get.snackbar('Error', 'Error de conexión: ${e.toString()}');
}
```

## Configuración

### Dependencias Requeridas
```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
  get: ^4.6.6
```

### Inicialización en main.dart
```dart
// Crear instancias
final dataSource = PersistentDataSource();
final remoteAuthDataSource = RemoteAuthDataSource();
final authRepo = AuthRepositoryImpl(dataSource, remoteAuthDataSource);

// Configurar controladores GetX
Get.put(AuthController(
  // ... use cases locales
  loginWithAPIUseCase: LoginWithAPIUseCase(authRepo),
  registerWithAPIUseCase: RegisterWithAPIUseCase(authRepo),
  logoutWithAPIUseCase: LogoutWithAPIUseCase(authRepo),
  refreshTokenUseCase: RefreshTokenUseCase(authRepo),
  validateTokenUseCase: ValidateTokenUseCase(authRepo),
));

// Configurar GetMaterialApp
GetMaterialApp(
  // ... configuración de rutas
)
```

## Características

- ✅ **Clean Architecture**: Separación clara de responsabilidades
- ✅ **GetX Integration**: Manejo de estado reactivo y navegación
- ✅ **API Roble**: Integración completa con la API externa
- ✅ **Manejo de Errores**: Respuestas estructuradas con información de error
- ✅ **Gestión de Tokens**: Almacenamiento seguro en SharedPreferences
- ✅ **Estado de Carga**: Indicadores de loading reactivos en la UI
- ✅ **Validación de Tokens**: Verificación automática de validez
- ✅ **Refresh Automático**: Renovación de tokens cuando sea necesario
- ✅ **Navegación GetX**: Sistema de navegación moderno y eficiente
- ✅ **UI Mejorada**: Pantallas de login y signup optimizadas
- ✅ **Información de Usuario**: Pantalla completa de perfil con datos de Roble
- ✅ **Null Safety**: Manejo robusto de valores nulos en respuestas de API

## Pantallas Implementadas

### Login Screen
- Campo de email/username
- Campo de contraseña
- Botón de "Iniciar Sesión" que usa la API de Roble
- Manejo de errores con GetX snackbars
- Navegación automática al home tras login exitoso

### Signup Screen
- Campo de nombre completo
- Campo de email
- Campo de contraseña
- Botón de "Crear Cuenta" que usa la API de Roble
- Validación de email con regex
- Navegación automática al home tras registro exitoso

### Profile Screen
- Información básica del usuario
- Botón para ver información personal detallada
- Opciones de configuración
- Botón de cerrar sesión

### User Info Screen
- Pantalla completa con información detallada del usuario
- Datos sincronizados con Roble
- Diseño moderno con gradientes y cards
- Botón de actualizar información

## Estado Actual del Proyecto

### ✅ Completado
- **Migración a GetX**: Todo el proyecto usa GetX para estado y navegación
- **Integración API Roble**: Login y signup funcionando con la API externa
- **Limpieza de Provider**: Eliminados todos los archivos y referencias de Provider
- **Pantallas de Perfil**: Implementación completa de información de usuario
- **Manejo de Errores**: Sistema robusto de manejo de errores de API
- **Null Safety**: Manejo seguro de valores nulos en respuestas

### 🔄 En Desarrollo
- **Validación de Tokens**: Implementación automática de refresh tokens
- **Modo Offline**: Fallback cuando no hay conexión a internet
- **Mejoras de UI**: Optimizaciones adicionales en las pantallas

### 📋 Próximas Características
- **Biometría**: Login con huella dactilar/Face ID
- **Notificaciones Push**: Integración con Firebase
- **Temas**: Modo oscuro y personalización de colores
- **Internacionalización**: Soporte para múltiples idiomas

## Notas de Desarrollo

### Cambios Importantes
1. **Provider → GetX**: Migración completa del sistema de estado
2. **API Integration**: Cambio de autenticación local a API externa
3. **Email vs Username**: Los endpoints ahora usan email en lugar de username
4. **Null Safety**: Implementación de manejo seguro de valores nulos

### Estructura de Archivos
```
lib/features/authentication/
├── data/
│   ├── datasources/
│   │   └── remote_auth_data_source.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── auth_response.dart
│   │   └── user.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       ├── login_with_api_usecase.dart
│       ├── register_with_api_usecase.dart
│       ├── logout_with_api_usecase.dart
│       ├── refresh_token_usecase.dart
│       └── validate_token_usecase.dart
└── presentation/
    ├── controllers/
    │   └── auth_controller.dart
    └── screens/
        ├── log_in.dart
        └── sign_up.dart
```
