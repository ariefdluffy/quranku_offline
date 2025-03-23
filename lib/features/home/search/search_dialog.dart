import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranku_offline/core/providers/quran_provider.dart';
import 'search_helper.dart';

class SearchDialog extends ConsumerStatefulWidget {
  const SearchDialog({super.key});

  @override
  _SearchDialogState createState() => _SearchDialogState();
}

class _SearchDialogState extends ConsumerState<SearchDialog> {
  final TextEditingController surahController = TextEditingController();
  final TextEditingController ayahController = TextEditingController();
  String? errorMessage;

  @override
  void dispose() {
    surahController.dispose();
    ayahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surahList = ref.watch(quranProvider);
    final List<String> surahNames = surahList.map((s) => s.namaLatin).toList();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        "Cari Surah / Ayat",
        style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔹 Input Nama Surah dengan AutoComplete
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return surahNames.where((name) => name
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (String selection) {
              surahController.text = selection;
              setState(() {}); // ✅ Perbarui UI agar tombol "X" muncul
            },
            fieldViewBuilder:
                (context, controller, focusNode, onEditingComplete) {
              surahController.text = controller.text;
              return TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: (_) =>
                    setState(() {}), // ✅ Perbarui UI saat mengetik
                decoration: InputDecoration(
                  hintText: "Masukkan nama surah",
                  prefixIcon: const Icon(Icons.book, color: Colors.teal),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () {
                            controller.clear();
                            setState(() {});
                          },
                        )
                      : null, // 🔹 Tampilkan tombol "X" hanya saat ada teks
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: Colors.white,
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.60, // ✅ Batasi Lebar
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final String option = options.elementAt(index);
                        return ListTile(
                          title: Text(
                            option,
                            maxLines: 1, // ✅ Batasi hanya 1 baris
                            overflow:
                                TextOverflow.ellipsis, // ✅ Tambahkan "..."
                            style: const TextStyle(fontSize: 14),
                          ),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // 🔹 Input Nomor Ayat (Opsional)
          TextField(
            controller: ayahController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}), // ✅ Perbarui UI saat mengetik
            decoration: InputDecoration(
              hintText: "Masukkan nomor ayat (opsional)",
              prefixIcon:
                  const Icon(Icons.format_list_numbered, color: Colors.teal),
              suffixIcon: ayahController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        ayahController.clear();
                        setState(() {});
                      },
                    )
                  : null, // 🔹 Tampilkan tombol "X" hanya saat ada teks
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          // 🔹 Tampilkan Pesan Error jika Surah/Ayat Tidak Ditemukan
          if (errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              errorMessage!,
              style: const TextStyle(
                  color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal", style: TextStyle(color: Colors.redAccent)),
        ),
        ElevatedButton(
          onPressed: () {
            SearchHelper.searchSurah(
              context,
              ref,
              surahController.text,
              ayahController.text,
              (msg) =>
                  setState(() => errorMessage = msg), // ✅ Update errorMessage
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          child: const Text("Cari"),
        ),
      ],
    );
  }
}
