// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:quranku_offline/core/models/download_state.dart';
// import 'package:quranku_offline/core/providers/audio_play/audio_page_provider.dart';
// import 'package:quranku_offline/core/providers/audio_play/download_provider.dart';

// class AudioPage extends ConsumerWidget {
//   Future<String> loadAudioUrl() async {
//     const jsonString =
//         '{"audioUrl": "https://equran.nos.wjv-1.neo.id/audio-full/Ibrahim-Al-Dossari/002.mp3"}';
//     final data = json.decode(jsonString);
//     return data['audioUrl'];
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final downloadState = ref.watch(downloadProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Audio Streaming & Download')),
//       body: Center(
//         child: FutureBuilder<String>(
//           future: loadAudioUrl(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const CircularProgressIndicator();
//             } else if (snapshot.hasError || !snapshot.hasData) {
//               return const Text('Error loading audio URL');
//             }
//             final audioUrl = snapshot.data!;
//             return Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: () =>
//                       ref.read(audioPagePlayerProvider).play(audioUrl),
//                   child: const Text('Play Audio'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => ref.read(audioPagePlayerProvider).pause(),
//                   child: const Text('Pause Audio'),
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () => ref
//                       .read(downloadProvider.notifier)
//                       .startDownload(audioUrl),
//                   child: const Text('Download Audio'),
//                 ),
//                 if (downloadState.status == DownloadStatus.downloading)
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child:
//                         LinearProgressIndicator(value: downloadState.progress),
//                   ),
//                 if (downloadState.status == DownloadStatus.completed)
//                   const Text('Download Completed!'),
//                 if (downloadState.status == DownloadStatus.error)
//                   Text('Download Error: ${downloadState.errorMessage}'),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
