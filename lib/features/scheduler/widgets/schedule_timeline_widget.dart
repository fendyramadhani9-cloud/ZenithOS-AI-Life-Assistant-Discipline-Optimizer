import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../models/schedule_item.dart';

class ScheduleTimelineWidget extends StatelessWidget {
  final List<ScheduleItem> items;
  final Function(ScheduleItem)? onItemToggled;
  final Function(ScheduleItem)? onItemEdited;

  const ScheduleTimelineWidget({
    super.key,
    required this.items,
    this.onItemToggled,
    this.onItemEdited,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fitness':
      case 'gym':
        return LucideIcons.dumbbell;
      case 'sleep':
        return LucideIcons.moon;
      case 'recovery':
        return LucideIcons.shieldCheck;
      case 'nutrition':
      case 'food':
        return LucideIcons.utensils;
      case 'work':
      default:
        return LucideIcons.terminal;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'fitness':
      case 'gym':
        return AppColors.accentSecondary;
      case 'sleep':
      case 'recovery':
        return AppColors.warningCutoff;
      case 'nutrition':
      case 'food':
        return AppColors.nutritionAccent;
      case 'work':
      default:
        return AppColors.accentPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.calendar, color: AppColors.textMuted, size: 32),
              const SizedBox(height: 8),
              Text('No timeline blocks loaded.', style: AppTypography.caption),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final catColor = _getCategoryColor(item.category);
        final catIcon = _getCategoryIcon(item.category);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: item.priority == 'urgent'
                  ? AppColors.warningCutoff.withOpacity(0.5)
                  : AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Time Range Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '${item.startTime} - ${item.endTime}',
                  style: AppTypography.timeStamp,
                ),
              ),
              const SizedBox(width: 10),

              // Category Indicator Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(catIcon, size: 14, color: catColor),
              ),
              const SizedBox(width: 10),

              // Title & Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: item.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: item.isCompleted
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.description,
                        style: AppTypography.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Toggle Completion Action
              IconButton(
                icon: Icon(
                  item.isCompleted
                      ? LucideIcons.checkCircle2
                      : LucideIcons.circle,
                  color: item.isCompleted
                      ? AppColors.nutritionAccent
                      : AppColors.textMuted,
                  size: 18,
                ),
                onPressed: () => onItemToggled?.call(item),
                splashRadius: 18,
              ),
            ],
          ),
        );
      },
    );
  }
}
