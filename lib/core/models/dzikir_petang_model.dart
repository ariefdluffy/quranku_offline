import 'dart:convert';

class DzikirPetang {
  final int id;
  final String judul;
  final dynamic arab;
  final String? latin;
  final String? terjemahan;
  final String? sumber;
  final String? dibaca;
  final String? faedah;

  DzikirPetang({
    required this.id,
    required this.judul,
    required this.arab,
    this.latin,
    required this.terjemahan,
    required this.sumber,
    required this.dibaca,
    required this.faedah,
  });

  factory DzikirPetang.fromJson(Map<String, dynamic> json) {
    return DzikirPetang(
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

List<DzikirPetang> parseDzikirPagi(String jsonString) {
  final parsed = json.decode(jsonString)['dzikir_pagi'] as List;
  return parsed.map((json) => DzikirPetang.fromJson(json)).toList();
}
