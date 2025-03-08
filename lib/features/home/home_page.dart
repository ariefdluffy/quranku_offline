import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranku_offline/core/providers/navigation_provider.dart';

import 'package:quranku_offline/features/audio_full_page.dart';
import 'package:quranku_offline/features/surah/lengkap_page.dart';
import 'package:quranku_offline/features/surah/per_surah_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);

    // List Halaman sesuai dengan indeks Bottom Navigation Bar
    final List<Widget> pages = [
      const PerSurahPage(),
      const LengkapPage(),
      const AudioFullPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Al-Quran Offline",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
      body: pages[currentIndex], // Menampilkan halaman berdasarkan indeks
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          // ref.read(navigationProvider.notifier).changePage(index);
          ref.read(navigationProvider.notifier).state = index;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Surah",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Al-Qur'an",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.spatial_audio_off),
            label: "Audio",
          ),
        ],
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}
