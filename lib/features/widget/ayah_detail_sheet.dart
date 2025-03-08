import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranku_offline/core/models/ayah_model.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';

class AyahDetailSheet extends ConsumerWidget {
  final Ayah ayah;

  const AyahDetailSheet({super.key, required this.ayah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayer = ref.watch(audioPlayerProvider.notifier);
    final isPlaying = ref.watch(isPlayingProvider);

    // 🔹 Listener agar ikon berubah saat audio selesai
    ref.read(audioPlayerProvider).onPlayerComplete.listen((event) {
      ref.read(isPlayingProvider.notifier).state = false;
    });

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔹 Tombol Tutup
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  audioPlayer.stopAudio(ref);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.redAccent,
                    size: 26,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RichText(
                textAlign: TextAlign.justify,
                textDirection: TextDirection.rtl,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: " ${ayah.teksArab} ",
                      style: GoogleFonts.lateef(
                        fontSize: 40,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const WidgetSpan(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 22),
                      ),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.teal,
                                width: 2), // Border lingkaran
                            color: Colors.white, // Warna latar belakang
                          ),
                          child: Center(
                            child: Text(
                              "${ayah.nomorAyat}",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            Text(
              ayah.teksLatin,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey),
            ),
            const SizedBox(height: 10),

            Text(
              ayah.teksIndonesia,
              textAlign: TextAlign.justify,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const Divider(thickness: 1, color: Colors.teal),

            // 🔹 Tombol Play/Pause Audio
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: Colors.teal,
                size: 55,
              ),
              onPressed: () {
                if (isPlaying) {
                  audioPlayer.pauseAudio(ref);
                } else {
                  audioPlayer.playAudio(ayah.audio['04'] ?? '', ref);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
