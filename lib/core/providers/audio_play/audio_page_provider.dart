// import 'dart:io';

// import 'package:audio_service/audio_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:logger/logger.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:quranku_offline/core/providers/audio_storage_provider.dart';
// import 'package:quranku_offline/core/providers/quran_provider.dart';
// import 'package:quranku_offline/core/services/audio_handler.dart';
// import 'package:quranku_offline/core/services/audio_service.dart';  
// import 'package:http/http.dart' as http;

// final audioPageProvider = StateNotifierProvider<AudioPageNotifier, int>(
//   (ref) => AudioPageNotifier(ref),
// );

// class AudioPageNotifier extends StateNotifier<int> {
//   final Ref ref;
//   final AudioService _audioService = AudioService();

//   final isLoadingAudioProvider = StateProvider<bool>((ref) => false);
//   final isPlayingAudioProvider = StateProvider<bool>((ref) => false);
//   final audioFullErrorProvider = StateProvider<String?>((ref) => null);

//   AudioPageNotifier(super.state, this.ref);

//  Future<void> playSurah(BuildContext context, WidgetRef ref, int index) async {
//   ref.read(isLoadingAudioProvider.notifier).state = true;

//   final surahList = ref.read(quranProvider);
//   if (index >= 0 && index < surahList.length) {
//     final surah = surahList[index];
//     final audioUrl = surah.audioFull['04'];

//     if (audioUrl != null) {
//       try {
//         final File? file = await _downloadMp3(context, surah.nomor.toString(), audioUrl);
//         if (file != null) {
//           final audioHandler = ref.read(audioHandlerProvider);
//           await audioHandler.playAudio(file, "${surah.namaLatin}: ${surah.nomor}");

//           ref.read(isLoadingAudioProvider.notifier).state = false;
//           ref.read(isPlayingAudioProvider.notifier).state = true;
//         } else {
//           throw "Gagal mengunduh audio.";
//         }
//       } catch (e) {
//         ref.read(audioFullErrorProvider.notifier).state = "Gagal memutar audio: $e";
//         Logger().e("Error saat memutar audio: $e");
//       }
//     } else {
//       ref.read(isLoadingAudioProvider.notifier).state = false;
//     }
//   }
// }

//   Future<File?> _downloadMp3(
//       BuildContext context, String surahNumber, String audioUrl) async {
//     // final connectivity = await Connectivity().checkConnectivity();

//     ref.read(downloadedSizeProvider.notifier).updateSize();

//     // if (connectivity.contains(ConnectivityResult.none)) {
//     //   _showSnackbar(context, "❌ Tidak ada koneksi internet!", isError: true);
//     //   return null;
//     // }

//     final directory = await getApplicationDocumentsDirectory();
//     final filePath = "${directory.path}/surah_$surahNumber.mp3";
//     final file = File(filePath);

//     if (await file.exists()) {
//       // _showSnackbar(context, "Audio diputar.");
//       return file;
//     }

//     int retryCount = 0;
//     while (retryCount < 3) {
//       try {
//         Logger().i("⬇ Mengunduh audio...");
//         final response = await http.get(Uri.parse(audioUrl));
//         _showSnackbar(context, "Mengunduh audio di latar belakang...");

//         if (response.statusCode == 200) {
//           await file.writeAsBytes(response.bodyBytes);
//           _showSnackbar(context, "Download selesai..");

//           // ✅ Update total ukuran file setelah download selesai
//           ref.read(downloadedSizeProvider.notifier).updateSize();

//           return file;
//         } else {
//           retryCount++;
//           if (retryCount == 3) {
//             _showSnackbar(context,
//                 "❌ Gagal mengunduh audio setelah 3 kali mencoba, cek koneksi internet!",
//                 isError: true);
//             ref.read(isLoadingAudioProvider.notifier).state = false;
//           }
//         }
//       } catch (e) {
//         retryCount++;
//         if (retryCount == 3) {
//           _showSnackbar(context, "❌ Error saat mengunduh: $e", isError: true);
//           ref.read(isLoadingAudioProvider.notifier).state = false;
//           Logger().e("Error saat mengunduh audio: $e");
//         }
//       }
//     }
//     return null;
//   }

//   void _showSnackbar(BuildContext context, String message,
//       {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     );
//   }
// }
