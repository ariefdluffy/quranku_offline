import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quranku_offline/core/models/surah_model.dart';
import 'package:quranku_offline/features/surah/surah_page.dart';
import 'package:quranku_offline/features/surah/surah_page_new.dart';

class SurahCard extends StatelessWidget {
  final Surah surah;

  const SurahCard({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) =>
                SurahPageNew(surah: surah),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircleAvatar(
                backgroundColor: Colors.teal,
                child: Text(
                  "${surah.nomor}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          title: Text(
            surah.nama,
            style: GoogleFonts.lateef(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          subtitle: Text(
            "${surah.namaLatin}: ${surah.jumlahAyat} ayat",
            style: GoogleFonts.abel(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.teal,
            size: 20,
          ),
        ),
      ),
    );
  }
}
