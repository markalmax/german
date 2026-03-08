import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final double percentage;
  final Color color;
  final String label;

  const ProgressIndicatorWidget({
    super.key,
    required this.percentage,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = percentage.clamp(0.0, 100.0);
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: clamped / 100.0,
            strokeWidth: 5,
            color: color,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${clamped.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

