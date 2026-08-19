import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/backup_service.dart';
import '../../../services/ai/key_vault_controller.dart';
import '../../../services/ai/models/api_key_entry.dart';

class KeyVaultScreen extends StatefulWidget {
  const KeyVaultScreen({super.key});

  @override
  State<KeyVaultScreen> createState() => _KeyVaultScreenState();
}

class _KeyVaultScreenState extends State<KeyVaultScreen> {
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  AiProvider _selectedProvider = AiProvider.gemini;
  bool _obscureKey = true;

  @override
  void dispose() {
    _labelController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  void _showAddKeyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.border),
          ),
          title: Row(
            children: [
              const Icon(
                LucideIcons.keyRound,
                color: AppColors.accentPrimary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text('Add API Key to Pool', style: AppTypography.h3),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Provider', style: AppTypography.caption),
              const SizedBox(height: 6),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Google Gemini'),
                    selected: _selectedProvider == AiProvider.gemini,
                    onSelected: (val) {
                      if (val)
                        setDialogState(
                          () => _selectedProvider = AiProvider.gemini,
                        );
                    },
                    selectedColor: AppColors.accentPrimary.withOpacity(0.2),
                    backgroundColor: AppColors.surfaceLight,
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('OpenAI GPT'),
                    selected: _selectedProvider == AiProvider.openAi,
                    onSelected: (val) {
                      if (val)
                        setDialogState(
                          () => _selectedProvider = AiProvider.openAi,
                        );
                    },
                    selectedColor: AppColors.accentSecondary.withOpacity(0.2),
                    backgroundColor: AppColors.surfaceLight,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _labelController,
                style: AppTypography.body,
                decoration: const InputDecoration(
                  labelText: 'Key Label (e.g. Primary Gemini Flash)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _keyController,
                obscureText: _obscureKey,
                style: AppTypography.metricSmall,
                decoration: InputDecoration(
                  labelText: 'API Key (Encrypted in Vault)',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureKey ? LucideIcons.eyeOff : LucideIcons.eye,
                      size: 16,
                    ),
                    onPressed: () =>
                        setDialogState(() => _obscureKey = !_obscureKey),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final key = _keyController.text.trim();
                if (key.isNotEmpty) {
                  await KeyVaultController.instance.addKey(
                    label: _labelController.text.trim(),
                    key: key,
                    provider: _selectedProvider,
                  );
                  _labelController.clear();
                  _keyController.clear();
                  if (context.mounted) Navigator.pop(ctx);
                  setState(() {});
                }
              },
              child: const Text('Save to Vault'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBackup() async {
    final jsonStr = BackupService.generateBackupJson();
    final filename = BackupService.getBackupFilename();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        content: Text(
          'Generated backup $filename (${jsonStr.length} bytes)',
          style: AppTypography.body,
        ),
      ),
    );
  }

  Future<void> _handleRestore() async {
    final success = await BackupService.pickAndRestoreBackup();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: success
              ? AppColors.surface
              : AppColors.warningCutoff,
          content: Text(
            success
                ? 'Database successfully restored from JSON.'
                : 'Restore cancelled or invalid format.',
            style: AppTypography.body,
          ),
        ),
      );
      if (success) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final keys = KeyVaultController.instance.keyPool;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Row(
          children: [
            const Icon(
              LucideIcons.shieldCheck,
              color: AppColors.accentPrimary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text('Key Vault & System Control', style: AppTypography.h2),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resilient Key Pool Card
            Container(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.keyRound,
                            color: AppColors.accentPrimary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'AI Key Pool & Auto-Failover',
                            style: AppTypography.h3,
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddKeyDialog,
                        icon: const Icon(LucideIcons.plus, size: 14),
                        label: const Text('Add Key'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Configured keys rotate automatically on 429 quota or network timeout errors.',
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 16),

                  if (keys.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'No keys configured. Add your first key to activate AI.',
                          style: AppTypography.caption,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: keys.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final k = keys[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: k.isActive
                                  ? AppColors.accentPrimary
                                  : AppColors.border,
                              width: k.isActive ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: k.provider == AiProvider.gemini
                                      ? AppColors.accentPrimary.withOpacity(
                                          0.12,
                                        )
                                      : AppColors.accentSecondary.withOpacity(
                                          0.12,
                                        ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  k.provider == AiProvider.gemini
                                      ? LucideIcons.sparkles
                                      : LucideIcons.cpu,
                                  size: 14,
                                  color: k.provider == AiProvider.gemini
                                      ? AppColors.accentPrimary
                                      : AppColors.accentSecondary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          k.label,
                                          style: AppTypography.body.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (k.isActive) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.nutritionAccent
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'ACTIVE',
                                              style: AppTypography.caption
                                                  .copyWith(
                                                    color: AppColors
                                                        .nutritionAccent,
                                                    fontSize: 9,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${k.provider.name.toUpperCase()} • ${k.maskedKey} • ${k.requestCount} requests',
                                      style: AppTypography.caption,
                                    ),
                                    if (k.lastError != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'Failover notice: ${k.lastError}',
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.warningCutoff,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (!k.isActive)
                                TextButton(
                                  onPressed: () async {
                                    await KeyVaultController.instance
                                        .setActiveKey(k.id);
                                    setState(() {});
                                  },
                                  child: const Text('Set Active'),
                                ),
                              IconButton(
                                icon: const Icon(
                                  LucideIcons.trash2,
                                  size: 16,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: () async {
                                  await KeyVaultController.instance.removeKey(
                                    k.id,
                                  );
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Local JSON Backup & Vault Export
            Container(
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
                      const Icon(
                        LucideIcons.database,
                        color: AppColors.nutritionAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Offline Data Vault & Backups',
                        style: AppTypography.h3,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Export all journal entries, meal vision records, hydration logs and schedules to local JSON file.',
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _handleBackup,
                        icon: const Icon(LucideIcons.downloadCloud, size: 16),
                        label: const Text('Export Backup JSON'),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: _handleRestore,
                        icon: const Icon(LucideIcons.uploadCloud, size: 16),
                        label: const Text('Restore from JSON'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
