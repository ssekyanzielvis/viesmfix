import 'package:flutter/material.dart';
import 'dart:async';

/// Countdown Timer Widget for upcoming matches
class CountdownTimer extends StatefulWidget {
  final DateTime targetTime;
  final TextStyle? textStyle;
  final bool compact;

  const CountdownTimer({
    super.key,
    required this.targetTime,
    this.textStyle,
    this.compact = false,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  Duration? _timeRemaining;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _timeRemaining = widget.targetTime.difference(DateTime.now());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_timeRemaining == null || _timeRemaining!.isNegative) {
      return const SizedBox.shrink();
    }

    final days = _timeRemaining!.inDays;
    final hours = _timeRemaining!.inHours.remainder(24);
    final minutes = _timeRemaining!.inMinutes.remainder(60);
    final seconds = _timeRemaining!.inSeconds.remainder(60);

    if (widget.compact) {
      return Text(
        _getCompactFormat(days, hours, minutes),
        style:
            widget.textStyle ??
            TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (days > 0) ...[
          _TimeUnit(value: days, label: 'D'),
          const SizedBox(width: 4),
          const Text(':', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
        ],
        if (days > 0 || hours > 0) ...[
          _TimeUnit(value: hours, label: 'H'),
          const SizedBox(width: 4),
          const Text(':', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
        ],
        _TimeUnit(value: minutes, label: 'M'),
        if (days == 0 && hours == 0) ...[
          const SizedBox(width: 4),
          const Text(':', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          _TimeUnit(value: seconds, label: 'S'),
        ],
      ],
    );
  }

  String _getCompactFormat(int days, int hours, int minutes) {
    if (days > 0) {
      return '$days${days == 1 ? 'day' : 'days'} ${hours}h';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return 'Starting soon';
    }
  }
}

class _TimeUnit extends StatelessWidget {
  final int value;
  final String label;

  const _TimeUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
          ),
        ),
      ],
    );
  }
}

/// Pulsing Live Indicator
class LiveIndicator extends StatefulWidget {
  final double size;
  final bool showText;

  const LiveIndicator({super.key, this.size = 12, this.showText = true});

  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(_animation.value),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(_animation.value * 0.5),
                    blurRadius: widget.size,
                    spreadRadius: widget.size / 4,
                  ),
                ],
              ),
            ),
            if (widget.showText) ...[
              const SizedBox(width: 6),
              Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: widget.size,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
