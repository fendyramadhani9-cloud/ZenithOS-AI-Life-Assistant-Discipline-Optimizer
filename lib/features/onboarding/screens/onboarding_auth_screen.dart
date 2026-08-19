import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/storage/storage_service.dart';
import '../../../services/ai/key_vault_controller.dart';
import '../../../services/ai/models/api_key_entry.dart';
import '../../../services/ai/gemini_service.dart';
import '../../dashboard/screens/main_dashboard_screen.dart';

class OnboardingAuthScreen extends StatefulWidget {
  const OnboardingAuthScreen({super.key});

  @override
  State<OnboardingAuthScreen> createState() => _OnboardingAuthScreenState();
}

class _OnboardingAuthScreenState extends State<OnboardingAuthScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Architect',
  );
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _labelController = TextEditingController(
    text: 'Primary Gemini Key',
  );

  AiProvider _provider = AiProvider.gemini;
  bool _obscureKey = true;
  bool _isValidating = false;
  bool? _testSuccess;
  String? _statusMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _keyController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _validateAndPingKey() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter an API Key to validate.';
        _testSuccess = false;
      });
      return;
    }

    setState(() {
      _isValidating = true;
      _statusMessage = 'Pinging AI model endpoint...';
      _testSuccess = null;
    });

    final gemini = GeminiService(apiKey: key);
    final ok = await gemini.ping(key);

    setState(() {
      _isValidating = false;
      _testSuccess = ok;
      _statusMessage = ok
          ? 'Validation Successful! Key is active and authorized.'
          : 'Failed to connect. Please verify your API key.';
    });
  }

  Future<void> _completeOnboarding() async {
    final name = _nameController.text.trim();
    final key = _keyController.text.trim();

    if (name.isNotEmpty) {
      await StorageService.instance.saveUserName(name);
    }

    if (key.isNotEmpty) {
      await KeyVaultController.instance.addKey(
        label: _labelController.text.trim(),
        key: key,
        provider: _provider,
        setAsActive: true,
      );
      await StorageService.instance.saveApiKey(key);
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainDashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ZenithOS Logo & Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.accentPrimary,
                            AppColors.accentSecondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        LucideIcons.terminal,
                        color: Color(0xFF0A0D14),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ZenithOS', style: AppTypography.h1),
                        Text(
                          'Life Assistant & Discipline Optimizer',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 20),

                // Name Input
                Text('User Designation', style: AppTypography.caption),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  style: AppTypography.body,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      LucideIcons.user,
                      size: 16,
                      color: AppColors.accentPrimary,
                    ),
                    hintText: 'e.g. Lead Architect, Alex',
                  ),
                ),
                const SizedBox(height: 18),

                // Provider Choice
                Text('AI Provider (BYOK Engine)', style: AppTypography.caption),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Google Gemini (Recommended)'),
                      selected: _provider == AiProvider.gemini,
                      onSelected: (val) =>
                          setState(() => _provider = AiProvider.gemini),
                      selectedColor: AppColors.accentPrimary.withOpacity(0.2),
                      backgroundColor: AppColors.surfaceLight,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('OpenAI'),
                      selected: _provider == AiProvider.openAi,
                      onSelected: (val) =>
                          setState(() => _provider = AiProvider.openAi),
                      selectedColor: AppColors.accentSecondary.withOpacity(0.2),
                      backgroundColor: AppColors.surfaceLight,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // API Key Field
                Text('API Key', style: AppTypography.caption),
                const SizedBox(height: 6),
                TextField(
                  controller: _keyController,
                  obscureText: _obscureKey,
                  style: AppTypography.metricSmall,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      LucideIcons.keyRound,
                      size: 16,
                      color: AppColors.accentPrimary,
                    ),
                    hintText: 'Paste Gemini or OpenAI API Key...',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureKey ? LucideIcons.eyeOff : LucideIcons.eye,
                        size: 16,
                      ),
                      onPressed: () =>
                          setState(() => _obscureKey = !_obscureKey),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Validator & Google AI Studio link
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _isValidating ? null : _validateAndPingKey,
                      icon: _isValidating
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              LucideIcons.activity,
                              size: 14,
                              color: AppColors.accentPrimary,
                            ),
                      label: Text(
                        _isValidating ? 'Testing...' : 'Test Connection',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.accentPrimary,
                        ),
                      ),
                    ),
                    Text(
                      'Encrypted via SecureStorage',
                      style: AppTypography.caption.copyWith(fontSize: 10),
                    ),
                  ],
                ),

                if (_statusMessage != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          (_testSuccess == true
                                  ? AppColors.nutritionAccent
                                  : AppColors.warningCutoff)
                              .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            (_testSuccess == true
                                    ? AppColors.nutritionAccent
                                    : AppColors.warningCutoff)
                                .withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _testSuccess == true
                              ? LucideIcons.shieldCheck
                              : LucideIcons.alertCircle,
                          size: 16,
                          color: _testSuccess == true
                              ? AppColors.nutritionAccent
                              : AppColors.warningCutoff,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _statusMessage!,
                            style: AppTypography.caption.copyWith(
                              color: _testSuccess == true
                                  ? AppColors.nutritionAccent
                                  : AppColors.warningCutoff,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Enter ZenithOS Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: _completeOnboarding,
                    icon: const Icon(LucideIcons.arrowRight, size: 16),
                    label: const Text('Initialize ZenithOS'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
