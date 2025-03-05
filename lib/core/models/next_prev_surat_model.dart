class SuratSelanjutnya {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;

  SuratSelanjutnya({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
  });

  // ✅ Tangani jika `json` adalah `false`
  factory SuratSelanjutnya.fromJson(dynamic json) {
    if (json is bool && json == false) {
      // Jika bernilai `false`, kembalikan objek default
      return SuratSelanjutnya(
        nomor: 0,
        nama: "Tidak Ada",
        namaLatin: "Tidak Ada",
        jumlahAyat: 0,
      );
    }

    // Jika `json` adalah objek Map<String, dynamic>, lakukan parsing normal
    return SuratSelanjutnya(
      nomor: json['nomor'] ?? 0,
      nama: json['nama'] ?? "",
      namaLatin: json['namaLatin'] ?? "",
      jumlahAyat: json['jumlahAyat'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomor': nomor,
      'nama': nama,
      'namaLatin': namaLatin,
      'jumlahAyat': jumlahAyat,
    };
  }
}

class SuratSebelumnya {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;

  SuratSebelumnya({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
  });

  // ✅ Tangani jika `json` adalah `false`
  factory SuratSebelumnya.fromJson(dynamic json) {
    if (json is bool && json == false) {
      // Jika bernilai `false`, kembalikan objek default
      return SuratSebelumnya(
        nomor: 0,
        nama: "Tidak Ada",
        namaLatin: "Tidak Ada",
        jumlahAyat: 0,
      );
    }

    // Jika `json` adalah objek Map<String, dynamic>, lakukan parsing normal
    return SuratSebelumnya(
      nomor: json['nomor'] ?? 0,
      nama: json['nama'] ?? "",
      namaLatin: json['namaLatin'] ?? "",
      jumlahAyat: json['jumlahAyat'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomor': nomor,
      'nama': nama,
      'namaLatin': namaLatin,
      'jumlahAyat': jumlahAyat,
    };
  }
}
