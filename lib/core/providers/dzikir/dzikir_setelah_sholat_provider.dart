import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:quranku_offline/core/models/dzikir_setelah_sholat.dart';

final dzikirSetelahSholatProvider =
    StateNotifierProvider<DzikirNotifier, List<DzikirSetelahSholat>>((ref) {
  return DzikirNotifier()..loadDzikirSetelahSholat();
});

class DzikirNotifier extends StateNotifier<List<DzikirSetelahSholat>> {
  DzikirNotifier() : super([]);

  Future<void> loadDzikirSetelahSholat() async {
    try {
      final String response =
          await rootBundle.loadString('assets/dzikir_setelah_sholat.json');
      final List<dynamic> jsonData =
          json.decode(response)['dzikir_setelah_sholat'] ?? [];
      state = jsonData
          .map((e) => DzikirSetelahSholat.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Logger().e("Error loading dzikir setelah sholat: $e");
    }
  }
}
