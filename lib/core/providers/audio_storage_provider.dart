import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final downloadedSizeProvider =
    StateNotifierProvider<DownloadedSizeNotifier, String>(
  (ref) => DownloadedSizeNotifier(),
);

class DownloadedSizeNotifier extends StateNotifier<String> {
  DownloadedSizeNotifier() : super("0 MB") {
    _calculateTotalSize();
  }

  Future<void> _calculateTotalSize() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync();
    int totalSize = 0;

    for (var file in files) {
      if (file is File && file.path.endsWith(".mp3")) {
        totalSize += await file.length();
      }
    }

    state = _formatSize(totalSize);
  }

  void updateSize() {
    _calculateTotalSize();
  }

  String _formatSize(int bytes) {
    double sizeInMb = bytes / (1024 * 1024);
    return "${sizeInMb.toStringAsFixed(2)} MB";
  }
}

// ✅ Fungsi untuk menghapus semua file surah (MP3)
Future<void> deleteAllSurahFiles(BuildContext context, WidgetRef ref) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync();

    for (var file in files) {
      if (file is File && file.path.endsWith(".mp3")) {
        await file.delete();
      }
    }

    // ✅ Perbarui ukuran total storage setelah penghapusan
    ref.read(downloadedSizeProvider.notifier).updateSize();

    // ✅ Tampilkan Snackbar jika berhasil dihapus
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Semua file surah telah dihapus"),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("❌ Gagal menghapus file: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
}
