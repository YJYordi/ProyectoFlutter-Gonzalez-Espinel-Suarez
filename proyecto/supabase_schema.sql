-- Esquema de base de datos para la aplicación de gestión de cursos
-- Ejecutar estos comandos en el SQL Editor de Supabase

-- Tabla de perfiles de usuario
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  name TEXT NOT NULL,
  username TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  role TEXT NOT NULL DEFAULT 'student' CHECK (role IN ('student', 'teacher')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de cursos
CREATE TABLE IF NOT EXISTS courses (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  creator_username TEXT NOT NULL,
  creator_name TEXT NOT NULL,
  categories TEXT[] NOT NULL DEFAULT '{}',
  max_enrollments INTEGER NOT NULL DEFAULT 0,
  current_enrollments INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  schedule TEXT,
  location TEXT,
  price DECIMAL(10,2) DEFAULT 0.0,
  is_random_assignment BOOLEAN NOT NULL DEFAULT FALSE,
  group_size INTEGER
);

-- Tabla de inscripciones en cursos
CREATE TABLE IF NOT EXISTS course_enrollments (
  id TEXT PRIMARY KEY,
  course_id TEXT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  username TEXT NOT NULL,
  user_name TEXT NOT NULL,
  enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de categorías
CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY,
  course_id TEXT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  number_of_groups INTEGER NOT NULL DEFAULT 1,
  is_random_assignment BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de grupos
CREATE TABLE IF NOT EXISTS groups (
  id TEXT PRIMARY KEY,
  category_id TEXT NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  group_number INTEGER NOT NULL,
  members TEXT[] NOT NULL DEFAULT '{}',
  max_members INTEGER NOT NULL DEFAULT 0
);

-- Tabla de actividades de usuario
CREATE TABLE IF NOT EXISTS user_activities (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  username TEXT,
  activity_type TEXT NOT NULL,
  payload JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_courses_creator ON courses(creator_username);
CREATE INDEX IF NOT EXISTS idx_enrollments_course ON course_enrollments(course_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_user ON course_enrollments(username);
CREATE INDEX IF NOT EXISTS idx_categories_course ON categories(course_id);
CREATE INDEX IF NOT EXISTS idx_groups_category ON groups(category_id);
CREATE INDEX IF NOT EXISTS idx_activities_user ON user_activities(user_id);
CREATE INDEX IF NOT EXISTS idx_activities_username ON user_activities(username);

-- Políticas de seguridad (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_activities ENABLE ROW LEVEL SECURITY;

-- Política para perfiles: los usuarios pueden ver y editar su propio perfil
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Política para cursos: todos pueden ver los cursos
CREATE POLICY "Anyone can view courses" ON courses
  FOR SELECT USING (true);

-- Política para cursos: solo los creadores pueden insertar/actualizar/eliminar sus cursos
CREATE POLICY "Creators can manage their courses" ON courses
  FOR ALL USING (auth.uid()::text = creator_username);

-- Política para inscripciones: los usuarios pueden ver sus propias inscripciones
CREATE POLICY "Users can view own enrollments" ON course_enrollments
  FOR SELECT USING (auth.uid()::text = username);

-- Política para inscripciones: los usuarios pueden inscribirse en cursos
CREATE POLICY "Users can enroll in courses" ON course_enrollments
  FOR INSERT WITH CHECK (auth.uid()::text = username);

-- Política para inscripciones: los usuarios pueden desinscribirse
CREATE POLICY "Users can unenroll from courses" ON course_enrollments
  FOR DELETE USING (auth.uid()::text = username);

-- Política para categorías: todos pueden ver las categorías
CREATE POLICY "Anyone can view categories" ON categories
  FOR SELECT USING (true);

-- Política para grupos: todos pueden ver los grupos
CREATE POLICY "Anyone can view groups" ON groups
  FOR SELECT USING (true);

-- Política para actividades: los usuarios pueden ver sus propias actividades
CREATE POLICY "Users can view own activities" ON user_activities
  FOR SELECT USING (auth.uid() = user_id OR auth.uid()::text = username);

-- Política para actividades: los usuarios pueden insertar sus propias actividades
CREATE POLICY "Users can insert own activities" ON user_activities
  FOR INSERT WITH CHECK (auth.uid() = user_id OR auth.uid()::text = username);

-- Función para actualizar el campo updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para actualizar updated_at en profiles
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

