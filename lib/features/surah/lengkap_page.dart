import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';
import 'package:quranku_offline/features/bookmark_page.dart';
import 'package:quranku_offline/features/widget/shimmer_loading.dart';

class LengkapPage extends ConsumerWidget {
  const LengkapPage({super.key});

  static const int ayahPerPage = 15;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahList = ref.watch(quranProvider);
    final currentPage = ref.watch(quranPaginationProvider);

    if (surahList.isEmpty) {
      return const Scaffold(
        body: Center(child: ShimmerLoading()),
      );
    }

// Ambil semua ayat dari seluruh surah
    final allAyahList = surahList.expand((surah) => surah.ayat).toList();
    int totalPages = (allAyahList.length / ayahPerPage).ceil();

// Menentukan ayat yang akan ditampilkan pada halaman saat ini
    final startIndex = currentPage * ayahPerPage;
    final endIndex = (startIndex + ayahPerPage < allAyahList.length)
        ? startIndex + ayahPerPage
        : allAyahList.length;
    final currentAyahList = allAyahList.sublist(startIndex, endIndex);

// ✅ Perbaikan: Ambil nama surah berdasarkan nomorSurah dari ayat pertama di halaman ini
    String namaSurah = surahList
        .firstWhere((surah) => surah.nomor == currentAyahList.first.nomorSurah)
        .namaLatin;

    return Scaffold(
      appBar: AppBar(
        title: Text(namaSurah),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark, color: Colors.teal),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookmarkPage()),
              );
            },
          ),
        ],
      ), // Nama surah di atas halaman
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    textAlign: TextAlign.justify,
                    textDirection: TextDirection.rtl,
                    text: TextSpan(
                      children: currentAyahList.expand((ayah) {
                        // Ambil nama Latin surah dari surahList
                        String namaSurah = surahList
                            .firstWhere(
                                (surah) => surah.nomor == ayah.nomorSurah)
                            .namaLatin;

                        // Cek apakah ayat ini adalah ayat terakhir dalam surah
                        bool isFirstAyah = surahList
                                .firstWhere(
                                    (surah) => surah.nomor == ayah.nomorSurah)
                                .ayat
                                .first
                                .nomorAyat ==
                            ayah.nomorAyat;

                        return [
                          if (isFirstAyah) ...[
                            // Nama Surah di Tengah
                            WidgetSpan(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.teal, size: 18),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Text(
                                          "【 $namaSurah 】",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.star,
                                          color: Colors.teal, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Garis Pemisah Dekoratif
                            const WidgetSpan(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Divider(
                                  thickness: 2,
                                  color: Colors.teal,
                                  indent: 50,
                                  endIndent: 50,
                                ),
                              ),
                            ),
                            // Tambahkan jarak setelah nama surah
                            const WidgetSpan(
                              child: SizedBox(height: 12),
                            ),
                          ],

                          // Ayat dalam satu baris dengan nomor ayat dalam lingkaran
                          TextSpan(
                            children: [
                              TextSpan(
                                text: " ${ayah.teksArab} ",
                                style: GoogleFonts.lateef(
                                  fontSize: 38,
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
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.teal,
                                          width: 2), // Border lingkaran
                                      color:
                                          Colors.white, // Warna latar belakang
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
                          // Tambahkan jarak antar ayat dengan SizedBox
                        ];
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentPage > 0
                      ? () => ref
                          .read(quranPaginationProvider.notifier)
                          .previousPage()
                      : null,
                  child: const Text("Prev"),
                ),
                Row(
                  children: [
                    // 🔹 Tombol "Go to Page"
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.teal),
                      onPressed: () =>
                          _showGoToPageDialog(context, ref, totalPages),
                    ),
                    Text(
                      "Hal: ${currentPage + 1} / $totalPages",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: currentPage < totalPages - 1
                      ? () => ref
                          .read(quranPaginationProvider.notifier)
                          .nextPage(totalPages)
                      : null,
                  child: const Text("Next"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showGoToPageDialog(BuildContext context, WidgetRef ref, int totalPages) {
  TextEditingController pageController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Pergi ke Halaman"),
        content: TextField(
          controller: pageController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Masukkan nomor halaman",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              int? targetPage = int.tryParse(pageController.text);
              if (targetPage != null &&
                  targetPage > 0 &&
                  targetPage <= totalPages) {
                ref
                    .read(quranPaginationProvider.notifier)
                    .jumpToPage(targetPage - 1);
                Navigator.pop(context);
              } else {
                // Tampilkan pesan jika input tidak valid
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Nomor halaman tidak valid"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Pergi"),
          ),
        ],
      );
    },
  );
}
