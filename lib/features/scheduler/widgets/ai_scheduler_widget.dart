import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../models/schedule_item.dart';
import '../services/scheduler_ai_service.dart';
import 'schedule_timeline_widget.dart';

enum SchedulerState { idle, drafting, review, applied }

class AiSchedulerWidget extends StatefulWidget {
  const AiSchedulerWidget({super.key});

  @override
  State<AiSchedulerWidget> createState() => _AiSchedulerWidgetState();
}

class _AiSchedulerWidgetState extends State<AiSchedulerWidget> {
  final SchedulerAiService _service = SchedulerAiService();
  final TextEditingController _promptController = TextEditingController();

  SchedulerState _state = SchedulerState.idle;
  List<ScheduleItem> _currentSchedule = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentSchedule = _service.getCachedSchedule();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generateDraft() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _state = SchedulerState.drafting;
      _errorMessage = null;
    });

    try {
      final items = await _service.draftScheduleFromPrompt(prompt);
      setState(() {
        _currentSchedule = items;
        _state = SchedulerState.review;
      });
    } catch (e) {
      setState(() {
        _state = SchedulerState.idle;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _applySchedule() async {
    setState(() => _state = SchedulerState.drafting);
    final success = await _service.applyToDevice(_currentSchedule);

    if (mounted) {
      setState(() {
        _state = SchedulerState.applied;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: success
              ? AppColors.surface
              : AppColors.warningCutoff,
          content: Row(
            children: [
              Icon(
                success ? LucideIcons.shieldCheck : LucideIcons.alertCircle,
                color: success ? AppColors.nutritionAccent : Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                success
                    ? 'Schedule applied. 22:30 cut-off & 23:00 sleep alarms armed.'
                    : 'Partial sync warning. Alarms armed.',
                style: AppTypography.body,
              ),
            ],
          ),
        ),
      );
    }
  }

  void _toggleItem(ScheduleItem item) {
    setState(() {
      final index = _currentSchedule.indexWhere((e) => e.id == item.id);
      if (index != -1) {
        _currentSchedule[index] = item.copyWith(isCompleted: !item.isCompleted);
        _service.saveActiveSchedule(_currentSchedule);
      }
    });
  }

  void _addQuickPrompt(String text) {
    _promptController.text = text;
    _generateDraft();
  }

  @override
  Widget build(BuildContext context) {
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
                      color: AppColors.accentPrimary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.bot,
                      color: AppColors.accentPrimary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Interactive Scheduler', style: AppTypography.h3),
                      Text(
                        'Dynamic Discipline & Sleep Optimizer',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ],
              ),
              if (_currentSchedule.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.clock,
                        size: 12,
                        color: AppColors.accentPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_currentSchedule.length} Blocks',
                        style: AppTypography.timeStamp,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Preset Prompts
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _presetChip('WFH + IaC Deep Work + Gym', LucideIcons.laptop),
              _presetChip('WFO Sprint + Fasting', LucideIcons.building),
              _presetChip(
                'Weekend Recovery Cut-off',
                LucideIcons.batteryCharging,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Input Text Field & Generate Button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promptController,
                  style: AppTypography.body,
                  decoration: InputDecoration(
                    hintText:
                        'e.g. WFH ngulik IaC Kubernetes, gym 17.30, strict tidur 23.00...',
                    prefixIcon: const Icon(
                      LucideIcons.sparkles,
                      size: 16,
                      color: AppColors.accentPrimary,
                    ),
                    suffixIcon: _promptController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              LucideIcons.x,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            onPressed: () =>
                                setState(() => _promptController.clear()),
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _generateDraft(),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _state == SchedulerState.drafting
                      ? null
                      : _generateDraft,
                  icon: _state == SchedulerState.drafting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.background,
                          ),
                        )
                      : const Icon(LucideIcons.sparkles, size: 16),
                  label: Text(
                    _state == SchedulerState.drafting
                        ? 'Architecting...'
                        : 'Draft AI',
                  ),
                ),
              ),
            ],
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warningCutoff.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.warningCutoff.withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.alertCircle,
                    size: 16,
                    color: AppColors.warningCutoff,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.warningCutoff,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Timeline View
          ScheduleTimelineWidget(
            items: _currentSchedule,
            onItemToggled: _toggleItem,
          ),

          const SizedBox(height: 14),

          // Action Apply to Device Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentSchedule = _service.getCachedSchedule();
                    _state = SchedulerState.idle;
                  });
                },
                icon: const Icon(LucideIcons.rotateCcw, size: 14),
                label: const Text('Reset'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.nutritionAccent,
                  foregroundColor: const Color(0xFF06090E),
                ),
                onPressed: _currentSchedule.isEmpty ? null : _applySchedule,
                icon: const Icon(LucideIcons.checkCheck, size: 16),
                label: const Text('Apply to Device & Alarms'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _presetChip(String text, IconData icon) {
    return InkWell(
      onTap: () => _addQuickPrompt(text),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(text, style: AppTypography.caption),
          ],
        ),
      ),
    );
  }
}
