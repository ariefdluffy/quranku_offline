import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:quranku_offline/core/providers/ad_provider.dart';
import 'package:quranku_offline/core/providers/audio_full_provider.dart';
import 'package:quranku_offline/core/providers/audio_storage_provider.dart';
import 'package:quranku_offline/core/providers/connectivity_provider.dart';

import 'package:quranku_offline/core/providers/quran_provider.dart';
import 'package:quranku_offline/features/about_page.dart';
import 'package:quranku_offline/features/utils/device_info_helper.dart';
import 'package:quranku_offline/features/utils/tele_helper.dart';
import 'package:quranku_offline/features/widget/show_surah_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class AudioFullPage extends ConsumerStatefulWidget {
  const AudioFullPage({super.key});

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends ConsumerState<AudioFullPage> {
  final TextEditingController surahController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentSurahIndex = ref.watch(audioFullPlayerProvider);
    final surahList = ref.watch(quranProvider);
    final isPlayingAudio = ref.watch(isPlayingAudioProvider);
    final isLoadingAudio = ref.watch(isLoadingAudioProvider);
    final bannerAd = ref.watch(bannerAdProvider);
    final downloadedSize = ref.watch(downloadedSizeProvider);

    if (surahList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.teal),
      );
    }

    final currentSurah = surahList[currentSurahIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
        // centerTitle: true,
        // backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutPage()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Surah Information Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "QS. ${currentSurah.namaLatin}: ${currentSurah.nomor}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    Text(
                      "${currentSurah.jumlahAyat} Ayat",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      currentSurah.nama,
                      style: GoogleFonts.amiri(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Audio Controls
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous,
                              size: 40, color: Colors.teal),
                          onPressed: () => ref
                              .read(audioFullPlayerProvider.notifier)
                              .previousSurah(context),
                        ),
                        const SizedBox(width: 20),
                        isLoadingAudio
                            ? const CircularProgressIndicator(
                                color: Colors.teal)
                            : IconButton(
                                icon: Icon(
                                  isPlayingAudio
                                      ? Icons.pause_circle_filled
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
                                        .playSurah(context, currentSurahIndex);
                                  }
                                },
                              ),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: const Icon(Icons.skip_next,
                              size: 40, color: Colors.teal),
                          onPressed: () => ref
                              .read(audioFullPlayerProvider.notifier)
                              .nextSurah(context),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.teal,
                      thickness: 1,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Stop Button
                        ElevatedButton.icon(
                          icon: const Icon(Icons.stop_circle_outlined,
                              color: Colors.white, size: 20),
                          label: const Text("Stop"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => ref
                              .read(audioFullPlayerProvider.notifier)
                              .stopAudio(),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      "Total Ukuran File: $downloadedSize",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text("Hapus semua surah"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        bool? confirmDelete = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Hapus Semua File?"),
                              content: const Text(
                                  "Apakah Anda yakin ingin menghapus semua file surah yang telah diunduh?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Batal"),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent),
                                  child: const Text(
                                    "Hapus",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmDelete == true) {
                          await deleteAllSurahFiles(context, ref);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 40),
            // Ad Banner
            if (bannerAd != null && bannerAd.responseInfo != null)
              Container(
                width: bannerAd.size.width.toDouble(),
                height: bannerAd.size.height.toDouble(),
                alignment: Alignment.center,
                child: AdWidget(ad: bannerAd),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showSurahDialog(context, ref, surahController),
        label: const Text("Cari Surah"),
        icon: const Icon(Icons.search),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    surahController.dispose();

    super.dispose();
  }
}
