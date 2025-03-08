import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';

final audioFullPlayerProvider =
    StateNotifierProvider<AudioFullPlayerNotifier, int>(
  (ref) => AudioFullPlayerNotifier(ref),
);

final isLoadingAudioProvider = StateProvider<bool>((ref) => false);
final isPlayingAudioProvider = StateProvider<bool>((ref) => false);
final audioFullErrorProvider = StateProvider<String?>((ref) => null);

class AudioFullPlayerNotifier extends StateNotifier<int> {
  final Ref ref;
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioFullPlayerNotifier(this.ref) : super(0) {
    _audioPlayer.onPlayerComplete.listen((event) {
      nextSurah();
    });
  }

  Future<void> playSurah(int index) async {
    ref.read(isLoadingAudioProvider.notifier).state =
        true; // ✅ Aktifkan loading

    final surahList = ref.read(quranProvider);
    if (index >= 0 && index < surahList.length) {
      state = index;
      final surah = surahList[index];
      final audioUrl =
          surah.audioFull['04']; // Pilih Qari ke-4 (Bisa disesuaikan)

      if (audioUrl != null) {
        // await _audioPlayer.stop();
        try {
          await _audioPlayer.play(UrlSource(audioUrl));
          ref.read(isLoadingAudioProvider.notifier).state =
              false; // ✅ Audio sedang diputar
          ref.read(isPlayingAudioProvider.notifier).state = true;
        } catch (e) {
          ref.read(audioFullErrorProvider.notifier).state =
              "Gagal memutar audio: $e"; // ✅ Simpan pesan error
          Logger().e("Error saat memutar audio: $e");
        }
      }
    }
  }

  // ✅ Fungsi untuk memilih surah tanpa langsung memutarnya
  void setSurah(int index) {
    state = index;
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
    ref.read(isPlayingAudioProvider.notifier).state = false;
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    ref.read(isPlayingAudioProvider.notifier).state = false;
    ref.read(isLoadingAudioProvider.notifier).state = false;
  }

  Future<void> nextSurah() async {
    final surahList = ref.read(quranProvider);
    if (state + 1 < surahList.length) {
      playSurah(state + 1);
    }
  }

  Future<void> previousSurah() async {
    if (state - 1 >= 0) {
      playSurah(state - 1);
    }
  }
}
