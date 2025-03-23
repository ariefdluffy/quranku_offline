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
  bool isLoading = true;
  List<Ayah> filteredAyah = [];
  List<GlobalKey> _ayahKeys = [];

  void scrollToAyah(int nomorAyat) {
    final index =
        widget.surah.ayat.indexWhere((ayah) => ayah.nomorAyat == nomorAyat);

    if (index != -1) {
      // 🔹 Dapatkan posisi widget berdasarkan GlobalKey
      final key = _ayahKeys[index];
      final context = key.currentContext;

      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.1, // 🔹 Atur posisi agar lebih ke tengah layar
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _ayahKeys = List.generate(widget.surah.ayat.length, (_) => GlobalKey());

    _loadAyat();
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

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadAyat() async {
    await Future.delayed(
        const Duration(milliseconds: 300)); // 🔹 Simulasi loading ayat

    if (mounted) {
      setState(() {
        isLoading = false;
      });

      // ✅ Tunggu sampai widget sudah dirender sebelum scroll ke ayat tertentu
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.targetAyah != null) {
          scrollToAyah(widget.targetAyah!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final bookmarkList = ref.watch(bookmarkProvider);

    final ayatAsyncValue = ref.watch(futureSurahProvider(widget.surah));

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
        loading: () => const Center(child: ShimmerLoading(itemCount: 8)),
        error: (error, stackTrace) => Center(child: Text("Error: $error")),
        data: (ayatList) => SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: widget.surah.ayat.asMap().entries.map((entry) {
              final index = entry.key;
              final ayah = entry.value;
              final isBookmarked = ref.watch(bookmarkProvider).contains(ayah);

              return GestureDetector(
                onTap: () => showAyahDetail(context, ayah),
                child: Container(
                  key: _ayahKeys[index],
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
