import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:quranku_offline/core/models/ayah_model.dart';
import 'package:quranku_offline/core/services/quran_services.dart';
import '../models/surah_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranNotifier extends StateNotifier<List<Surah>> {
  QuranNotifier() : super([]) {
    loadAllSurah();
  }

  Future<void> loadAllSurah() async {
    try {
      final service = QuranService();
      state = await service.fetchAllSurah();
    } catch (e) {
      Logger().e("Error loading Quran data: $e");
    }
  }
}

final quranProvider = StateNotifierProvider<QuranNotifier, List<Surah>>((ref) {
  return QuranNotifier();
});

class QuranPaginationNotifier extends StateNotifier<int> {
  QuranPaginationNotifier() : super(0); // Halaman awal = 0

  void nextPage(int totalPages) {
    if (state < totalPages - 1) {
      state++;
    }
  }

  void previousPage() {
    if (state > 0) {
      state--;
    }
  }

  // 🔹 Tambahkan fungsi ini agar bisa loncat ke halaman tertentu
  void jumpToPage(int pageIndex) {
    state = pageIndex;
  }
}

final quranPaginationProvider =
    StateNotifierProvider<QuranPaginationNotifier, int>((ref) {
  return QuranPaginationNotifier();
});

class AllAyahNotifier extends StateNotifier<List<Ayah>> {
  AllAyahNotifier() : super([]) {
    loadAllAyah();
  }

  Future<void> loadAllAyah() async {
    try {
      final service = QuranService();
      state = await service.fetchAllAyah();
    } catch (e) {
      Logger().e("Error loading all ayah data: $e");
    }
  }
}

final allAyahProvider =
    StateNotifierProvider<AllAyahNotifier, List<Ayah>>((ref) {
  return AllAyahNotifier();
});

class BookmarkNotifier extends StateNotifier<List<Ayah>> {
  BookmarkNotifier() : super([]) {
    _loadBookmarks(); // Load bookmark saat pertama kali aplikasi dibuka
  }

  // 🔹 Load Bookmark dari SharedPreferences
  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? bookmarksJson = prefs.getString('bookmarks');

    if (bookmarksJson != null) {
      List<dynamic> decodedData = jsonDecode(bookmarksJson);
      state = decodedData
          .map((item) => Ayah.fromJson(
                item,
              ))
          .toList();
    }
  }

  // 🔹 Simpan Bookmark ke SharedPreferences
  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final String bookmarksJson =
        jsonEncode(state.map((ayah) => ayah.toJson()).toList());
    await prefs.setString('bookmarks', bookmarksJson);
  }

  void addBookmark(Ayah ayah) {
    if (!state.contains(ayah)) {
      state = [...state, ayah]; // Tambah bookmark baru
      _saveBookmarks(); // Simpan ke SharedPreferences
    }
  }

  void removeBookmark(Ayah ayah) {
    state = state.where((item) => item != ayah).toList(); // Hapus bookmark
    _saveBookmarks(); // Simpan perubahan ke SharedPreferences
  }
}

final bookmarkProvider = StateNotifierProvider<BookmarkNotifier, List<Ayah>>(
  (ref) => BookmarkNotifier(),
);

// Provider untuk mengontrol state loading
final isLoadingProvider = StateProvider<bool>((ref) => false);

class ScrollControllerNotifier extends StateNotifier<ScrollController> {
  ScrollControllerNotifier() : super(ScrollController());

  void scrollToTop() {
    state.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void scrollToBottom() {
    state.animateTo(
      state.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }
}

final scrollControllerProvider =
    StateNotifierProvider<ScrollControllerNotifier, ScrollController>(
  (ref) => ScrollControllerNotifier(),
);

class FabVisibilityNotifier extends StateNotifier<bool> {
  FabVisibilityNotifier() : super(false);

  void updateVisibility(ScrollController controller) {
    if (!controller.hasClients) return;

    bool isScrollable = controller.position.maxScrollExtent > 0;
    if (state != isScrollable) {
      state = isScrollable;
    }
  }
}

final fabVisibilityProvider =
    StateNotifierProvider<FabVisibilityNotifier, bool>(
  (ref) => FabVisibilityNotifier(),
);

// ✅ Notifier untuk memantau apakah FAB harus menunjukkan ikon atas atau bawah
class FabIconNotifier extends StateNotifier<bool> {
  FabIconNotifier() : super(true);

  void updateIcon(ScrollController controller) {
    if (!controller.hasClients) return;

    bool isAtBottom =
        controller.position.pixels >= controller.position.maxScrollExtent - 50;
    if (state != isAtBottom) {
      state = isAtBottom;
    }
  }
}

final fabIconProvider = StateNotifierProvider<FabIconNotifier, bool>(
  (ref) => FabIconNotifier(),
);

class AudioPlayerNotifier extends StateNotifier<AudioPlayer> {
  AudioPlayerNotifier(Ref ref) : super(AudioPlayer()) {
    _initListener();

    // 🔹 Hentikan audio saat provider dihentikan
    ref.onDispose(() {
      state.stop();
    });
  }

  void _initListener() {
    state.onPlayerComplete.listen((event) {
      state.stop(); // Hentikan audio setelah selesai
    });
  }

  final audioErrorProvider = StateProvider<String?>((ref) => null);

  Future<void> playAudio(String url, WidgetRef ref) async {
    ref.read(isLoadingAudioProvider.notifier).state =
        true; // ✅ Aktifkan loading
    ref.read(audioErrorProvider.notifier).state = null; // ✅ Reset pesan error

    try {
      // await state.stop();
      await state.play(UrlSource(url)).timeout(const Duration(seconds: 20));
      ref.read(isPlayingProvider.notifier).state = true;
    } on TimeoutException {
      ref.read(audioErrorProvider.notifier).state =
          "Koneksi timeout. Coba lagi.";
    } catch (e) {
      ref.read(audioErrorProvider.notifier).state =
          "Gagal memutar audio: $e"; // ✅ Simpan pesan error
      Logger().e("Error saat memutar audio: $e");
    } finally {
      ref.read(isLoadingAudioProvider.notifier).state =
          false; // ✅ Matikan loading setelah selesai
    }
  }

  Future<void> pauseAudio(WidgetRef ref) async {
    await state.pause();
    ref.read(isPlayingProvider.notifier).state = false;
  }

  Future<void> stopAudio(WidgetRef ref) async {
    await state.stop();
    ref.read(isPlayingProvider.notifier).state = false;
  }
}

final isLoadingAudioProvider = StateProvider<bool>((ref) => false);

final isPlayingProvider = StateProvider<bool>((ref) => false);

final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayer>(
  (ref) => AudioPlayerNotifier(ref),
);

final selectedSurahProvider =
    FutureProvider.family<Surah, int>((ref, nomorSurah) async {
  final surahList = ref.watch(quranProvider);
  await Future.delayed(const Duration(milliseconds: 800)); // 🔹 Simulasi load
  return surahList.firstWhere((surah) => surah.nomor == nomorSurah);
});

final futureSurahProvider =
    FutureProvider.family<List<Ayah>, Surah>((ref, surah) async {
  await Future.delayed(const Duration(seconds: 2)); // ✅ Simulasi delay loading
  return surah.ayat; // ✅ Kembalikan daftar ayat
});
