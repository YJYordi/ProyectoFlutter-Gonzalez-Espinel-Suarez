import 'package:flutter/material.dart';

class CourseCreationScreen extends StatefulWidget {
  const CourseCreationScreen({super.key});

  @override
  State<CourseCreationScreen> createState() => _CourseCreationScreenState();
}

class _CourseCreationScreenState extends State<CourseCreationScreen> {
  int _selectedIndex = 0;
  final _formKey = GlobalKey<FormState>();
  final _courseTitleController = TextEditingController();
  final _groupSizeController = TextEditingController(text: '5');
  final _groupPrefixController = TextEditingController();
  
  String _groupingMethod = 'random';
  bool _showAdvancedOptions = false;
  bool _setStartDate = false;
  bool _setEndDate = false;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Curso'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título del curso
              TextFormField(
                controller: _courseTitleController,
                decoration: const InputDecoration(
                  labelText: 'Título del Curso',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título para el curso';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Tamaño del grupo
              TextFormField(
                controller: _groupSizeController,
                decoration: const InputDecoration(
                  labelText: 'Tamaño del Grupo',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el tamaño del grupo';
                  }
                  final n = int.tryParse(value);
                  if (n == null || n < 2) {
                    return 'El tamaño debe ser un número mayor a 1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Método de agrupamiento
              const Text(
                'Método de Agrupamiento',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Radio<String>(
                    value: 'random',
                    groupValue: _groupingMethod,
                    onChanged: (value) {
                      setState(() {
                        _groupingMethod = value!;
                      });
                    },
                  ),
                  const Text('Creación Aleatoria de Grupos'),
                ],
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'self',
                    groupValue: _groupingMethod,
                    onChanged: (value) {
                      setState(() {
                        _groupingMethod = value!;
                      });
                    },
                  ),
                  const Text('Autoinscripción'),
                ],
              ),
              const SizedBox(height: 20),
              
              // Opciones avanzadas
              Row(
                children: [
                  Checkbox(
                    value: _showAdvancedOptions,
                    onChanged: (value) {
                      setState(() {
                        _showAdvancedOptions = value!;
                      });
                    },
                  ),
                  const Text('Mostrar opciones avanzadas'),
                ],
              ),
              
              if (_showAdvancedOptions) ...[
                _buildAdvancedOptions(),
                const SizedBox(height: 20),
              ],
              
              // Prefijo del grupo
              TextFormField(
                controller: _groupPrefixController,
                decoration: const InputDecoration(
                  labelText: 'Prefijo del Grupo (Opcional)',
                  border: OutlineInputBorder(),
                  hintText: 'Ej: Grupo',
                ),
              ),
              const SizedBox(height: 30),
              
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _createCourse,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Crear Curso'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Navegación a otras pantallas (por implementar)
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Contactos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Pendientes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildAdvancedOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Opciones Avanzadas',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        
        // Fecha de inicio
        Row(
          children: [
            Checkbox(
              value: _setStartDate,
              onChanged: (value) {
                setState(() {
                  _setStartDate = value!;
                });
              },
            ),
            const Text('Establecer fecha de inicio de la autoinscripción'),
          ],
        ),
        if (_setStartDate) ...[
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() {
                        _startDate = date;
                      });
                    }
                  },
                  child: Text(
                    _startDate != null
                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                        : 'Seleccionar fecha',
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _startTime = time;
                      });
                    }
                  },
                  child: Text(
                    _startTime != null
                        ? _startTime!.format(context)
                        : 'Seleccionar hora',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        
        // Fecha de vencimiento
        Row(
          children: [
            Checkbox(
              value: _setEndDate,
              onChanged: (value) {
                setState(() {
                  _setEndDate = value!;
                });
              },
            ),
            const Text('Establecer fecha de vencimiento de la autoinscripción'),
          ],
        ),
        if (_setEndDate) ...[
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() {
                        _endDate = date;
                      });
                    }
                  },
                  child: Text(
                    _endDate != null
                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                        : 'Seleccionar fecha',
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _endTime = time;
                      });
                    }
                  },
                  child: Text(
                    _endTime != null
                        ? _endTime!.format(context)
                        : 'Seleccionar hora',
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _createCourse() {
    if (_formKey.currentState!.validate()) {
      // Lógica para crear el curso
      final courseTitle = _courseTitleController.text;
      final groupSize = int.parse(_groupSizeController.text);
      final groupPrefix = _groupPrefixController.text.isNotEmpty
          ? _groupPrefixController.text
          : null;
      
      // Aquí iría la lógica para guardar el curso
      print('Curso creado: $courseTitle, Tamaño: $groupSize, Prefijo: $groupPrefix');
      
      // Navegar de vuelta al homepage
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _courseTitleController.dispose();
    _groupSizeController.dispose();
    _groupPrefixController.dispose();
    super.dispose();
  }
}