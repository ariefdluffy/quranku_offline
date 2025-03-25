import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranku_offline/core/models/surah_model.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';
import 'package:quranku_offline/features/surah/surah_page_new.dart';

class SearchResultPage extends ConsumerWidget {
  final List<Surah> searchResults;
  final int? ayahNumber;

  const SearchResultPage({
    super.key,
    required this.searchResults,
    this.ayahNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hasil Pencarian"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: searchResults.isEmpty
          ? const Center(
              child: Text(
                "❌ Surah atau Ayat Tidak Ditemukan",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final surah = searchResults[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    // leading: CircleAvatar(
                    //   backgroundColor: Colors.teal,
                    //   child: Text(
                    //     "${surah.nomor}",
                    //     style: const TextStyle(
                    //       color: Colors.white,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),
                    title: Text(
                      "QS. ${surah.namaLatin}: ${surah.nama}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${surah.jumlahAyat} Ayat",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, color: Colors.teal),
                    onTap: () {
                      // 🔹 Navigasi ke halaman SurahPage dengan ayat tertentu jika ada
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SurahPageNew(
                            surah: surah,
                            targetAyah: ayahNumber,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
