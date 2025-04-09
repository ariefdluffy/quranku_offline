import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quranku_offline/core/models/ayah_model.dart';
import 'package:quranku_offline/core/models/surah_model.dart';

class AyahTextWidget extends StatelessWidget {
  final List<Ayah> ayahList;
  final List<Surah> surahList;

  const AyahTextWidget({
    super.key,
    required this.ayahList,
    required this.surahList,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.justify,
      textDirection: TextDirection.rtl,
      text: TextSpan(
        children: ayahList.expand((ayah) {
          // 🔹 Ambil nama Latin surah dari `surahList`
          String namaSurah = surahList
              .firstWhere((surah) => surah.nomor == ayah.nomorSurah)
              .namaLatin;

          // 🔹 Ambil Nomor Surah dari `surahList`
          String nomorSurah = surahList
              .firstWhere((surah) => surah.nomor == ayah.nomorSurah)
              .nomor
              .toString();

          // 🔹 Ambil Jumlah ayat Latin surah dari `surahList`
          String jumlahAyat = surahList
              .firstWhere((surah) => surah.nomor == ayah.nomorSurah)
              .jumlahAyat
              .toString();

          // 🔹 Cek apakah ayat ini adalah ayat pertama dalam surah
          bool isFirstAyah = surahList
                  .firstWhere((surah) => surah.nomor == ayah.nomorSurah)
                  .ayat
                  .first
                  .nomorAyat ==
              ayah.nomorAyat;

          // 🔹 Cek apakah ayat ini adalah ayat terakhir dalam surah
          // bool isLastAyah = surahList
          //         .firstWhere((surah) => surah.nomor == ayah.nomorSurah)
          //         .ayat
          //         .last
          //         .nomorAyat ==
          //     ayah.nomorAyat;

          return [
            // 🔹 Tampilkan Nama Surah di Awal
            if (isFirstAyah) ...[
              const WidgetSpan(
                child: Divider(
                  thickness: 1,
                  color: Colors.teal,
                  indent: 40,
                  endIndent: 40,
                ),
              ),
              WidgetSpan(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 2, top: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.teal, size: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "【 $namaSurah: $nomorSurah ($jumlahAyat Ayat) 】",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const Icon(Icons.star, color: Colors.teal, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            // 🔹 Tampilkan Ayat dan Nomor Ayat
            TextSpan(
              children: [
                TextSpan(
                  text: " ${ayah.teksArab}",
                  style: GoogleFonts.amiriQuran(
                    fontSize: 34,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const WidgetSpan(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.teal, width: 1),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          "${ayah.nomorAyat}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ];
        }).toList(),
      ),
    );
  }
}
