import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:share_plus/share_plus.dart';

/// Moves backup files in and out of the app.
abstract interface class BackupFiles {
  /// Offers [json] to the user as [fileName]. Returns false if they cancel.
  Future<bool> export(String json, String fileName);

  /// Lets the user pick a backup and returns its text, or null if they
  /// cancel.
  Future<String?> pick();
}

/// The share sheet for export (it saves to Files or downloads on the web)
/// and the system file picker for import.
final class SystemBackupFiles implements BackupFiles {
  const SystemBackupFiles();

  static const _type = XTypeGroup(
    label: 'Due backup',
    extensions: ['json'],
    mimeTypes: ['application/json'],
    uniformTypeIdentifiers: ['public.json'],
  );

  @override
  Future<bool> export(String json, String fileName) async {
    final file = XFile.fromData(Uint8List.fromList(utf8.encode(json)), mimeType: 'application/json', name: fileName);
    final result = await SharePlus.instance.share(ShareParams(files: [file], fileNameOverrides: [fileName]));
    return result.status != ShareResultStatus.dismissed;
  }

  @override
  Future<String?> pick() async {
    final file = await openFile(acceptedTypeGroups: const [_type]);
    return file?.readAsString();
  }
}
