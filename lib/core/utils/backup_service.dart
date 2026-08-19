import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../storage/storage_service.dart';

class BackupService {
  /// Generate JSON string backup
  static String generateBackupJson() {
    final data = StorageService.instance.exportFullBackup();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Get formatted backup filename
  static String getBackupFilename() {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return 'zenith_backup_$timestamp.json';
  }

  /// Restore from picked file
  static Future<bool> pickAndRestoreBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        Uint8List? bytes = file.bytes;
        
        if (bytes != null) {
          final jsonString = utf8.decode(bytes);
          final map = jsonDecode(jsonString) as Map<String, dynamic>;
          await StorageService.instance.restoreBackup(map);
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('[BackupService] Restore failed: $e');
      return false;
    }
  }
}
