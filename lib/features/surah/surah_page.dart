import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quranku_offline/core/models/ayah_model.dart';
import 'package:quranku_offline/core/models/surah_model.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';
import 'package:quranku_offline/features/widget/audio_player_widget.dart';
import 'package:quranku_offline/features/widget/ayah_detail_sheet.dart';
import 'package:quranku_offline/features/widget/shimmer_loading.dart';
import 'package:quranku_offline/features/widget/surah_detail_dialog.dart';

class SurahPage extends ConsumerStatefulWidget {
  final Surah surah;

  final int? targetAyah;

  const SurahPage({super.key, required this.surah, this.targetAyah});

  @override
  _SurahPageState createState() => _SurahPageState();
}

class _SurahPageState extends ConsumerState<SurahPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Panggil fungsi yang memodifikasi provider di sini
      _loadAyat();
    });
    // _loadAyat();
    _scrollController = ref.read(scrollControllerProvider);
    // ✅ Perbarui visibilitas FAB saat halaman dimuat pertama kali
    Future.microtask(
      () {
        if (mounted) {
          ref
              .read(fabVisibilityProvider.notifier)
              .updateVisibility(_scrollController);
        }
      },
    );

    void _scrollToAyah(int nomorAyat) {
      final index =
          widget.surah.ayat.indexWhere((ayah) => ayah.nomorAyat == nomorAyat);
      if (index != -1) {
        _scrollController.animateTo(
          index * 100.0, // 🔹 Scroll ke posisi (100 pixel per ayat)
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }

    // 🔹 Tunggu hingga halaman selesai build sebelum scroll ke ayat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.targetAyah != null) {
        _scrollToAyah(widget.targetAyah!);
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

  Future<void> _loadAyat() async {
    ref.read(isLoadingProvider.notifier).state = true; // ✅ Set loading ke true

    await Future.delayed(const Duration(seconds: 2)); // ✅ Simulasi delay

    ref.read(isLoadingProvider.notifier).state =
        false; // ✅ Set loading ke false setelah data dimuat
  }

  @override
  Widget build(BuildContext context) {
    // final bookmarkList = ref.watch(bookmarkProvider);
    final scrollController = ref.watch(scrollControllerProvider);
    final isFabVisible =
        ref.watch(fabVisibilityProvider); // ✅ Cek apakah FAB perlu ditampilkan

    final ayatAsyncValue = ref.watch(futureSurahProvider(widget.surah));
    const isLoading = false;

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
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => showSurahDetail(
                context, widget.surah), // 🔹 Tampilkan dialog detail
          ),
        ],
      ),
      body: ayatAsyncValue.when(
        loading: () => const Center(
          child: ShimmerLoading(
            itemCount: 8,
          ), // ✅ Loading indikator
        ),
        error: (error, stackTrace) => Center(
          child: Text("Error: $error"), // ✅ Tampilkan error jika gagal load
        ),
        data: (ayatList) => SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: ayatList.map((ayah) {
              final isBookmarked = ref.watch(bookmarkProvider).contains(ayah);

              return GestureDetector(
                onTap: () => showAyahDetail(context, ayah),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          spreadRadius: 1),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Divider(
                          thickness: 1,
                          color: Colors.teal.shade300,
                          indent: 10,
                          endIndent: 10),
                      // const SizedBox(width: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // 🔹 Tombol Bookmark
                          IconButton(
                            icon: Icon(
                              size: 30,
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
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
                          const SizedBox(width: 5),
                          Expanded(
                            child: RichText(
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.justify,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "${ayah.teksArab} ",
                                    style: GoogleFonts.lateef(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  WidgetSpan(
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.teal, width: 2),
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
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                      Divider(
                          thickness: 1,
                          color: Colors.teal.shade300,
                          indent: 10,
                          endIndent: 10),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // 🔹 Tambahkan Container Audio di Bawah
      ),
      // 🔹 Gunakan Widget AudioPlayer di Bawah
      bottomNavigationBar: SafeArea(
        child: AudioPlayerWidget(
          audioUrl: widget.surah.audioFull['04'], // Pilih Qari tertentu
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

void showAyahDetail(BuildContext context, Ayah ayah) {
  showModalBottomSheet(
    useSafeArea: true,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white,
    builder: (context) => AyahDetailSheet(ayah: ayah),
  );
}

void showSurahDetail(BuildContext context, Surah surah) {
  showDialog(
    useSafeArea: false,
    context: context,
    builder: (context) => SurahDetailDialog(surah: surah),
  );
}
