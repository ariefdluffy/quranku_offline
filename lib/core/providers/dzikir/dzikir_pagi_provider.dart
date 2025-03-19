import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:quranku_offline/core/models/dzikir_pagi_model.dart';

final dzikirProvider =
    StateNotifierProvider<DzikirNotifier, List<DzikirPagi>>((ref) {
  return DzikirNotifier()..loadDzikir();
});

class DzikirNotifier extends StateNotifier<List<DzikirPagi>> {
  DzikirNotifier() : super([]);

  Future<void> loadDzikir() async {
    try {
      final String response =
          await rootBundle.loadString('assets/dzikir_pagi.json');
      final List<dynamic> jsonData = json.decode(response)['dzikir_pagi'] ?? [];
      state = jsonData
          .map((e) => DzikirPagi.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Logger().e("Error loading dzikir: $e");
    }
  }
}
