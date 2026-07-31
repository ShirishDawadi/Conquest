import 'dart:developer';
import 'dart:io';
import 'package:conquest/core/utils/connectivity_utils.dart';
import 'package:conquest/data/sources/local/object_image_local_source.dart';
import 'package:conquest/data/sources/remote/object_image_remote_source.dart';
import 'package:conquest/presentation/viewmodels/quest_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CaptureSyncService {
  final _captureLocalSource = ObjectImageLocalSource();
  final _objectImageSource = ObjectImageRemoteSource();

  Future<void> syncPending(WidgetRef ref) async {
    if (!await ConnectivityUtils.isOnline()) return;

    final pending = await _captureLocalSource.getPending();
    if (pending.isEmpty) return;

    bool anySynced = false;

    for (final row in pending) {
      final id = row['id'] as int;
      final questId = row['quest_id'] as int?;
      final objectId = row['object_id'] as int;
      final imagePath = row['image_path'] as String;
      final latitude = row['latitude'] as double?;
      final longitude = row['longitude'] as double?;

      final file = File(imagePath);
      if (!await file.exists() || questId == null) {
        await _captureLocalSource.deleteCapture(id);
        continue;
      }

      try {
        final bytes = await file.readAsBytes();
        await _objectImageSource.uploadObjectImage(
          questId: questId,
          objectId: objectId,
          latitude: latitude,
          longitude: longitude,
          imageBytes: bytes,
        );
        await _captureLocalSource.deleteCapture(id);
        await file.delete();
        anySynced = true;
      } catch (e) {
        log('Sync failed for capture $id: $e', name: 'CaptureSync');
      }
    }

    if (anySynced) {
      ref.invalidate(questProvider);
    }
  }
}