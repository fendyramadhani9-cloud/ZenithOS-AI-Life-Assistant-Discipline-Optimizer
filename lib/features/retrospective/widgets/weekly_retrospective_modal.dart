import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/storage/storage_service.dart';
import '../../../services/ai/ai_factory.dart';

class WeeklyRetrospectiveModal extends StatefulWidget {
  const WeeklyRetrospectiveModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const WeeklyRetrospectiveModal(),
    );
  }

  @override
  State<WeeklyRetrospectiveModal> createState() => _WeeklyRetrospectiveModalState();
}

class _WeeklyRetrospectiveModalState extends State<WeeklyRetrospectiveModal> {
  bool _isLoading = true;
  String _briefingText = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final journalEntries = StorageService.instance.getAllJournalEntries();
      final mealEntries = StorageService.instance.getAllMealEntries();
      final waterLiters = (StorageService.instance.getTodayHydration() * 7 / 1000).toInt();

      final result = await AiFactory.executeWithFailover(
        (service) => service.generateWeeklyRetrospective(
          journalEntries: journalEntries,
          mealEntries: mealEntries,
          totalWaterLiters: waterLiters > 0 ? waterLiters : 18,
        ),
      );

      setState(() {
        _briefingText = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 650, maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentSecondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.calendarCheck, color: AppColors.accentSecondary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Weekly Retrospective Briefing', style: AppTypography.h2),
                        Text('Sunday Discipline & Performance Wrap-Up', style: AppTypography.caption),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 18, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: AppColors.accentSecondary),
                          const SizedBox(height: 16),
                          Text('Aggregating 7-day metrics & generating executive briefing...', style: AppTypography.bodySecondary),
                        ],
                      ),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.alertTriangle, color: AppColors.warningCutoff, size: 36),
                              const SizedBox(height: 10),
                              Text('Generation Failed', style: AppTypography.h3),
                              const SizedBox(height: 6),
                              Text(_errorMessage!, style: AppTypography.caption, textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _generateReport,
                                icon: const Icon(LucideIcons.rotateCcw, size: 14),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: SelectableText(
                              _briefingText,
                              style: AppTypography.body.copyWith(height: 1.6),
                            ),
                          ),
                        ),
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _generateReport,
                  icon: const Icon(LucideIcons.refreshCw, size: 14),
                  label: const Text('Re-evaluate'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Acknowledge & Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
