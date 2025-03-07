import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quranku_offline/core/models/ayah_model.dart';
import 'package:quranku_offline/core/models/surah_model.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';
import 'package:quranku_offline/features/widget/ayah_detail_sheet.dart';
import 'package:quranku_offline/features/widget/shimmer_loading.dart';

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
            onPressed: () => _showSurahDetailDialog(
                context, ref, widget.surah), // 🔹 Tampilkan dialog detail
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

// // 🔹 Fungsi untuk Menampilkan Detail Ayat dengan Tombol Play Audio
// void _showAyahDetailDialog(BuildContext context, Ayah ayah) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     backgroundColor: Colors.white,
//     builder: (context) {
//       return Consumer(
//         builder: (context, ref, child) {
//           final audioPlayer = ref.watch(audioPlayerProvider.notifier);
//           final isPlaying = ref.watch(isPlayingProvider);

//           // 🔹 Tambahkan listener agar ikon berubah saat audio selesai
//           ref.read(audioPlayerProvider).onPlayerComplete.listen((event) {
//             ref.read(isPlayingProvider.notifier).state = false;
//           });

//           return Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // 🔹 Tombol Tutup di Kanan Atas
//                 Align(
//                   alignment: Alignment.topRight,
//                   child: InkWell(
//                     onTap: () {
//                       audioPlayer.stopAudio(ref);
//                       Navigator.pop(context);
//                     },
//                     borderRadius:
//                         BorderRadius.circular(30), // 🔹 Efek klik melingkar
//                     child: Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.redAccent
//                             .withOpacity(0.1), // 🔹 Warna transparan
//                       ),
//                       child: const Icon(
//                         Icons.close_rounded,
//                         color: Colors.redAccent,
//                         size: 26,
//                       ),
//                     ),
//                   ),
//                 ),

//                 Text(
//                   ayah.teksArab,
//                   textAlign: TextAlign.right,
//                   style: GoogleFonts.lateef(
//                     fontSize: 38,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   ayah.teksLatin,
//                   textAlign: TextAlign.right,
//                   style: const TextStyle(
//                       fontSize: 16,
//                       fontStyle: FontStyle.italic,
//                       color: Colors.grey),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   ayah.teksIndonesia,
//                   textAlign: TextAlign.left,
//                   style: const TextStyle(fontSize: 16, color: Colors.black87),
//                 ),
//                 const Divider(thickness: 1, color: Colors.teal),
//                 // 🔹 Tombol Play/Pause Audio
//                 IconButton(
//                   icon: Icon(
//                     isPlaying
//                         ? Icons.pause_circle_filled
//                         : Icons.play_circle_fill,
//                     color: Colors.teal,
//                     size: 60,
//                   ),
//                   onPressed: () {
//                     if (isPlaying) {
//                       audioPlayer.pauseAudio(ref);
//                     } else {
//                       audioPlayer.playAudio(ayah.audio['04'] ?? '', ref);
//                     }
//                   },
//                 ),
//                 // ElevatedButton.icon(
//                 //   onPressed: () {
//                 //     audioPlayer.stopAudio(ref);
//                 //     Navigator.pop(context);
//                 //   },
//                 //   icon: const Icon(Icons.close),
//                 //   label: const Text("Tutup"),
//                 //   style: ElevatedButton.styleFrom(
//                 //     backgroundColor: Colors.redAccent,
//                 //     foregroundColor: Colors.white,
//                 //     shape: RoundedRectangleBorder(
//                 //       borderRadius: BorderRadius.circular(10),
//                 //     ),
//                 //     padding: const EdgeInsets.symmetric(
//                 //         vertical: 12, horizontal: 20),
//                 //   ),
//                 // ),
//               ],
//             ),
//           );
//         },
//       );
//     },
//   );
// }

// 🔹 Fungsi untuk Menampilkan Detail Surah dalam Dialog
void _showSurahDetailDialog(BuildContext context, WidgetRef ref, Surah surah) {
  showDialog(
    useSafeArea: false,
    context: context,
    builder: (context) {
      return Consumer(
        builder: (context, ref, child) {
          final audioPlayer = ref.watch(audioPlayerProvider.notifier);
          final isPlaying = ref.watch(isPlayingProvider);

          final isLoadingAudio =
              ref.watch(isLoadingAudioProvider); // 🔹 Pantau loading

          // 🔹 Pastikan ada audio untuk surah ini
          String? audioUrl = surah.audioFull['04']; // Pilih Qari tertentu

          // 🔹 Tambahkan listener agar ikon berubah saat audio selesai
          ref.read(audioPlayerProvider).onPlayerComplete.listen((event) {
            ref.read(isPlayingProvider.notifier).state = false;
          });

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  surah.namaLatin,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal),
                ),
                InkWell(
                  onTap: () {
                    audioPlayer.stopAudio(ref);
                    Navigator.pop(context);
                  },
                  borderRadius:
                      BorderRadius.circular(30), // 🔹 Efek klik melingkar
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.redAccent
                          .withOpacity(0.1), // 🔹 Warna transparan
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.redAccent,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // const Divider(thickness: 1, color: Colors.teal),
                Text(
                  surah.nama,
                  style: GoogleFonts.amiri(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
                const SizedBox(height: 5),
                _buildDetailRow("Jumlah Ayat", "${surah.jumlahAyat} ayat"),
                _buildDetailRow("Tempat Turun", surah.tempatTurun),
                _buildDetailRow("Arti", surah.arti),
                const Divider(thickness: 1, color: Colors.teal),
                Text(
                  surah.deskripsi.replaceAll(
                      RegExp(r'<[^>]*>'), ''), // 🔹 Hilangkan tag HTML
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 15),

                // 🔹 Tombol Play/Pause dengan Loading
                if (audioUrl != null)
                  isLoadingAudio
                      ? const CircularProgressIndicator(
                          color:
                              Colors.teal) // ✅ Tampilkan loading saat download
                      : IconButton(
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            color: Colors.teal,
                            size: 55,
                          ),
                          onPressed: () {
                            if (isPlaying) {
                              audioPlayer.pauseAudio(ref);
                            } else {
                              audioPlayer.playAudio(audioUrl, ref);
                            }
                          },
                        ),
              ],
            ),
          );
        },
      );
    },
  );
}

// 🔹 Widget untuk Baris Detail
Widget _buildDetailRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black)),
        Text(value, style: const TextStyle(color: Colors.black54)),
      ],
    ),
  );
}
