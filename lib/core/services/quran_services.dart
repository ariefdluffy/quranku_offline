import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:quranku_offline/core/models/ayah_model.dart';
import '../models/surah_model.dart';

class QuranService {
  Future<List<Surah>> fetchAllSurah() async {
    List<Surah> allSurahList = [];

    for (int i = 1; i <= 114; i++) {
      String filePath = 'assets/surah/$i.json';
      try {
        final String response = await rootBundle.loadString(filePath);
        final Map<String, dynamic> jsonData = json.decode(response);

        // Tambahkan surah ke daftar
        allSurahList.add(Surah.fromJson(jsonData));
      } catch (e) {
        print("Gagal membaca $filePath: $e");
      }
    }

    return allSurahList;
  }

  Future<List<Ayah>> fetchAllAyah() async {
    List<Ayah> allAyahList = [];

    for (int i = 1; i <= 114; i++) {
      String filePath = 'assets/surah/$i.json';
      try {
        final String response = await rootBundle.loadString(filePath);
        final Map<String, dynamic> jsonData = json.decode(response);
        // int surahNamaLatin = jsonData['namaLatin'];

        List<Ayah> ayatList =
            (jsonData['ayat'] as List).map((e) => Ayah.fromJson(e)).toList();

        allAyahList.addAll(ayatList);
      } catch (e) {
        print("Gagal membaca $filePath: $e");
      }
    }

    return allAyahList;
  }
}
