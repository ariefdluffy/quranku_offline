import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';
import 'package:quranku_offline/features/surah/surah_page.dart';

class BookmarkPage extends ConsumerWidget {
  const BookmarkPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkList = ref.watch(bookmarkProvider);
    final surahList = ref.watch(quranProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Bookmark"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: bookmarkList.isEmpty
          ? const Center(
              child: Text(
                "Belum ada ayat yang ditandai.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: bookmarkList.length,
              itemBuilder: (context, index) {
                final ayah = bookmarkList[index];

                // 🔹 Temukan Surah berdasarkan nomorSurah
                final surah =
                    surahList.firstWhere((s) => s.nomor == ayah.nomorSurah);

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ListTile(
                      isThreeLine: true,
                      // leading: Text(
                      //   "${surah.namaLatin} ",
                      //   style: GoogleFonts.lateef(
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.w500,
                      //     color: Colors.black,
                      //   ),
                      // ),
                      title: RichText(
                        textAlign: TextAlign.justify,
                        textDirection: TextDirection.rtl,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "${ayah.teksArab} ",
                              style: GoogleFonts.lateef(
                                fontSize: 34,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const WidgetSpan(
                                child: SizedBox(
                              width: 10,
                            )),
                            WidgetSpan(
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.teal, width: 2),
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: Text(
                                    "${ayah.nomorAyat}",
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                        height: 2.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      subtitle: Text(
                          "${surah.namaLatin}:${surah.nomor}, ${ayah.teksIndonesia}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          ref
                              .read(bookmarkProvider.notifier)
                              .removeBookmark(ayah);
                        },
                      ),
                      onTap: () {
                        // 🔹 Navigasi ke `SurahPage` dan langsung ke ayat yang dipilih
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SurahPage(
                              surah: surah,
                              targetAyah: ayah.nomorAyat, // 🔹 Kirim nomor ayat
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
