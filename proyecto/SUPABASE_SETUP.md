# Configuración de Supabase para la Aplicación de Gestión de Cursos

## Pasos para configurar Supabase

### 1. Crear un proyecto en Supabase

1. Ve a [supabase.com](https://supabase.com)
2. Crea una cuenta o inicia sesión
3. Crea un nuevo proyecto
4. Anota la URL del proyecto y la clave anónima (anon key)

### 2. Configurar las tablas de la base de datos

1. Ve al SQL Editor en tu dashboard de Supabase
2. Copia y pega el contenido del archivo `supabase_schema.sql`
3. Ejecuta el script para crear todas las tablas y políticas

### 3. Configurar la autenticación

1. Ve a Authentication > Settings en tu dashboard
2. Configura las políticas de autenticación según tus necesidades
3. Opcionalmente, configura proveedores OAuth (Google, GitHub, etc.)

### 4. Actualizar la configuración en la aplicación

1. Abre el archivo `lib/config/supabase_config.dart`
2. Reemplaza los valores con los de tu proyecto:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://tu-proyecto.supabase.co';
  static const String supabaseAnonKey = 'tu-anon-key-aqui';
  // ... resto de la configuración
}
```

### 5. Estructura de las tablas

#### `profiles`
- Almacena información de los usuarios autenticados
- Se vincula con `auth.users` de Supabase
- Campos: id, name, username, email, role, created_at, updated_at

#### `courses`
- Almacena información de los cursos
- Campos: id, title, description, creator_username, creator_name, categories, max_enrollments, current_enrollments, created_at, schedule, location, price, is_random_assignment, group_size

#### `course_enrollments`
- Almacena las inscripciones de usuarios en cursos
- Campos: id, course_id, username, user_name, enrolled_at

#### `categories`
- Almacena las categorías de agrupación dentro de los cursos
- Campos: id, course_id, name, number_of_groups, is_random_assignment, created_at

#### `groups`
- Almacena los grupos dentro de las categorías
- Campos: id, category_id, group_number, members, max_members

#### `user_activities`
- Almacena el historial de actividades de los usuarios
- Campos: id, user_id, username, activity_type, payload, created_at

### 6. Características implementadas

#### Autenticación
- ✅ Registro de usuarios con Supabase Auth
- ✅ Inicio de sesión con Supabase Auth
- ✅ Cierre de sesión
- ✅ Sincronización de datos entre dispositivos

#### Sincronización de datos
- ✅ Los datos se almacenan localmente y se sincronizan con Supabase
- ✅ Al iniciar sesión, se descargan los datos del usuario
- ✅ Las actividades se registran automáticamente
- ✅ Fallback a almacenamiento local si Supabase no está disponible

#### Seguridad
- ✅ Row Level Security (RLS) habilitado
- ✅ Políticas de seguridad configuradas
- ✅ Los usuarios solo pueden acceder a sus propios datos

### 7. Uso en la aplicación

La aplicación ahora funciona de la siguiente manera:

1. **Primera vez**: El usuario se registra y los datos se guardan tanto localmente como en Supabase
2. **Inicio de sesión**: Se autentica con Supabase y se descargan sus datos
3. **Uso normal**: Los datos se sincronizan automáticamente con Supabase
4. **Cambio de dispositivo**: Al iniciar sesión en otro dispositivo, se descargan todos sus datos

### 8. Monitoreo y logs

- Las actividades de los usuarios se registran en la tabla `user_activities`
- Puedes consultar el historial de actividades desde el dashboard de Supabase
- Los logs incluyen: login, logout, register, course_creation, enrollment, etc.

### 9. Troubleshooting

#### Error de conexión a Supabase
- Verifica que la URL y la clave anónima sean correctas
- Asegúrate de que el proyecto esté activo en Supabase

#### Error de políticas de seguridad
- Verifica que las políticas RLS estén configuradas correctamente
- Asegúrate de que el usuario esté autenticado

#### Datos no se sincronizan
- Verifica la conexión a internet
- Revisa los logs en la consola para errores específicos
- La aplicación tiene fallback a almacenamiento local

### 10. Próximos pasos

- Configurar notificaciones push (opcional)
- Implementar backup automático de datos
- Agregar métricas y analytics
- Configurar webhooks para eventos importantes

