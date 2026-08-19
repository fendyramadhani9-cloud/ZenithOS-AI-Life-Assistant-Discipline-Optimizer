import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/utils/backup_service.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../food_vision/widgets/food_vision_card.dart';
import '../../hydration/widgets/hydration_tracker_widget.dart';
import '../../journal/widgets/dual_layer_journal_widget.dart';
import '../../retrospective/widgets/weekly_retrospective_modal.dart';
import '../../scheduler/widgets/ai_scheduler_widget.dart';
import '../../settings/screens/key_vault_screen.dart';
import '../widgets/desktop_sidebar.dart';
import '../widgets/mobile_bottom_nav.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveLayout(
        desktop: _buildDesktopLayout(),
        mobile: _buildMobileLayout(),
      ),
    );
  }

  // --- Desktop / Web Layout (Screen Width >= 900px) ---
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Fixed Sidebar Left
        DesktopSidebar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
        ),

        // Main Multi-Column Content Area
        Expanded(
          child: Column(
            children: [
              // Top Bar
              _buildDesktopTopBar(),

              // 3-Column Content Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Column 1 (Primary): Interactive AI Scheduler & Timeline
                      const Expanded(
                        flex: 4,
                        child: AiSchedulerWidget(),
                      ),
                      const SizedBox(width: 16),

                      // Column 2 (Center): Daily Log (Dual-Layer) + Hydration Tracker
                      const Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            DualLayerJournalWidget(),
                            SizedBox(height: 16),
                            HydrationTrackerWidget(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Column 3 (Right): Food Vision Macro Ring & Quick Action Card
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            const FoodVisionCard(),
                            const SizedBox(height: 16),
                            _buildQuickActionCard(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTopBar() {
    final userName = StorageService.instance.getUserName();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('Welcome, $userName', style: AppTypography.h3),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentPrimary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.accentPrimary.withOpacity(0.3)),
                ),
                child: Text('DISCIPLINE MODE ACTIVE', style: AppTypography.caption.copyWith(color: AppColors.accentPrimary, fontSize: 10)),
              ),
            ],
          ),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => WeeklyRetrospectiveModal.show(context),
                icon: const Icon(LucideIcons.calendarCheck, size: 14, color: AppColors.accentSecondary),
                label: const Text('Weekly Wrap-Up'),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(LucideIcons.keyRound, size: 18, color: AppColors.textSecondary),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const KeyVaultScreen()),
                  );
                },
                tooltip: 'Key Vault & Backups',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard() {
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
          Row(
            children: [
              const Icon(LucideIcons.shieldCheck, color: AppColors.accentPrimary, size: 18),
              const SizedBox(width: 8),
              Text('Quick System Action', style: AppTypography.h3),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final filename = BackupService.getBackupFilename();
                BackupService.generateBackupJson();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.surface,
                    content: Text('Instant snapshot created: $filename', style: AppTypography.body),
                  ),
                );
              },
              icon: const Icon(LucideIcons.downloadCloud, size: 14),
              label: const Text('Export JSON Snapshot'),
            ),
          ),
        ],
      ),
    );
  }

  // --- Mobile Android Layout (Screen Width < 900px) ---
  Widget _buildMobileLayout() {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: AppColors.background,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accentPrimary, AppColors.accentSecondary],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(LucideIcons.terminal, color: Color(0xFF0A0D14), size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text('ZenithOS', style: AppTypography.h2),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(LucideIcons.calendarCheck, size: 18, color: AppColors.accentSecondary),
                  onPressed: () => WeeklyRetrospectiveModal.show(context),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.keyRound, size: 18, color: AppColors.textSecondary),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const KeyVaultScreen()),
                    );
                  },
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
              sliver: SliverToBoxAdapter(
                child: _buildMobileTabContent(),
              ),
            ),
          ],
        ),

        // Floating Bottom Navigation
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: MobileBottomNav(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTabContent() {
    switch (_selectedIndex) {
      case 1:
        return const AiSchedulerWidget();
      case 2:
        return const FoodVisionCard();
      case 3:
        return const DualLayerJournalWidget();
      case 4:
        return const HydrationTrackerWidget();
      case 0:
      default:
        return const Column(
          children: [
            AiSchedulerWidget(),
            SizedBox(height: 16),
            DualLayerJournalWidget(),
            SizedBox(height: 16),
            FoodVisionCard(),
            SizedBox(height: 16),
            HydrationTrackerWidget(),
          ],
        );
    }
  }
}
