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

  void _showSearchDialog(BuildContext context, List<Surah> surahList) {
    final TextEditingController surahController = TextEditingController();
    final TextEditingController ayahController = TextEditingController();
    int? selectedSurahIndex;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cari Surah & Ayat"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 Input Nama Surah (AutoComplete)
              Autocomplete<Surah>(
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<Surah>.empty();
                  }
                  return surahList.where((surah) => surah.namaLatin
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()));
                },
                displayStringForOption: (Surah surah) => surah.namaLatin,
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                  surahController.text = controller.text;
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: "Nama Surah",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: surahController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                controller.clear();
                                surahController.clear();
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) => onFieldSubmitted(),
                  );
                },
                onSelected: (Surah surah) {
                  selectedSurahIndex = surah.nomor - 1;
                },
              ),
              const SizedBox(height: 10),

              // 🔹 Input Nomor Ayat
              TextField(
                controller: ayahController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Nomor Ayat",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: ayahController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            ayahController.clear();
                          },
                        )
                      : null,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedSurahIndex == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("❌ Pilih Surah terlebih dahulu!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                int? ayahNumber = int.tryParse(ayahController.text);
                if (ayahNumber != null) {
                  final surah = surahList[selectedSurahIndex!];
                  final ayahExists =
                      surah.ayat.any((ayah) => ayah.nomorAyat == ayahNumber);

                  if (!ayahExists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Ayat tidak ditemukan dalam surah ini!"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // ✅ Navigasi ke halaman Surah dan Scroll ke Ayat
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SurahPageNew(
                        surah: surah,
                        targetAyah: ayahNumber,
                      ),
                    ),
                  );
                } else {
                  // ✅ Jika hanya Surah yang dipilih, navigasikan ke halaman Surah
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SurahPage(surah: surahList[selectedSurahIndex!]),
                    ),
                  );
                }
              },
              child: const Text("Cari"),
            ),
          ],
        );
      },
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
