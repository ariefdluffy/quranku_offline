import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';

class AudioPlayerWidget extends ConsumerWidget {
  final String? audioUrl; // Bisa berasal dari SurahModel atau AyahModel

  const AudioPlayerWidget({super.key, this.audioUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayer = ref.watch(audioPlayerProvider.notifier);
    final isPlaying = ref.watch(isPlayingProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🔹 Jika audioUrl tidak ada, tampilkan pesan
          if (audioUrl == null)
            const Text("Audio tidak tersedia",
                style: TextStyle(color: Colors.grey)),
          if (audioUrl != null) ...[
            // 🔹 Tombol Play/Pause Audio
            isLoading
                ? const CircularProgressIndicator(
                    color: Colors.teal) // ⏳ Loading saat audio di-download
                : Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                          color: Colors.teal,
                          size: 50,
                        ),
                        onPressed: () {
                          if (isPlaying) {
                            audioPlayer.pauseAudio(ref);
                            ref.read(isPlayingProvider.notifier).state = false;
                          } else {
                            audioPlayer.playAudio(audioUrl!, ref);
                            ref.read(isPlayingProvider.notifier).state = true;
                          }
                        },
                      ),
                      const SizedBox(width: 10), // 🔹 Beri sedikit jarak

                      // 🔹 Tombol Stop Audio
                      IconButton(
                        icon: const Icon(
                          Icons.stop_circle_outlined,
                          color: Colors.redAccent,
                          size: 50,
                        ),
                        onPressed: () {
                          audioPlayer.stopAudio(ref);
                          ref.read(isPlayingProvider.notifier).state = false;
                        },
                      ),
                    ],
                  ),
          ]
        ],
      ),
    );
  }
}
