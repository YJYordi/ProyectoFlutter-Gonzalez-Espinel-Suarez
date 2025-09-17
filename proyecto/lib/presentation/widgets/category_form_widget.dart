import 'package:flutter/material.dart';
import 'package:proyecto/Domain/Entities/category.dart';

class CategoryFormWidget extends StatefulWidget {
  final CategoryEntity? editingCategory;
  final Function({
    required String name,
    required int numberOfGroups,
    required bool isRandomAssignment,
  }) onSubmit;
  final VoidCallback onCancel;

  const CategoryFormWidget({
    Key? key,
    this.editingCategory,
    required this.onSubmit,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<CategoryFormWidget> createState() => _CategoryFormWidgetState();
}

class _CategoryFormWidgetState extends State<CategoryFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberOfGroupsController = TextEditingController();
  bool _isRandomAssignment = false;
  final GlobalKey _widgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void didUpdateWidget(CategoryFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambió la categoría que se está editando, reinicializar el formulario
    if (oldWidget.editingCategory?.id != widget.editingCategory?.id) {
      _initializeForm();
    }
  }

  void _initializeForm() {
    if (widget.editingCategory != null) {
      _nameController.text = widget.editingCategory!.name;
      _numberOfGroupsController.text = widget.editingCategory!.numberOfGroups.toString();
      _isRandomAssignment = widget.editingCategory!.isRandomAssignment;
    } else {
      // Limpiar el formulario para nueva categoría
      _nameController.clear();
      _numberOfGroupsController.clear();
      _isRandomAssignment = false;
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    _numberOfGroupsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        name: _nameController.text.trim(),
        numberOfGroups: int.parse(_numberOfGroupsController.text),
        isRandomAssignment: _isRandomAssignment,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _widgetKey,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              widget.editingCategory != null ? 'Editar Categoría' : 'Nueva Categoría',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Category name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de Categoría',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre de la categoría es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Number of groups field
            TextFormField(
              controller: _numberOfGroupsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad de Grupos',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.group),
                helperText: 'Mínimo 1, máximo 10',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La cantidad de grupos es requerida';
                }
                final number = int.tryParse(value);
                if (number == null) {
                  return 'Debe ser un número válido';
                }
                if (number < 1 || number > 10) {
                  return 'Debe estar entre 1 y 10';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Random assignment toggle
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shuffle, color: Colors.grey),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Asignación Random',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Switch(
                    value: _isRandomAssignment,
                    onChanged: (value) {
                      setState(() {
                        _isRandomAssignment = value;
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.editingCategory != null ? 'Actualizar' : 'Crear',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
