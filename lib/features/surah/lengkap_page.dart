import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';
import 'package:quranku_offline/features/bookmark_page.dart';
import 'package:quranku_offline/features/widget/ayat_text_widget.dart';
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
        body: Center(
            child: ShimmerLoading(
          itemCount: 8,
        )),
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

    // String nomor = surahList
    //     .firstWhere((surah) => surah.nomor == currentAyahList.first.nomorSurah)
    //     .nomor
    //     .toString();

    // // 🔹 Gabungkan semua ayat dari seluruh surah
    // final allAyatList = surahList.map((surah) {
    //   return SurahAyatList(
    //     nomorSurah: surah.nomor,
    //     namaSurah: surah.nama,
    //     namaLatin: surah.namaLatin,
    //     ayatList: surah.ayat,
    //   );
    // }).toList();

    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          // 🔹 Fullscreen Mode saat Landscape
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        } else {
          // 🔹 Normal Mode saat Portrait
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        }
        return Scaffold(
          appBar: orientation == Orientation.portrait
              ? AppBar(
                  title: Text(namaSurah),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.bookmark, color: Colors.teal),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BookmarkPage()),
                        );
                      },
                    ),
                  ],
                )
              : null, // Nama surah di atas halaman
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AyahTextWidget(
                      ayahList: currentAyahList,
                      surahList: surahList,
                    ),
                  ),
                ),
              ),
              _buildPaginationControls(ref, context, currentPage, totalPages),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaginationControls(
      WidgetRef ref, BuildContext context, int currentPage, int totalPages) {
    return Container(
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
                ? () =>
                    ref.read(quranPaginationProvider.notifier).previousPage()
                : null,
            child: const Text("Prev"),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.teal),
                onPressed: () => _showGoToPageDialog(context, ref, totalPages),
              ),
              Text(
                "Hal: ${currentPage + 1} / $totalPages",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    );
  }

  void _showGoToPageDialog(
      BuildContext context, WidgetRef ref, int totalPages) {
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
}
