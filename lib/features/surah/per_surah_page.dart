import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';
import 'package:quranku_offline/features/bookmark_page.dart';
import 'package:quranku_offline/features/widget/shimmer_loading.dart';
import 'package:quranku_offline/features/widget/surah_card.dart';

class PerSurahPage extends ConsumerWidget {
  const PerSurahPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahList = ref.watch(quranProvider);
    final scrollController = ref.watch(scrollControllerProvider);

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
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (scrollController.hasClients) {
            final isAtBottom = scrollController.position.pixels >=
                scrollController.position.maxScrollExtent - 50;
            if (isAtBottom) {
              ref.read(scrollControllerProvider.notifier).scrollToTop();
            } else {
              ref.read(scrollControllerProvider.notifier).scrollToBottom();
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
      ),
    );
  }
}
