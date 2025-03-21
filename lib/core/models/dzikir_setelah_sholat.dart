import 'dart:convert';

class DzikirSetelahSholat {
  final int id;
  final String judul;
  final dynamic arab;
  final String? latin;
  final String? terjemahan;
  final String? sumber;
  final String? dibaca;
  final String? faedah;

  DzikirSetelahSholat({
    required this.id,
    required this.judul,
    required this.arab,
    this.latin,
    required this.terjemahan,
    required this.sumber,
    required this.dibaca,
    required this.faedah,
  });

  factory DzikirSetelahSholat.fromJson(Map<String, dynamic> json) {
    return DzikirSetelahSholat(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? "Tanpa Judul",
      arab: json['arab'] ?? "",
      latin: json['latin'] ?? "",
      terjemahan: json['terjemahan'] ?? "",
      sumber: json['sumber'] ?? "",
      dibaca: json['dibaca'] ?? "1x",
      faedah: json['faedah'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'arab': arab,
      'latin': latin,
      'terjemahan': terjemahan,
      'sumber': sumber,
      'dibaca': dibaca,
      'faedah': faedah,
    };
  }
}

List<DzikirSetelahSholat> parseDzikirSetelahSholat(String jsonString) {
  final parsed = json.decode(jsonString)['dzikir_setelah_sholat'] as List;
  return parsed.map((json) => DzikirSetelahSholat.fromJson(json)).toList();
}
