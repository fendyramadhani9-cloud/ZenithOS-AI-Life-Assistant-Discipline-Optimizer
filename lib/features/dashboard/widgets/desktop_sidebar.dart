import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/network_queue/offline_queue_service.dart';
import '../../../core/storage/storage_service.dart';
import '../../../services/ai/key_vault_controller.dart';
import '../../retrospective/widgets/weekly_retrospective_modal.dart';
import '../../settings/screens/key_vault_screen.dart';

class DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final userName = StorageService.instance.getUserName();
    final activeKey = KeyVaultController.instance.activeKey;

    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Branding
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.accentPrimary,
                      AppColors.accentSecondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.terminal,
                  color: Color(0xFF0A0D14),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ZenithOS', style: AppTypography.h2),
                  Text(
                    'DISCIPLINE VAULT',
                    style: AppTypography.caption.copyWith(
                      letterSpacing: 1.0,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // User & Active AI Badge
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      LucideIcons.user,
                      size: 14,
                      color: AppColors.accentPrimary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        userName,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: activeKey != null
                            ? AppColors.nutritionAccent
                            : AppColors.warningCutoff,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        activeKey != null
                            ? '${activeKey.provider.name.toUpperCase()}: ${activeKey.label}'
                            : 'No Active Key',
                        style: AppTypography.caption.copyWith(fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Navigation Links
          Expanded(
            child: ListView(
              children: [
                _navItem(0, 'Dashboard', LucideIcons.layoutDashboard),
                _navItem(1, 'AI Scheduler', LucideIcons.calendar),
                _navItem(2, 'Smart Food Vision', LucideIcons.camera),
                _navItem(3, 'Daily Log Capsule', LucideIcons.fileText),
                _navItem(4, 'Hydration Tracker', LucideIcons.droplets),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                ListTile(
                  dense: true,
                  leading: const Icon(
                    LucideIcons.calendarCheck,
                    size: 16,
                    color: AppColors.accentSecondary,
                  ),
                  title: Text(
                    'Weekly Retrospective',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () => WeeklyRetrospectiveModal.show(context),
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(
                    LucideIcons.keyRound,
                    size: 16,
                    color: AppColors.accentPrimary,
                  ),
                  title: Text(
                    'Key Vault & Backup',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const KeyVaultScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Bottom Connectivity & Offline Queue Status
          AnimatedBuilder(
            animation: OfflineQueueService.instance,
            builder: (context, _) {
              final isOnline = OfflineQueueService.instance.isOnline;
              final pending = OfflineQueueService.instance.pendingCount;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      isOnline ? LucideIcons.wifi : LucideIcons.wifiOff,
                      size: 14,
                      color: isOnline
                          ? AppColors.nutritionAccent
                          : AppColors.warningCutoff,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isOnline
                            ? (pending > 0
                                  ? 'Syncing ($pending pending)'
                                  : 'Engine Online')
                            : 'Offline Mode ($pending queued)',
                        style: AppTypography.caption.copyWith(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _navItem(int index, String label, IconData icon) {
    final isSelected = selectedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.accentPrimary.withOpacity(0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? AppColors.accentPrimary.withOpacity(0.4)
              : Colors.transparent,
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          size: 16,
          color: isSelected ? AppColors.accentPrimary : AppColors.textSecondary,
        ),
        title: Text(
          label,
          style: AppTypography.body.copyWith(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onTap: () => onDestinationSelected(index),
      ),
    );
  }
}
