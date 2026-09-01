import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class EvaluationBarWidget extends StatelessWidget {
  final int scoreCentipawns;
  final bool isFlipped;

  const EvaluationBarWidget({
    super.key,
    required this.scoreCentipawns,
    this.isFlipped = false,
  });

  @override
  Widget build(BuildContext context) {
    // Clamp evaluation score between -1000 and +1000 centipawns (-10.0 to +10.0 pawns)
    final clampedScore = scoreCentipawns.clamp(-1000, 1000);
    // Convert to percentage (0.0 to 1.0) where 0.5 is equal, 1.0 is +10 White, 0.0 is -10 Black
    final whiteFraction = (clampedScore + 1000) / 2000.0;
    final topFraction = isFlipped ? whiteFraction : (1.0 - whiteFraction);

    return Container(
      width: 14,
      decoration: BoxDecoration(
        color: const Color(0xFF1E232A),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.darkBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Expanded(
                flex: (topFraction * 1000).toInt().clamp(1, 999),
                child: Container(
                  color: isFlipped ? Colors.white : const Color(0xFF161B22),
                ),
              ),
              Expanded(
                flex: ((1.0 - topFraction) * 1000).toInt().clamp(1, 999),
                child: Container(
                  color: isFlipped ? const Color(0xFF161B22) : Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
