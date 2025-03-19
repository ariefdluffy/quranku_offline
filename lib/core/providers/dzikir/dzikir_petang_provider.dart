import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:quranku_offline/core/models/dzikir_petang_model.dart';

final dzikirPetangProvider =
    StateNotifierProvider<DzikirNotifier, List<DzikirPetang>>((ref) {
  return DzikirNotifier()..loadDzikirPetang();
});

class DzikirNotifier extends StateNotifier<List<DzikirPetang>> {
  DzikirNotifier() : super([]);

  Future<void> loadDzikirPetang() async {
    try {
      final String response =
          await rootBundle.loadString('assets/dzikir_petang.json');
      final List<dynamic> jsonData =
          json.decode(response)['dzikir_petang'] ?? [];
      state = jsonData
          .map((e) => DzikirPetang.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Logger().e("Error loading dzikir: $e");
    }
  }
}
