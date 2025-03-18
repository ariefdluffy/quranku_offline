import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/models/dzikir_pagi_model.dart';
import '../core/providers/dzikir/dzikir_pagi_provider.dart';

class DzikirPagiPage extends ConsumerWidget {
  const DzikirPagiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dzikirList = ref.watch(dzikirProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dzikir Pagi",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor:
          Colors.teal.shade50, // Background dengan nuansa hijau lembut
      body: dzikirList.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: dzikirList.length,
              itemBuilder: (context, index) {
                DzikirPagi dzikir = dzikirList[index];
                return DzikirCard(dzikir: dzikir);
              },
            ),
    );
  }
}

class DzikirCard extends StatefulWidget {
  final DzikirPagi dzikir;
  const DzikirCard({super.key, required this.dzikir});

  @override
  _DzikirCardState createState() => _DzikirCardState();
}

class _DzikirCardState extends State<DzikirCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
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
            const SizedBox(height: 10),
            Text(
              "Dibaca: ${widget.dzikir.dibaca}",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Teks Arab dengan Font Islami
            RichText(
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.justify,
              text: TextSpan(
                text: "${widget.dzikir.arab} ",
                style: GoogleFonts.lateef(
                  fontSize: 34,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),

            // Tombol Ekspansi
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() => _expanded = !_expanded);
                },
                child:
                    Text(_expanded ? "Sembunyikan Detail ⬆" : "Lihat Detail ⬇"),
              ),
            ),

            // Konten Tambahan (Muncul saat tombol ditekan)
            if (_expanded) ...[
              const Divider(),
              Text(
                "📖 Sumber: ${widget.dzikir.sumber}",
                style:
                    const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              ),
              const SizedBox(height: 5),
              Text(
                "📜 Faedah:\n${widget.dzikir.faedah}",
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.left,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
