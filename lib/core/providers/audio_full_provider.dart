import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quranku_offline/core/providers/audio_storage_provider.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';
import 'package:http/http.dart' as http;
// import 'package:quranku_offline/core/services/background_service.dart';
import 'package:workmanager/workmanager.dart';

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

  BuildContext? _context;

  AudioFullPlayerNotifier(this.ref) : super(0) {
    // startBackgroundService();
    _audioPlayer.onPlayerComplete.listen((event) {
      if (_context != null) {
        nextSurah(_context!);
      }
    });
  }

  // void startBackgroundService() {
  //   initializeService();
  // }

  // ✅ Simpan context dari UI agar bisa digunakan di fungsi lain
  void setContext(BuildContext context) {
    _context = context;
    _initNotifications(
        context); // ✅ Pastikan _initNotifications() punya context
  }

  // ✅ Inisialisasi Notifikasi
  Future<void> _initNotifications(BuildContext context) async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings,
        onDidReceiveNotificationResponse: (response) {
      if (response.payload == "pause") {
        pauseAudio();
      } else if (response.payload == "next") {
        nextSurah(context);
      } else if (response.payload == "previous") {
        previousSurah(context);
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

  Future<void> playSurah(BuildContext context, int index) async {
    ref.read(isLoadingAudioProvider.notifier).state =
        true; // ✅ Aktifkan loading

    final surahList = ref.read(quranProvider);
    if (index >= 0 && index < surahList.length) {
      state = index;
      final surah = surahList[index];
      final audioUrl = surah.audioFull['04'];

      if (audioUrl != null) {
        // await _audioPlayer.stop();
        try {
          final File? file =
              await _downloadMp3(context, surah.nomor.toString(), audioUrl);
          if (file != null) {
            await _audioPlayer.play(DeviceFileSource(file.path));

            ref.read(isLoadingAudioProvider.notifier).state = false;
            ref.read(isPlayingAudioProvider.notifier).state = true;

            _showNotification(
              "${surah.namaLatin}: ${surah.nomor}",
              "Sedang diputar...",
            );
          }
          // await _audioPlayer.play(UrlSource(audioUrl));

          // ref.read(isLoadingAudioProvider.notifier).state =
          //     false; // ✅ Audio sedang diputar
          // ref.read(isPlayingAudioProvider.notifier).state = true;

          // _showNotification(
          //   "${surah.namaLatin}: ${surah.nomor}",
          //   "Sedang diputar...",
          // );
        } catch (e) {
          ref.read(audioFullErrorProvider.notifier).state =
              "Gagal memutar audio: $e"; // ✅ Simpan pesan error
          Logger().e("Error saat memutar audio: $e");
        }
      }
    }
  }

  // ✅ Fungsi untuk mengunduh MP3 dengan Retry 3x
  Future<File?> _downloadMp3(
      BuildContext context, String surahNumber, String audioUrl) async {
    final connectivity = await Connectivity().checkConnectivity();
    // ✅ Update total ukuran file setelah download selesai
    ref.read(downloadedSizeProvider.notifier).updateSize();

    if (connectivity == ConnectivityResult.none) {
      _showSnackbar(context, "❌ Tidak ada koneksi internet!", isError: true);
      return null;
    }

    final directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}/surah_$surahNumber.mp3";
    final file = File(filePath);

    if (await file.exists()) {
      // _showSnackbar(context, "✅ Audio sudah di download, langsung dimainkan.");
      return file;
    }

    // _showSnackbar(context, "Mengunduh audio di latar belakang...");

    // await Workmanager().registerOneOffTask(
    //   "download_mp3_task_${DateTime.now().millisecondsSinceEpoch}", // Unique ID untuk task
    //   "download_mp3_task",
    //   inputData: {
    //     "surahNumber": surahNumber,
    //     "audioUrl": audioUrl,
    //   },
    // );

    int retryCount = 0;
    while (retryCount < 3) {
      try {
        Logger().i("⬇ Mengunduh audio...");
        _showSnackbar(context, "Mengunduh audio..");
        final response = await http
            .get(
              Uri.parse(audioUrl),
            )
            .timeout(const Duration(seconds: 10)); // Timeout 10 detik

        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          _showSnackbar(context, "Download selesai..");

          // ✅ Update total ukuran file setelah download selesai
          ref.read(downloadedSizeProvider.notifier).updateSize();

          return file;
        } else {
          retryCount++;
          if (retryCount == 3) {
            _showSnackbar(context,
                "❌ Gagal mengunduh audio setelah 3 kali mencoba, cek koneksi internet!",
                isError: true);
          }
        }
      } catch (e) {
        retryCount++;
        if (retryCount == 3) {
          _showSnackbar(context, "❌ Error saat mengunduh: $e", isError: true);
        }
      }
    }
    return null;
  }

  // ✅ Menampilkan Snackbar
  void _showSnackbar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
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

  Future<void> nextSurah(BuildContext context) async {
    final surahList = ref.read(quranProvider);
    if (state + 1 < surahList.length) {
      // FlutterBackgroundService().invoke("next_surah");

      playSurah(context, state + 1);
    } else {
      ref.read(isPlayingAudioProvider.notifier).state = false;
    }
  }

  Future<void> previousSurah(BuildContext context) async {
    if (state - 1 >= 0) {
      playSurah(context, state - 1);
      ref.read(isPlayingAudioProvider.notifier).state = false;
    }
  }
}
