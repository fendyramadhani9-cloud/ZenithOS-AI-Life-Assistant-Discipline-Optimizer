import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/storage/storage_service.dart';

class HydrationTrackerWidget extends StatefulWidget {
  const HydrationTrackerWidget({super.key});

  @override
  State<HydrationTrackerWidget> createState() => _HydrationTrackerWidgetState();
}

class _HydrationTrackerWidgetState extends State<HydrationTrackerWidget> {
  int _currentHydrationMl = 0;
  int _targetGoalMl = 2500;

  @override
  void initState() {
    super.initState();
    _loadHydration();
  }

  void _loadHydration() {
    setState(() {
      _currentHydrationMl = StorageService.instance.getTodayHydration();
      _targetGoalMl = StorageService.instance.getHydrationGoal();
    });
  }

  Future<void> _addWater(int amountMl) async {
    await StorageService.instance.logHydration(amountMl);
    _loadHydration();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = (_currentHydrationMl / _targetGoalMl).clamp(0.0, 1.0);
    final percentage = (ratio * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.hydrationAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.droplets,
                      color: AppColors.hydrationAccent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hydration Tracker', style: AppTypography.h3),
                      Text(
                        'Target: $_targetGoalMl ml / day',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '$_currentHydrationMl ml',
                style: AppTypography.metricMedium.copyWith(
                  color: AppColors.hydrationAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$percentage% of daily target',
                style: AppTypography.caption,
              ),
              Text(
                '${(_targetGoalMl - _currentHydrationMl).clamp(0, 5000)} ml remaining',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.hydrationAccent,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Quick Action Buttons (+250ml and +500ml)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _addWater(250),
                  icon: const Icon(
                    LucideIcons.plus,
                    size: 14,
                    color: AppColors.hydrationAccent,
                  ),
                  label: const Text('+250 ml'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _addWater(500),
                  icon: const Icon(
                    LucideIcons.plus,
                    size: 14,
                    color: AppColors.hydrationAccent,
                  ),
                  label: const Text('+500 ml'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
