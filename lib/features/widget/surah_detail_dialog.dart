import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranku_offline/core/models/surah_model.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';

class SurahDetailDialog extends ConsumerWidget {
  final Surah surah;

  const SurahDetailDialog({super.key, required this.surah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayer = ref.watch(audioPlayerProvider.notifier);
    final isPlaying = ref.watch(isPlayingProvider);

    // 🔹 Pastikan ada audio untuk surah ini
    String? audioUrl = surah.audioFull['04']; // Pilih Qari tertentu

    // 🔹 Tambahkan listener agar ikon berubah saat audio selesai
    ref.read(audioPlayerProvider).onPlayerComplete.listen((event) {
      ref.read(isPlayingProvider.notifier).state = false;
    });

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${surah.namaLatin}: ${surah.nomor}",
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
          InkWell(
            onTap: () {
              audioPlayer.stopAudio(ref);
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.redAccent,
                size: 26,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            surah.nama,
            style: GoogleFonts.amiri(
                fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const SizedBox(height: 5),
          _buildDetailRow("Jumlah Ayat", "${surah.jumlahAyat} ayat"),
          _buildDetailRow("Tempat Turun", surah.tempatTurun),
          _buildDetailRow("Arti", surah.arti),
          const Divider(thickness: 1, color: Colors.teal),
          Text(
            surah.deskripsi
                .replaceAll(RegExp(r'<[^>]*>'), ''), // 🔹 Hilangkan tag HTML
            textAlign: TextAlign.justify,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  // 🔹 Widget untuk Baris Detail
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black)),
          Text(value, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
