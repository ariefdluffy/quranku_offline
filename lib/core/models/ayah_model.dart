class Ayah {
  final int nomorSurah; // ✅ Tambahkan ini
  final int nomorAyat;
  final String teksArab;
  final String teksLatin;
  final String teksIndonesia;
  final Map<String, String> audio; // Audio dari beberapa qari

  Ayah({
    required this.nomorSurah,
    required this.nomorAyat,
    required this.teksArab,
    required this.teksLatin,
    required this.teksIndonesia,
    required this.audio,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      nomorSurah: json['nomorSurah'] ?? 0,
      nomorAyat: json['nomorAyat'] ?? 0,
      teksArab: json['teksArab'] ?? "",
      teksLatin: json['teksLatin'] ?? "",
      teksIndonesia: json['teksIndonesia'] ?? "",
      audio: Map<String, String>.from(
          json['audio'] ?? {}), // Konversi JSON audio ke Map
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomorSurah': nomorSurah,
      'nomorAyat': nomorAyat,
      'teksArab': teksArab,
      'teksLatin': teksLatin,
      'teksIndonesia': teksIndonesia,
      'audio': audio,
    };
  }
}
