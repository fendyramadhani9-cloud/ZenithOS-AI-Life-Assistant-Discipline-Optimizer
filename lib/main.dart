import 'package:flutter/material.dart';
import 'core/constants/app_theme.dart';
import 'core/network_queue/offline_queue_service.dart';
import 'core/storage/storage_service.dart';
import 'features/dashboard/screens/main_dashboard_screen.dart';
import 'features/onboarding/screens/onboarding_auth_screen.dart';
import 'services/ai/key_vault_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Offline-first Storage, Key Vault, and Network Queue
  await StorageService.init();
  await KeyVaultController.init();
  await OfflineQueueService.init();

  runApp(const ZenithApp());
}

class ZenithApp extends StatelessWidget {
  const ZenithApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if BYOK Key Vault already has a configured key
    final hasKey = KeyVaultController.instance.keyPool.isNotEmpty;

    return MaterialApp(
      title: 'ZenithOS - AI Life Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: hasKey ? const MainDashboardScreen() : const OnboardingAuthScreen(),
    );
  }
}
