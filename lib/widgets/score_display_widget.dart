import 'package:flutter/material.dart';

class ScoreDisplayWidget extends StatefulWidget {
  final double score;
  final bool isNewBest;
  final VoidCallback? onAnimationComplete;

  const ScoreDisplayWidget({
    super.key,
    required this.score,
    required this.isNewBest,
    this.onAnimationComplete,
  });

  @override
  State<ScoreDisplayWidget> createState() => _ScoreDisplayWidgetState();
}

class _ScoreDisplayWidgetState extends State<ScoreDisplayWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          widget.onAnimationComplete != null) {
        widget.onAnimationComplete!();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final target = widget.score.clamp(0.0, 100.0);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final value = (target * _animation.value);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${value.toStringAsFixed(0)}',
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              '/ 100',
              style: theme.textTheme.titleMedium,
            ),
            if (widget.isNewBest) ...[
              const SizedBox(height: 8),
              Chip(
                avatar: const Icon(Icons.emoji_events, size: 18),
                label: const Text('New best score!'),
                backgroundColor:
                    theme.colorScheme.primaryContainer,
              ),
            ],
          ],
        );
      },
    );
  }
}

