import 'package:flutter/material.dart';

class StarRatingWidget extends StatefulWidget {
  final int initialRating;
  final Function(int) onRatingChanged;
  final String criterion;
  final String description;
  final String spanishDescription;
  final bool isReadOnly;

  const StarRatingWidget({
    super.key,
    required this.initialRating,
    required this.onRatingChanged,
    required this.criterion,
    required this.description,
    required this.spanishDescription,
    this.isReadOnly = false,
  });

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget>
    with TickerProviderStateMixin {
  late int _currentRating;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      5,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _animations = _animationControllers
        .map((controller) => Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeInOut,
            )))
        .toList();

    // Animar las estrellas iniciales
    for (int i = 0; i < _currentRating; i++) {
      _animationControllers[i].forward();
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onStarTapped(int index) {
    if (widget.isReadOnly) return;

    setState(() {
      _currentRating = index + 1;
    });

    // Animar las estrellas
    for (int i = 0; i < 5; i++) {
      if (i < _currentRating) {
        _animationControllers[i].forward();
      } else {
        _animationControllers[i].reverse();
      }
    }

    widget.onRatingChanged(_currentRating);
  }

  String _getRatingDescription(int rating) {
    switch (rating) {
      case 0:
        return 'Sin calificar';
      case 1:
      case 2:
        return 'Necesita mejorar (${rating} estrella${rating > 1 ? 's' : ''})';
      case 3:
        return 'Adecuado (${rating} estrellas)';
      case 4:
        return 'Bueno (${rating} estrellas)';
      case 5:
        return 'Excelente (${rating} estrellas)';
      default:
        return 'Sin calificar';
    }
  }

  Color _getStarColor(int index) {
    if (index < _currentRating) {
      return Colors.amber;
    }
    return Colors.grey[300]!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del criterio
          Text(
            widget.criterion,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          
          // Descripción en español
          Text(
            widget.spanishDescription,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          
          // Estrellas
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => _onStarTapped(index),
                child: AnimatedBuilder(
                  animation: _animations[index],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animations[index].value * 0.2 + 0.8,
                      child: Container(
                        margin: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.star,
                          size: 32,
                          color: _getStarColor(index),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          
          // Descripción de la calificación actual
          Text(
            _getRatingDescription(_currentRating),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _currentRating > 0 ? Colors.blue[700] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class StarRatingDisplayWidget extends StatelessWidget {
  final int rating;
  final String criterion;
  final String description;
  final String spanishDescription;

  const StarRatingDisplayWidget({
    super.key,
    required this.rating,
    required this.criterion,
    required this.description,
    required this.spanishDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del criterio
          Text(
            criterion,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          
          // Descripción en español
          Text(
            spanishDescription,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          
          // Estrellas (solo visualización)
          Row(
            children: List.generate(5, (index) {
              return Container(
                margin: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.star,
                  size: 28,
                  color: index < rating ? Colors.amber : Colors.grey[300],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          
          // Descripción de la calificación
          Text(
            _getRatingDescription(rating),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: rating > 0 ? Colors.blue[700] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _getRatingDescription(int rating) {
    switch (rating) {
      case 0:
        return 'Sin calificar';
      case 1:
      case 2:
        return 'Necesita mejorar (${rating} estrella${rating > 1 ? 's' : ''})';
      case 3:
        return 'Adecuado (${rating} estrellas)';
      case 4:
        return 'Bueno (${rating} estrellas)';
      case 5:
        return 'Excelente (${rating} estrellas)';
      default:
        return 'Sin calificar';
    }
  }
}
