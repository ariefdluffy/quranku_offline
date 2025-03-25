import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quranku_offline/core/models/surah_model.dart';
import 'package:quranku_offline/core/providers/ad_provider.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';
import 'package:quranku_offline/features/dzikir_pagi/dzikir_pagi_page.dart';
import 'package:quranku_offline/features/bookmark_page.dart';
import 'package:quranku_offline/features/dzikir_petang/dzikir_petang_page.dart';
import 'package:quranku_offline/features/dzikir_lainnya/home_dzikri_lainnya_page.dart';
import 'package:quranku_offline/features/home/search/search_dialog.dart';
import 'package:quranku_offline/features/surah/search_result_page.dart';
import 'package:quranku_offline/features/surah/surah_page.dart';
import 'package:quranku_offline/features/surah/surah_page_new.dart';
import 'package:quranku_offline/features/widget/shimmer_loading.dart';
import 'package:quranku_offline/features/widget/surah_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahList = ref.watch(quranProvider);
    final bannerAd = ref.watch(bannerAdProviderPerSurah);

    return Scaffold(
      body: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft, // Menempatkan teks ke kiri
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10), // Tambahkan padding biar rapi
            child: const Text(
              "Menu Utama",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ),
          SizedBox(
            height: 110,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: GridView.count(
                crossAxisCount: 4, // 2 kolom
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildMenuCard(
                    icon: Icons.sunny,
                    label: "Dzikir Pagi",
                    color: const Color.fromARGB(255, 231, 215, 66),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DzikirPagiPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.mode_night_outlined,
                    label: "Dzikir Petang",
                    color: Colors.blueGrey,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DzikirPetangPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.wysiwyg,
                    label: "Dzikir Lainnya",
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeDzikirLainnyaPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.bookmark_added_rounded,
                    label: "Bookmark",
                    color: Colors.redAccent,
                    onTap: () {
                      // Aksi ketika menu diklik
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BookmarkPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft, // Menempatkan teks ke kiri
            padding: const EdgeInsets.symmetric(
                horizontal: 16), // Tambahkan padding biar rapi
            child: const Text(
              "Daftar Surah",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            // Gunakan Expanded di sini agar mengambil sisa tinggi yang tersedia
            child: surahList.isEmpty
                ? const ShimmerLoading(
                    itemCount: 9,
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: ListView.builder(
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.search, color: Colors.white),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const SearchDialog(), // ✅ Hapus `const`
          );
        },
        // onPressed: () {
        //   _showSearchDialog(context, surahList);
        // },
      ),
    );
  }

  Widget _buildMenuCard(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 25, color: color),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
