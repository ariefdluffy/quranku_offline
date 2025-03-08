import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranku_offline/core/providers/audio_full_provider.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';
import 'package:quranku_offline/features/about_page.dart';
import 'package:quranku_offline/features/widget/show_surah_dialog.dart';

class AudioFullPage extends ConsumerWidget {
  const AudioFullPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahList = ref.watch(quranProvider);
    final currentSurahIndex = ref.watch(audioFullPlayerProvider);
    final isPlayingAudio = ref.watch(isPlayingAudioProvider);
    final isLoadingAudio = ref.watch(isLoadingAudioProvider);

    if (surahList.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentSurah = surahList[currentSurahIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info, color: Colors.teal),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔹 Tombol Pilih Surah
            ElevatedButton.icon(
              icon: const Icon(Icons.search, color: Colors.white),
              label: const Text("Cari Surah"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final TextEditingController surahController =
                    TextEditingController();
                showSurahDialog(context, ref, surahController);
              },
            ),
            const SizedBox(height: 50),
            Text(
              "${currentSurah.namaLatin}: ${currentSurah.nomor}",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              currentSurah.nama,
              style: const TextStyle(fontSize: 24, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous,
                      size: 35, color: Colors.teal),
                  onPressed: () {
                    ref.read(audioFullPlayerProvider.notifier).previousSurah();
                  },
                ),
                Container(
                  width: 1, // Lebar pembatas
                  height: 40, // Tinggi pembatas
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10), // Jarak horizontal
                  decoration: BoxDecoration(
                    color: Colors.black54, // Warna pembatas
                    borderRadius: BorderRadius.circular(5), // Sudut melengkung
                  ),
                ),
                // 🔹 Tampilkan Loading Saat Audio Dimuat
                isLoadingAudio
                    ? const CircularProgressIndicator(
                        color: Colors.teal) // ⏳ Loading saat audio dimuat
                    : IconButton(
                        icon: Icon(
                          isPlayingAudio
                              ? Icons.pause_circle_outlined
                              : Icons.play_circle_fill,
                          size: 60,
                          color: Colors.teal,
                        ),
                        onPressed: () {
                          if (isPlayingAudio) {
                            ref
                                .read(audioFullPlayerProvider.notifier)
                                .pauseAudio();
                          } else {
                            ref
                                .read(audioFullPlayerProvider.notifier)
                                .playSurah(currentSurahIndex);
                          }
                        },
                      ),
                Container(
                  width: 1, // Lebar pembatas
                  height: 40, // Tinggi pembatas
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10), // Jarak horizontal
                  decoration: BoxDecoration(
                    color: Colors.black54, // Warna pembatas
                    borderRadius: BorderRadius.circular(5), // Sudut melengkung
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.skip_next, size: 35, color: Colors.teal),
                  onPressed: () {
                    ref.read(audioFullPlayerProvider.notifier).nextSurah();
                  },
                ),
              ],
            ),
            const Divider(),
            Column(
              children: [
                // 🔹 Tombol Stop Audio
                IconButton(
                  icon: const Icon(Icons.stop_circle_outlined,
                      size: 45, color: Colors.redAccent),
                  onPressed: () {
                    ref.read(audioFullPlayerProvider.notifier).stopAudio();
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
