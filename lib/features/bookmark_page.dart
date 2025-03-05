import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';

class BookmarkPage extends ConsumerWidget {
  const BookmarkPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkList = ref.watch(bookmarkProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Bookmark")),
      body: bookmarkList.isEmpty
          ? const Center(
              child: Text(
                "Belum ada ayat yang ditandai.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: bookmarkList.length,
              itemBuilder: (context, index) {
                final ayah = bookmarkList[index];

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ListTile(
                      title: Text(
                        ayah.teksArab,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.amiri(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(ayah.teksIndonesia),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          ref
                              .read(bookmarkProvider.notifier)
                              .removeBookmark(ayah);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
