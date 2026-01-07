import 'package:flutter/material.dart';

/// Static rating display widget
class StaticRatingWidget extends StatelessWidget {
  final double rating;
  final double size;

  const StaticRatingWidget({super.key, required this.rating, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, size: size, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Interactive rating widget for user input
class InteractiveRatingWidget extends StatefulWidget {
  final double initialRating;
  final Function(double) onRatingChanged;
  final double size;

  const InteractiveRatingWidget({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.size = 30,
  });

  @override
  State<InteractiveRatingWidget> createState() =>
      _InteractiveRatingWidgetState();
}

class _InteractiveRatingWidgetState extends State<InteractiveRatingWidget> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 1; i <= 5; i++)
          GestureDetector(
            onTap: () {
              setState(() {
                _currentRating = i.toDouble();
              });
              widget.onRatingChanged(_currentRating);
            },
            child: Icon(
              i <= _currentRating ? Icons.star : Icons.star_outline,
              size: widget.size,
              color: Colors.amber,
            ),
          ),
        const SizedBox(width: 12),
        Text(
          _currentRating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
