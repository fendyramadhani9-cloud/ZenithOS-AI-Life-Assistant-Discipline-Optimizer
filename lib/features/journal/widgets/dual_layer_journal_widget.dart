import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/storage/storage_service.dart';
import '../models/journal_entry.dart';

class DualLayerJournalWidget extends StatefulWidget {
  const DualLayerJournalWidget({super.key});

  @override
  State<DualLayerJournalWidget> createState() => _DualLayerJournalWidgetState();
}

class _DualLayerJournalWidgetState extends State<DualLayerJournalWidget> {
  final TextEditingController _todoInputController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();

  List<TodoItem> _todos = [];
  bool _isPartnerShared = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadTodayJournal();
  }

  @override
  void dispose() {
    _todoInputController.dispose();
    _storyController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _loadTodayJournal() {
    final now = DateTime.now();
    final todayKey =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final entries = StorageService.instance.getAllJournalEntries();

    final match = entries.cast<Map<String, dynamic>?>().firstWhere(
      (e) => e != null && e['id'] == todayKey,
      orElse: () => null,
    );

    if (match != null) {
      final entry = JournalEntry.fromMap(match);
      setState(() {
        _todos = entry.todos;
        _storyController.text = entry.unfilteredStory;
        _isPartnerShared = entry.isPartnerShared;
      });
    } else {
      // Default initial daily bullets
      setState(() {
        _todos = [
          TodoItem(
            id: '1',
            title: 'Review Kubernetes Ingress & Terraform state',
            isCompleted: true,
          ),
          TodoItem(
            id: '2',
            title: 'Complete 15-min Zone 2 Cardio at Gym',
            isCompleted: false,
          ),
          TodoItem(
            id: '3',
            title: 'Verify Gemini API Key Failover in ZenithOS',
            isCompleted: false,
          ),
        ];
      });
      _saveJournal();
    }
  }

  void _saveJournal() {
    final now = DateTime.now();
    final todayKey =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final entry = JournalEntry(
      id: todayKey,
      date: now,
      todos: _todos,
      unfilteredStory: _storyController.text,
      isPartnerShared: _isPartnerShared,
    );
    StorageService.instance.saveJournalEntry(entry.toMap());
  }

  void _onStoryChanged(String text) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _saveJournal();
    });
  }

  void _addTodo() {
    final text = _todoInputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _todos.add(
        TodoItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: text,
          isCompleted: false,
        ),
      );
      _todoInputController.clear();
    });
    _saveJournal();
  }

  void _toggleTodo(TodoItem item) {
    setState(() {
      final index = _todos.indexWhere((e) => e.id == item.id);
      if (index != -1) {
        _todos[index] = item.copyWith(isCompleted: !item.isCompleted);
      }
    });
    _saveJournal();
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((e) => e.id == id);
    });
    _saveJournal();
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _todos.where((e) => e.isCompleted).length;

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
          // Header & Privacy Toggle Switch
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
                    child: const Icon(
                      LucideIcons.fileText,
                      color: AppColors.accentSecondary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Log (Dual-Layer)', style: AppTypography.h3),
                      Text(
                        'Time Capsule & Unfiltered Record',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ],
              ),

              // Privacy Switcher Button
              InkWell(
                onTap: () {
                  setState(() {
                    _isPartnerShared = !_isPartnerShared;
                  });
                  _saveJournal();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _isPartnerShared
                        ? AppColors.accentPrimary.withOpacity(0.15)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isPartnerShared
                          ? AppColors.accentPrimary
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isPartnerShared
                            ? LucideIcons.share2
                            : LucideIcons.lock,
                        size: 13,
                        color: _isPartnerShared
                            ? AppColors.accentPrimary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isPartnerShared ? 'Partner Shared' : 'Private Only',
                        style: AppTypography.caption.copyWith(
                          color: _isPartnerShared
                              ? AppColors.accentPrimary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Layer 1: Quick Bullets (Checklist)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LAYER 1: QUICK BULLETS',
                style: AppTypography.caption.copyWith(letterSpacing: 0.8),
              ),
              Text(
                '$completedCount/${_todos.length} Done',
                style: AppTypography.timeStamp,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Todo input field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _todoInputController,
                  style: AppTypography.body,
                  decoration: const InputDecoration(
                    hintText: 'Add tactical bullet point...',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: (_) => _addTodo(),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: _addTodo,
                icon: const Icon(
                  LucideIcons.plusCircle,
                  color: AppColors.accentPrimary,
                  size: 20,
                ),
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Bullets List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _todos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final todo = _todos[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => _toggleTodo(todo),
                      child: Icon(
                        todo.isCompleted
                            ? LucideIcons.checkSquare
                            : LucideIcons.square,
                        color: todo.isCompleted
                            ? AppColors.nutritionAccent
                            : AppColors.textMuted,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        todo.title,
                        style: AppTypography.body.copyWith(
                          fontSize: 12.5,
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: todo.isCompleted
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        LucideIcons.trash2,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () => _deleteTodo(todo.id),
                      splashRadius: 14,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Layer 2: The Unfiltered Story
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LAYER 2: THE UNFILTERED STORY',
                style: AppTypography.caption.copyWith(letterSpacing: 0.8),
              ),
              const Icon(
                LucideIcons.shieldCheck,
                size: 13,
                color: AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _storyController,
            onChanged: _onStoryChanged,
            maxLines: 5,
            style: AppTypography.body.copyWith(height: 1.5),
            decoration: const InputDecoration(
              hintText:
                  'Raw thoughts, architecture bottlenecks, wins, or emotional clarity for future retrospectives...',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }
}
