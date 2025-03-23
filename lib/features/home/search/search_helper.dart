import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranku_offline/core/models/surah_model.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';
import 'package:quranku_offline/features/surah/surah_page.dart';
import 'package:quranku_offline/features/surah/surah_page_new.dart';

class SearchHelper {
  static void searchSurah(
    BuildContext context,
    WidgetRef ref,
    String surahName,
    String ayahNumber,
    void Function(String?) updateError,
  ) {
    final surahList = ref.read(quranProvider);
    int? ayahNum = int.tryParse(ayahNumber);

    final surah = surahList.firstWhere(
      (s) =>
          s.namaLatin.toLowerCase() == surahName.toLowerCase() ||
          s.nama.toLowerCase() == surahName.toLowerCase(),
      orElse: () => Surah(
          nomor: -1,
          nama: "",
          namaLatin: "",
          jumlahAyat: 0,
          tempatTurun: "",
          arti: "",
          deskripsi: "",
          ayat: [],
          audioFull: {"default": "04"}),
    );

    if (surah.nomor != -1) {
      // ✅ Cek apakah nomor ayat valid
      if (ayahNum != null && (ayahNum < 1 || ayahNum > surah.jumlahAyat)) {
        updateError(
            "Nomor ayat tidak ditemukan dalam Surah ${surah.namaLatin}");
        return;
      }

      updateError(null); // ✅ Hapus error jika pencarian berhasil
      Navigator.pop(context); // ✅ Tutup dialog
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SurahPageNew(
            surah: surah,
            targetAyah: ayahNum,
          ),
        ),
      );
    } else {
      updateError("Surah tidak ditemukan!"); // ✅ Tampilkan error
    }
  }
}
