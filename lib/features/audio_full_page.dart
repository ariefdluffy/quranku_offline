import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quranku_offline/core/providers/audio_full_provider.dart';
import 'package:quranku_offline/core/providers/connectivity_provider.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';
import 'package:quranku_offline/features/about_page.dart';
import 'package:quranku_offline/features/widget/show_surah_dialog.dart';

class AudioFullPage extends ConsumerStatefulWidget {
  const AudioFullPage({super.key});

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends ConsumerState<AudioFullPage> {
  final TextEditingController surahController = TextEditingController();

  @override
  void dispose() {
    surahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSurahIndex = ref.watch(audioFullPlayerProvider);
    final surahList = ref.watch(quranProvider);
    final isPlayingAudio = ref.watch(isPlayingAudioProvider);
    final isLoadingAudio = ref.watch(isLoadingAudioProvider);

    final connectivity = ref.watch(connectivityProvider);

    // ✅ Dengarkan perubahan koneksi dan tampilkan Snackbar jika internet putus
    ref.listen<AsyncValue<ConnectivityResult>>(
      connectivityProvider,
      (previous, next) {
        if (next.value == ConnectivityResult.none) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Internet terputus! Audio dihentikan."),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          ref.read(audioFullPlayerProvider.notifier).stopAudio();
        }
      },
    );

    if (surahList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.teal),
      );
    }

    final currentSurah = surahList[currentSurahIndex];

    return Padding(
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
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => showSurahDialog(context, ref, surahController),
          ),
          const SizedBox(height: 50),

          // 🔹 Nama Surah & Nomor
          Text(
            "${currentSurah.namaLatin}: ${currentSurah.nomor}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            currentSurah.nama,
            style: GoogleFonts.lateef(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),

          // 🔹 Kontrol Audio
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous,
                    size: 35, color: Colors.teal),
                onPressed: () =>
                    ref.read(audioFullPlayerProvider.notifier).previousSurah(),
              ),
              _buildVerticalDivider(), // 🔹 Pembatas

              // 🔹 Loading atau Play/Pause
              isLoadingAudio
                  ? const CircularProgressIndicator(color: Colors.teal)
                  : IconButton(
                      icon: Icon(
                        isPlayingAudio
                            ? Icons.pause_circle_outlined
                            : Icons.play_circle_fill,
                        size: 60,
                        color: Colors.teal,
                      ),
                      onPressed: () {
                        // if (isPlayingAudio) {
                        //   ref
                        //       .read(audioFullPlayerProvider.notifier)
                        //       .pauseAudio();
                        // } else {
                        //   ref
                        //       .read(audioFullPlayerProvider.notifier)
                        //       .playSurah(currentSurahIndex);
                        // }
                        // 🔹 Cek koneksi sebelum memutar audio
                        if (connectivity.value == ConnectivityResult.none) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Tidak ada koneksi internet!"),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 3),
                            ),
                          );
                          return; // 🚫 Jangan lanjutkan pemutaran jika tidak ada internet
                        }

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

              _buildVerticalDivider(), // 🔹 Pembatas

              IconButton(
                icon: const Icon(Icons.skip_next, size: 35, color: Colors.teal),
                onPressed: () =>
                    ref.read(audioFullPlayerProvider.notifier).nextSurah(),
              ),
            ],
          ),

          const Divider(),

          // 🔹 Tombol Stop Audio
          IconButton(
            icon: const Icon(Icons.stop_circle_outlined,
                size: 45, color: Colors.redAccent),
            onPressed: () =>
                ref.read(audioFullPlayerProvider.notifier).stopAudio(),
          ),
        ],
      ),
    );
  }

  // 🔹 Widget untuk Pembatas Vertikal
  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
