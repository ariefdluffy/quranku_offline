import 'package:logger/logger.dart';
import 'package:quranku_offline/core/models/ayah_model.dart';
import 'package:quranku_offline/core/models/next_prev_surat_model.dart';

final Logger logger = Logger();

class Surah {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final String deskripsi;
  final Map<String, String> audioFull; // Audio full dari beberapa qari
  final List<Ayah> ayat;
  // final List<SurahAyatList> ayatlist;
  final SuratSelanjutnya? suratSelanjutnya;
  final SuratSebelumnya? suratSebelumnya;

  Surah({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
    required this.audioFull,
    required this.ayat,
    this.suratSelanjutnya,
    this.suratSebelumnya,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    List<Ayah> sortedAyat = (json['ayat'] as List? ?? [])
        .map((e) => Ayah.fromJson({...e, 'nomorSurah': json['nomor']}))
        .toList();

    // ✅ Pastikan ayat selalu dalam urutan yang benar
    sortedAyat.sort((a, b) => a.nomorAyat.compareTo(b.nomorAyat));

    // // 🔹 Cetak JSON ke Logger (cek apakah data benar)
    // logger.i(
    //     "✅ Surah ${json['namaLatin']} (${json['nomor']}), Jumlah Ayat: ${json['jumlahAyat']}");
    // for (var ayah in sortedAyat) {
    //   logger.d("📖 Ayat ${ayah.nomorAyat}: ${ayah.teksArab}");
    // }

    return Surah(
      nomor: json['nomor'] ?? 0,
      nama: json['nama'] ?? "",
      namaLatin: json['namaLatin'] ?? "",
      jumlahAyat: json['jumlahAyat'] ?? 0,
      tempatTurun: json['tempatTurun'] ?? "",
      arti: json['arti'] ?? "",
      deskripsi: json['deskripsi'] ?? "",
      ayat: sortedAyat,
      // ayatlist: sortedAyat,
      audioFull: Map<String, String>.from(json['audioFull'] ?? {}),
      // ayat: (json['ayat'] as List? ?? [])
      //     .map((e) => Ayah.fromJson({...e, 'nomorSurah': json['nomor']}))
      //     .toList(),
      suratSelanjutnya: json['suratSelanjutnya'] != null
          ? SuratSelanjutnya.fromJson(json['suratSelanjutnya'])
          : null,
      // ✅ Cek apakah `suratSebelumnya` adalah objek atau `false`
      suratSebelumnya: json['suratSebelumnya'] != null
          ? SuratSebelumnya.fromJson(json['suratSebelumnya'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomor': nomor,
      'nama': nama,
      'namaLatin': namaLatin,
      'jumlahAyat': jumlahAyat,
      'tempatTurun': tempatTurun,
      'arti': arti,
      'deskripsi': deskripsi,
      'audioFull': audioFull,
      'ayat': ayat.map((e) => e.toJson()).toList(),
      'suratSelanjutnya': suratSelanjutnya?.toJson(),
      'suratSebelumnya': suratSebelumnya?.toJson(),
    };
  }
}
