import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quranku_offline/core/models/dzikir_setelah_sholat.dart';

class DzikirCardSetelahSholat extends StatefulWidget {
  final DzikirSetelahSholat dzikir;

  const DzikirCardSetelahSholat({super.key, required this.dzikir});

  @override
  _DzikirCardSetelahSholatState createState() =>
      _DzikirCardSetelahSholatState();
}

class _DzikirCardSetelahSholatState extends State<DzikirCardSetelahSholat> {
  bool _expanded = false; // State lokal untuk ekspansi

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Dzikir
              Text(
                widget.dzikir.judul,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
              ),
              const SizedBox(height: 5),
              Text(
                "Dibaca: ${widget.dzikir.dibaca}",
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Teks Arab dengan Font Islami
              RichText(
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.justify,
                text: TextSpan(
                  text: "${widget.dzikir.arab} ",
                  style: GoogleFonts.lateef(
                    fontSize: 38,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "${widget.dzikir.latin}",
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.justify,
              ),

              // Tombol Ekspansi
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() => _expanded = !_expanded);
                  },
                  child: Text(
                      _expanded ? "Sembunyikan Detail ⬆" : "Lihat Detail ⬇"),
                ),
              ),

              // Konten Tambahan (Muncul saat tombol ditekan)
              if (_expanded) ...[
                const Divider(),
                Text(
                  "Terjemahan: ${widget.dzikir.terjemahan}",
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 5),
                if (widget.dzikir.faedah != null &&
                    widget.dzikir.faedah!.isNotEmpty) ...[
                  Text(
                    "📜 Faedah:\n${widget.dzikir.faedah}",
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 5),
                ],
                if (widget.dzikir.sumber != null &&
                    widget.dzikir.sumber!.isNotEmpty) ...[
                  Text(
                    "📖 Sumber: ${widget.dzikir.sumber}",
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 5),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
