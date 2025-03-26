import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:quranku_offline/core/models/ayah_model.dart';
import 'package:quranku_offline/core/models/surah_model.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';
import 'package:quranku_offline/features/widget/ayah_detail_sheet.dart';
import 'package:quranku_offline/features/widget/surah_detail_dialog.dart';

class SurahPageNew extends ConsumerStatefulWidget {
  final Surah surah;
  final int? targetAyah;

  const SurahPageNew({super.key, required this.surah, this.targetAyah});

  @override
  _SurahPageState createState() => _SurahPageState();
}

class _SurahPageState extends ConsumerState<SurahPageNew> {
  late ScrollController _scrollController;
  List<Ayah> displayedAyat = [];
  int batchSize = 25; // Jumlah ayat yang dimuat per batch
  bool isLoadingMore = false;
  List<GlobalKey> _ayahKeys = [];
  int lastIndexLoaded = 0;
  int currentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // 🔹 Inisialisasi GlobalKey untuk setiap ayat
    _ayahKeys = List.generate(widget.surah.ayat.length, (_) => GlobalKey());
    // Logger().i("_ayahKeys: ${_ayahKeys}");

    _scrollController = ScrollController()..addListener(_onScroll);

    // 🔹 Muat ayat pertama kali
    _loadMoreAyat();

    // 🔹 Jika user mencari ayat tertentu, pastikan dimuat dan scroll ke sana
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.targetAyah != null) {
        _ensureAyahIsLoaded(widget.targetAyah!);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoadingMore) {
      _loadMoreAyat();
    }
  }

  void _loadMoreAyat() {
    if (currentIndex < widget.surah.ayat.length && !isLoadingMore) {
      setState(() {
        isLoadingMore = true;
      });

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            int nextIndex = currentIndex + batchSize;

            // ✅ Pastikan nextIndex tidak melebihi total ayat
            if (nextIndex > widget.surah.ayat.length) {
              nextIndex = widget.surah.ayat.length;
            }

            // ✅ Tambahkan hanya ayat yang belum ditampilkan
            displayedAyat
                .addAll(widget.surah.ayat.sublist(currentIndex, nextIndex));

            currentIndex = nextIndex;
            isLoadingMore = false;
          });
        }
      });
    }
  }

  Future<void> _loadAyat() async {
    await Future.delayed(
        const Duration(milliseconds: 800)); // 🔹 Simulasi loading ayat

    if (mounted) {
      setState(() {
        isLoading = false;
      });

      // ✅ Tunggu sampai widget sudah dirender sebelum scroll ke ayat tertentu
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.targetAyah != null) {
          _scrollToAyah(widget.targetAyah!);
        }
      });
    }
  }

  void _ensureAyahIsLoaded(int nomorAyat) {
    int index =
        widget.surah.ayat.indexWhere((ayah) => ayah.nomorAyat == nomorAyat);

    if (index != -1) {
      // Jika ayat yang dituju belum dimuat, muat lebih banyak hingga ayatnya tersedia
      if (index > lastIndexLoaded) {
        setState(() {
          displayedAyat = widget.surah.ayat.sublist(0, index + batchSize);
        });

        // 🔹 Pastikan sudah dirender sebelum scroll
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToAyah(index);
        });
      } else {
        // Jika sudah dimuat, langsung scroll
        _scrollToAyah(index);
      }
    }
  }

  void _scrollToAyah(int nomorAyat) {
    final index =
        widget.surah.ayat.indexWhere((ayah) => ayah.nomorAyat == nomorAyat);

    if (index == -1) {
      Logger().e("❌ Ayat tidak ditemukan!");
      return;
    }

    // 🔹 Jika target belum termuat, panggil ensureAyahIsLoaded
    if (index >= displayedAyat.length) {
      Logger().w("⚠ Target ayat $index belum dimuat, muat lebih banyak...");
      _ensureAyahIsLoaded(nomorAyat);
      return;
    }

    // 🔹 Jika target sudah tersedia, lakukan scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _ayahKeys[index];
      final context = key.currentContext;

      Logger().e("🔍 Scrolling to ayat $index..., $context");

      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      } else {
        Logger().e("❌ context masih null setelah render!");
      }
    });
  }

  // void _scrollToAyah(int index) {
  //   Future.delayed(const Duration(milliseconds: 300), () {
  //     if (_ayahKeys[index].currentContext != null) {
  //       Scrollable.ensureVisible(
  //         _ayahKeys[index].currentContext!,
  //         duration: const Duration(milliseconds: 600),
  //         curve: Curves.easeInOut,
  //         alignment: 0.2, // 🔹 Buat agar berada di tengah layar
  //       );

  //       Logger().i("Scrolled to ayah ${_ayahKeys[index].currentContext}");
  //     } else {
  //       // 🔹 Jika GlobalKey gagal, fallback ke scroll biasa
  //       _scrollController.animateTo(
  //         index * 150.0, // 🔹 Estimasi posisi scroll
  //         duration: const Duration(milliseconds: 600),
  //         curve: Curves.easeInOut,
  //       );
  //     }
  //   });
  // }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(12.0),
          itemCount: displayedAyat.length + 1,
          itemBuilder: (context, index) {
            if (index == displayedAyat.length) {
              return isLoadingMore
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox();
            }

            final ayah = displayedAyat[index];
            final isBookmarked = ref.watch(bookmarkProvider).contains(ayah);

            return GestureDetector(
              onTap: () => showAyahDetail(context, ayah),
              child: Container(
                key: _ayahKeys[index],
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12, blurRadius: 4, spreadRadius: 1),
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
                              _toggleBookmark(ayah);
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
                                  text: " ${ayah.teksArab} ",
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
          },
        ),
      ),
    );
  }

  void _toggleBookmark(Ayah ayah) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bookmark: Ayat ${ayah.nomorAyat} tersimpan!")),
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
