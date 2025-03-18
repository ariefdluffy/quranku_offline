// import 'dart:async';
// import 'dart:io';
// import 'dart:ui';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:quranku_offline/core/providers/audio_full_provider.dart';

// final AudioPlayer _audioPlayer = AudioPlayer();

// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();

//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       autoStart: true,
//       isForegroundMode: true,
//       notificationChannelId: 'audio_channel',
//       initialNotificationTitle: 'Quran Audio Playback',
//       initialNotificationContent:
//           'Audio Al-Quran Offline akan terus berjalan di latar belakang',
//       foregroundServiceNotificationId: 888,
//     ),
//     iosConfiguration: IosConfiguration(
//       onForeground: onStart,
//       onBackground: onIosBackground,
//     ),
//   );
// }

// void onStart(ServiceInstance service) {
//   if (service is AndroidServiceInstance) {
//     service.setAsForegroundService();
//   }

//   service.on('downloadAndPlay').listen((event) async {
//     final String? url = event?['url'];
//     final String? filename = event?['filename'];

//     if (url != null && filename != null) {
//       final file = await _downloadMp3(filename, url);
//       if (file != null) {
//         await _audioPlayer.play(DeviceFileSource(file.path));
//       }
//     }
//   });

//   service.on('stopAudio').listen((event) {
//     _audioPlayer.stop();
//   });

//   service.on('stopService').listen((event) {
//     service.stopSelf();
//   });

//   service.on('pauseAudio').listen((event) async {
//     await _audioPlayer.pause();
//   });
// }

// bool onIosBackground(ServiceInstance service) {
//   return true;
// }

// Future<File?> _downloadMp3(String filename, String url) async {
//   try {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/$filename.mp3');

//     if (await file.exists()) {
//       return file;
//     }

//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       await file.writeAsBytes(response.bodyBytes);
//       return file;
//     }
//   } catch (e) {
//     print("Download error: $e");
//   }
//   return null;
// }
