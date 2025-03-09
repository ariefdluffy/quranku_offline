import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quranku_offline/core/providers/ad_provider.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';
import 'package:quranku_offline/features/bookmark_page.dart';
import 'package:quranku_offline/features/widget/shimmer_loading.dart';
import 'package:quranku_offline/features/widget/surah_card.dart';

class PerSurahPage extends ConsumerWidget {
  const PerSurahPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahList = ref.watch(quranProvider);

    final bannerAd = ref.watch(bannerAdProvider);

    // final scrollController = ref.watch(scrollControllerProvider);
    // final isFabVisible =
    //     ref.watch(fabVisibilityProvider); // ✅ Cek apakah FAB perlu ditampilkan

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookmark"),
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
      ),
      body: surahList.isEmpty
          ? const ShimmerLoading(
              itemCount: 9,
            )
          : Column(
              children: [
                if (bannerAd !=
                    null) // 🔹 Menampilkan Banner Ads jika berhasil dimuat
                  SizedBox(
                    height: bannerAd.size.height.toDouble(),
                    width: bannerAd.size.width.toDouble(),
                    child: AdWidget(ad: bannerAd),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: ListView.builder(
                      // shrinkWrap: true,
                      // physics: const NeverScrollableScrollPhysics(),
                      itemCount: surahList.length,
                      itemBuilder: (context, index) {
                        final surah = surahList[index];
                        return SurahCard(surah: surah);
                      },
                    ),
                  ),
                ),
              ],
            ),
      // 🔹 Tambahkan Banner Ads di BottomNavigationBar
      // bottomNavigationBar: bannerAd != null
      //     ? SizedBox(
      //         height: bannerAd.size.height.toDouble(),
      //         child: AdWidget(ad: bannerAd),
      //       )
      //     : null,

      // floatingActionButton: isFabVisible
      //     ? FloatingActionButton(
      //         onPressed: () {
      //           if (scrollController.hasClients) {
      //             final isAtBottom = scrollController.position.pixels >=
      //                 scrollController.position.maxScrollExtent - 50;
      //             if (isAtBottom) {
      //               ref.read(scrollControllerProvider.notifier).scrollToTop();
      //             } else {
      //               ref
      //                   .read(scrollControllerProvider.notifier)
      //                   .scrollToBottom();
      //             }
      //           }
      //         },
      //         backgroundColor: Colors.teal,
      //         child: Icon(
      //           scrollController.hasClients &&
      //                   scrollController.position.pixels >=
      //                       scrollController.position.maxScrollExtent - 50
      //               ? Icons.arrow_upward
      //               : Icons.arrow_downward,
      //         ),
      //       )
      //     : null,
    );
  }
}
