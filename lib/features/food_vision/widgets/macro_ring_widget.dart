import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class MacroRingWidget extends StatelessWidget {
  final int currentCalories;
  final int targetCalories;
  final double currentProtein;
  final double targetProtein;
  final double currentWeight;
  final double targetWeight;

  const MacroRingWidget({
    super.key,
    this.currentCalories = 1650,
    this.targetCalories = 2100,
    this.currentProtein = 135.0,
    this.targetProtein = 160.0,
    this.currentWeight = 68.2,
    this.targetWeight = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    final calorieRatio = (currentCalories / targetCalories).clamp(0.0, 1.0);
    final proteinRatio = (currentProtein / targetProtein).clamp(0.0, 1.0);

    // Weight cut progress from start 70.0 kg down to 64.0 kg
    const startWeight = 70.0;
    final totalLossNeeded = startWeight - targetWeight; // 6.0 kg
    final lossAchieved = (startWeight - currentWeight).clamp(
      0.0,
      totalLossNeeded,
    );
    final weightProgress = (lossAchieved / totalLossNeeded).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weight Cut Milestone Bar (70kg -> 64kg)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.scale,
                    size: 14,
                    color: AppColors.nutritionAccent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Target Cut: 70kg -> 64kg',
                    style: AppTypography.caption,
                  ),
                ],
              ),
              Text(
                '${currentWeight.toStringAsFixed(1)} kg (${(weightProgress * 100).toInt()}%)',
                style: AppTypography.timeStamp,
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: weightProgress,
              minHeight: 6,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.nutritionAccent,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Ring Metrics (Calories & Protein)
          Row(
            children: [
              // Circular Macro Indicator
              SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: calorieRatio,
                      strokeWidth: 6,
                      backgroundColor: AppColors.background,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.accentPrimary,
                      ),
                    ),
                    CircularProgressIndicator(
                      value: proteinRatio,
                      strokeWidth: 3,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.nutritionAccent,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$currentCalories',
                          style: AppTypography.metricSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'kcal',
                          style: AppTypography.caption.copyWith(fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Macro Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _macroRow(
                      'Calories Deficit',
                      '$currentCalories / $targetCalories kcal',
                      AppColors.accentPrimary,
                    ),
                    const SizedBox(height: 4),
                    _macroRow(
                      'Protein Target',
                      '${currentProtein.toInt()} / ${targetProtein.toInt()} g',
                      AppColors.nutritionAccent,
                    ),
                    const SizedBox(height: 4),
                    _macroRow(
                      'Deficit Buffer',
                      '-${(targetCalories - currentCalories).clamp(0, 3000)} kcal',
                      AppColors.accentSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label, style: AppTypography.caption),
          ],
        ),
        Text(value, style: AppTypography.metricSmall.copyWith(fontSize: 11)),
      ],
    );
  }
}
