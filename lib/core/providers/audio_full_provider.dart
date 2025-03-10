import 'package:audioplayers/audioplayers.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
// import 'package:quranku_offline/core/providers/connectivity_provider.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';
// import 'package:quranku_offline/main.dart';

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

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  AudioFullPlayerNotifier(this.ref) : super(0) {
    _audioPlayer.onPlayerComplete.listen((event) {
      nextSurah();
    });
    _initNotifications();
  }

  // ✅ Inisialisasi Notifikasi
  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings,
        onDidReceiveNotificationResponse: (response) {
      if (response.payload == "pause") {
        pauseAudio();
      } else if (response.payload == "next") {
        nextSurah();
      } else if (response.payload == "previous") {
        previousSurah();
      }
    });

    // ✅ Minta izin notifikasi Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ✅ Menampilkan Notifikasi
  Future<void> _showNotification(String title, String subtitle) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'audio_channel', // ✅ Gunakan channelId yang sama dengan yang dibuat sebelumnya
      'Quran Audio Playback',
      channelDescription: 'Memutar audio surah Quran',
      importance: Importance.high,
      priority: Priority.high,
      playSound: false,
      enableVibration: false,
      ongoing: true,
      styleInformation: BigTextStyleInformation(''),
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: Colors.teal,
      actions: [
        AndroidNotificationAction('previous', '⏮ Sebelumnya',
            showsUserInterface: true),
        AndroidNotificationAction('play_pause', '⏯ Play/Pause',
            showsUserInterface: true),
        AndroidNotificationAction('next', '⏭ Selanjutnya',
            showsUserInterface: true),
      ],
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    _notifications.show(
      0,
      title,
      subtitle,
      details,
      payload: "play", // ✅ Tambahkan payload untuk Play/Pause
    );
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

          _showNotification(
            surah.namaLatin,
            "Sedang diputar...",
          );
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
    _showNotification("Audio Dijeda", "Ketuk untuk melanjutkan");
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    ref.read(isPlayingAudioProvider.notifier).state = false;
    ref.read(isLoadingAudioProvider.notifier).state = false;
    _notifications.cancel(0);
  }

  Future<void> nextSurah() async {
    final surahList = ref.read(quranProvider);
    if (state + 1 < surahList.length) {
      playSurah(state + 1);
    } else {
      ref.read(isPlayingAudioProvider.notifier).state = false;
    }
  }

  Future<void> previousSurah() async {
    if (state - 1 >= 0) {
      playSurah(state - 1);
    }
  }
}
