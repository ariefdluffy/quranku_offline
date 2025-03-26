import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:quranku_offline/core/models/ayah_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/surah_model.dart';

class QuranService {
  // Future<List<Surah>> fetchAllSurah() async {
  //   List<Surah> allSurahList = [];

  //   for (int i = 1; i <= 114; i++) {
  //     String filePath = 'assets/surah/$i.json';
  //     try {
  //       final String response = await rootBundle.loadString(filePath);
  //       final Map<String, dynamic> jsonData = json.decode(response);

  //       // Tambahkan surah ke daftar
  //       allSurahList.add(Surah.fromJson(jsonData));
  //     } catch (e) {
  //       Logger().e("Gagal membaca $filePath: $e");
  //     }
  //   }

  //   return allSurahList;
  // }

  // ✅ Memuat data dari cache jika tersedia, jika tidak, baca dari assets
  Future<List<Surah>> getAllSurah() async {
    List<Surah> surahList = await loadCachedSurah();

    if (surahList.isNotEmpty) {
      return surahList;
    } else {
      surahList = await fetchAllSurah();
      await cacheSurahData(surahList); // Simpan ke cache setelah load pertama
      return surahList;
    }
  }

  Future<List<Surah>> fetchAllSurah() async {
    List<Future<String>> futures = [];

    for (int i = 1; i <= 114; i++) {
      String filePath = 'assets/surah/$i.json';
      futures.add(rootBundle.loadString(filePath));
    }

    List<String> responses = await Future.wait(futures);
    return compute(parseSurahJson, responses);
  }

  List<Surah> parseSurahJson(List<String> responses) {
    return responses.map((response) {
      final Map<String, dynamic> jsonData = jsonDecode(response);
      return Surah.fromJson(jsonData);
    }).toList();
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
        Logger().e("Gagal membaca $filePath: $e");
      }
    }

    return allAyahList;
  }

  Future<void> cacheSurahData(List<Surah> surahList) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(surahList.map((e) => e.toJson()).toList());
    await prefs.setString('cached_surah', jsonString);
    Logger().i('Data surah telah dicache');
  }

  Future<List<Surah>> loadCachedSurah() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cached_surah');
    Logger().i("cached_surah: $jsonString");

    if (jsonString != null) {
      final List<dynamic> jsonData = jsonDecode(jsonString);
      return jsonData.map((e) => Surah.fromJson(e)).toList();
    }
    return [];
  }
}
