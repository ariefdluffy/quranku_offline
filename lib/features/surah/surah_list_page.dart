import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';
import 'package:quranku_offline/features/widget/surah_card.dart';

class SurahListPage extends ConsumerStatefulWidget {
  const SurahListPage({super.key});

  @override
  _SurahListPageState createState() => _SurahListPageState();
}

class _SurahListPageState extends ConsumerState<SurahListPage> {
  final ScrollController _scrollController = ScrollController();
  int batchSize = 10; // Jumlah item yang dimuat per batch
  int currentMax = 15; // Jumlah item yang ditampilkan

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Jika scroll mendekati akhir, muat lebih banyak data
      setState(() {
        currentMax += batchSize;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final surahList = ref.watch(quranProvider);

    return ListView.builder(
      controller: _scrollController,
      itemCount: (currentMax < surahList.length) ? currentMax + 1 : 20,
      itemBuilder: (context, index) {
        if (index == currentMax) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final surah = surahList[index];
        return SurahCard(surah: surah);
      },
    );
  }
}
