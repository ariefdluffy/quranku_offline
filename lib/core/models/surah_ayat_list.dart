import 'package:quranku_offline/core/models/ayah_model.dart';

class SurahAyatList {
  final int nomorSurah;
  final String namaSurah;
  final String namaLatin;
  final List<Ayah> ayatList;

  SurahAyatList({
    required this.nomorSurah,
    required this.namaSurah,
    required this.namaLatin,
    required this.ayatList,
  });

  factory SurahAyatList.fromJson(Map<String, dynamic> json) {
    List<Ayah> sortedAyat = (json['ayat'] as List? ?? [])
        .map((e) => Ayah.fromJson({...e, 'nomorSurah': json['nomor']}))
        .toList();

    // ✅ Pastikan ayat selalu dalam urutan yang benar
    sortedAyat.sort((a, b) => a.nomorAyat.compareTo(b.nomorAyat));

    return SurahAyatList(
      nomorSurah: json['nomor'] ?? 0,
      namaSurah: json['nama'] ?? "",
      namaLatin: json['namaLatin'] ?? "",
      ayatList: sortedAyat,
    );
  }
}
