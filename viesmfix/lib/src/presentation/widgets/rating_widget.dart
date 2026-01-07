import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showNumber;

  const RatingWidget({
    super.key,
    required this.rating,
    this.maxRating = 10,
    this.size = 20,
    this.activeColor,
    this.inactiveColor,
    this.showNumber = true,
  });

  @override
  Widget build(BuildContext context) {
    final stars = (rating / 2).round(); // Convert 10-point scale to 5-star
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < stars ? Icons.star : Icons.star_border,
            size: size,
            color: index < stars
                ? (activeColor ?? Colors.amber)
                : (inactiveColor ?? colorScheme.onSurfaceVariant),
          );
        }),
        if (showNumber) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(fontSize: size * 0.8, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }
}

class InteractiveRatingWidget extends StatefulWidget {
  final double initialRating;
  final ValueChanged<double>? onRatingChanged;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const InteractiveRatingWidget({
    super.key,
    this.initialRating = 0,
    this.onRatingChanged,
    this.size = 32,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<InteractiveRatingWidget> createState() =>
      _InteractiveRatingWidgetState();
}

class _InteractiveRatingWidgetState extends State<InteractiveRatingWidget> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(10, (index) {
        final value = index + 1.0;
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = value;
            });
            widget.onRatingChanged?.call(value);
          },
          child: Icon(
            value <= _rating ? Icons.star : Icons.star_border,
            size: widget.size,
            color: value <= _rating
                ? (widget.activeColor ?? Colors.amber)
                : (widget.inactiveColor ?? Colors.grey),
          ),
        );
      }),
    );
  }
}
