# Autenticación con API

Este módulo implementa la integración con la API de autenticación externa siguiendo los principios de Clean Architecture.

## URL Base
```
https://roble-api.openlab.uninorte.edu.co/auth/proyectoflutter_c35bbd8fbe
```

## Endpoints Disponibles

### 1. Login
- **Endpoint**: `POST /login`
- **Parámetros**: `username`, `password`
- **Respuesta**: Token de acceso, refresh token y datos del usuario

### 2. Registro Directo
- **Endpoint**: `POST /signup-direct`
- **Parámetros**: `name`, `username`, `password`
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
- **`AuthProvider`**: Estado de autenticación con métodos para API
- **Pantallas**: Login con botón para API

## Uso en la Aplicación

### Login con API
```dart
final authProvider = context.read<AuthProvider>();
final response = await authProvider.loginWithAPI(username, password);

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
final authProvider = context.read<AuthProvider>();
final response = await authProvider.registerWithAPI(
  name: 'Juan Pérez',
  username: 'juan123',
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
final authProvider = context.read<AuthProvider>();
final response = await authProvider.logoutWithAPI();

if (response.success) {
  // Sesión cerrada exitosamente
} else {
  // Error al cerrar sesión
  print('Error: ${response.error}');
}
```

### Validar Token
```dart
final authProvider = context.read<AuthProvider>();
final response = await authProvider.validateToken();

if (response.success && response.valid) {
  // Token válido
} else {
  // Token inválido o expirado
}
```

### Refresh Token
```dart
final authProvider = context.read<AuthProvider>();
final response = await authProvider.refreshToken();

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

## Configuración

### Dependencias Requeridas
```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

### Inicialización en main.dart
```dart
// Crear instancias
final dataSource = PersistentDataSource();
final remoteAuthDataSource = RemoteAuthDataSource();
final authRepo = AuthRepositoryImpl(dataSource, remoteAuthDataSource);

// Configurar providers
ChangeNotifierProvider<AuthProvider>(
  create: (_) => AuthProvider(
    // ... use cases locales
    loginWithAPIUseCase: LoginWithAPIUseCase(authRepo),
    registerWithAPIUseCase: RegisterWithAPIUseCase(authRepo),
    logoutWithAPIUseCase: LogoutWithAPIUseCase(authRepo),
    refreshTokenUseCase: RefreshTokenUseCase(authRepo),
    validateTokenUseCase: ValidateTokenUseCase(authRepo),
  ),
),
```

## Características

- ✅ **Clean Architecture**: Separación clara de responsabilidades
- ✅ **Manejo de Errores**: Respuestas estructuradas con información de error
- ✅ **Gestión de Tokens**: Almacenamiento seguro en SharedPreferences
- ✅ **Estado de Carga**: Indicadores de loading en la UI
- ✅ **Validación de Tokens**: Verificación automática de validez
- ✅ **Refresh Automático**: Renovación de tokens cuando sea necesario
- ✅ **Compatibilidad**: Funciona junto con el sistema de autenticación local existente
