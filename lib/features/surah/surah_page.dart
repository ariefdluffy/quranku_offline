import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quranku_offline/core/models/surah_model.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';

class SurahPage extends ConsumerStatefulWidget {
  final Surah surah;

  const SurahPage({super.key, required this.surah});

  @override
  _SurahPageState createState() => _SurahPageState();
}

class _SurahPageState extends ConsumerState<SurahPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ref.read(scrollControllerProvider);
    // ✅ Perbarui visibilitas FAB saat halaman dimuat pertama kali
    Future.microtask(() {
      if (mounted) {
        ref
            .read(fabVisibilityProvider.notifier)
            .updateVisibility(_scrollController);
      }
    });

    // ✅ Tambahkan listener untuk mendeteksi perubahan scroll
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (mounted) {
      ref
          .read(fabVisibilityProvider.notifier)
          .updateVisibility(_scrollController);
    }
  }

  void _updateFab() {
    if (mounted) {
      ref
          .read(fabVisibilityProvider.notifier)
          .updateVisibility(_scrollController);
      ref.read(fabIconProvider.notifier).updateIcon(_scrollController);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateFab);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkList = ref.watch(bookmarkProvider);
    final scrollController = ref.watch(scrollControllerProvider);
    final isFabVisible =
        ref.watch(fabVisibilityProvider); // ✅ Cek apakah FAB perlu ditampilkan

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah.namaLatin),
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
      body: SingleChildScrollView(
        controller:
            scrollController, // ✅ Pastikan controller digunakan di scroll view
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: widget.surah.ayat.map((ayah) {
            bool isBookmarked = bookmarkList.contains(ayah);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        iconSize: 30,
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: isBookmarked ? Colors.teal : Colors.grey,
                        ),
                        onPressed: () {
                          if (isBookmarked) {
                            ref
                                .read(bookmarkProvider.notifier)
                                .removeBookmark(ayah);
                          } else {
                            ref
                                .read(bookmarkProvider.notifier)
                                .addBookmark(ayah);
                          }
                        },
                      ),
                      Expanded(
                        child: Text(
                          ayah.teksArab,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.amiri(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.teal, width: 2),
                          color: Colors.white,
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
                    ],
                  ),
                  const SizedBox(height: 4),
                  Divider(
                    thickness: 2,
                    color: Colors.teal.shade300,
                    indent: 10,
                    endIndent: 10,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),

      // 🔹 Floating Action Button (FAB) hanya muncul jika bisa di-scroll
      floatingActionButton: isFabVisible
          ? FloatingActionButton(
              onPressed: () {
                if (scrollController.hasClients) {
                  final isAtBottom = scrollController.position.pixels >=
                      scrollController.position.maxScrollExtent - 50;
                  if (isAtBottom) {
                    ref.read(scrollControllerProvider.notifier).scrollToTop();
                  } else {
                    ref
                        .read(scrollControllerProvider.notifier)
                        .scrollToBottom();
                  }
                }
              },
              backgroundColor: Colors.teal,
              child: Icon(
                scrollController.hasClients &&
                        scrollController.position.pixels >=
                            scrollController.position.maxScrollExtent - 50
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
              ),
            )
          : null, // ✅ FAB disembunyikan jika konten hanya 1 layar
    );
  }
}
