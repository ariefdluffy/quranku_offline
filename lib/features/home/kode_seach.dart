// // ✅ Fungsi untuk Menampilkan Dialog Pencarian
//   void _showSearchDialog(BuildContext context, WidgetRef ref) {
//     TextEditingController surahController = TextEditingController();
//     TextEditingController ayahController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           title: const Text(
//             "Cari Surah / Ayat",
//             style: TextStyle(
//               color: Colors.teal,
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // 🔹 Input Nama Surah
//               TextField(
//                 controller: surahController,
//                 decoration: InputDecoration(
//                   hintText: "Masukkan nama surah",
//                   prefixIcon: const Icon(Icons.book, color: Colors.teal),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               const SizedBox(height: 10),

//               // 🔹 Input Nomor Ayat
//               TextField(
//                 controller: ayahController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   hintText: "Masukkan nomor ayat (opsional)",
//                   prefixIcon: const Icon(Icons.format_list_numbered,
//                       color: Colors.teal),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Batal",
//                   style: TextStyle(color: Colors.redAccent)),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 _searchSurah(
//                     context, ref, surahController.text, ayahController.text);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.teal,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text("Cari"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ✅ Fungsi untuk Mencari Surah / Ayat dan Navigasi ke Halaman yang Tepat
//   void _searchSurah(BuildContext context, WidgetRef ref, String namaSurah,
//       String nomorSurah) {
//     final surahList = ref.read(quranProvider);
//     int? ayahNum = int.tryParse(nomorSurah);

//     final surah = surahList.firstWhere(
//       (s) =>
//           s.namaLatin.toLowerCase() == namaSurah.toLowerCase() ||
//           s.nama.toLowerCase() == namaSurah.toLowerCase(),
//       orElse: () => Surah(
//           nomor: -1,
//           nama: "",
//           namaLatin: "",
//           jumlahAyat: 0,
//           tempatTurun: "",
//           arti: "",
//           deskripsi: "",
//           ayat: [],
//           audioFull: {"default": "04"}),
//     );

//     if (surah.nomor != -1) {
//       Navigator.pop(context); // Tutup dialog
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SurahPage(
//             surah: surah,
//             targetAyah: ayahNum,
//           ),
//         ),
//       );
//       return;
//     }

//     // Jika Tidak Ditemukan
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text("Surah atau ayat tidak ditemukan!",
//             style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }// ✅ Fungsi untuk Menampilkan Dialog Pencarian
//   void _showSearchDialog(BuildContext context, WidgetRef ref) {
//     TextEditingController surahController = TextEditingController();
//     TextEditingController ayahController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           title: const Text(
//             "Cari Surah / Ayat",
//             style: TextStyle(
//               color: Colors.teal,
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // 🔹 Input Nama Surah
//               TextField(
//                 controller: surahController,
//                 decoration: InputDecoration(
//                   hintText: "Masukkan nama surah",
//                   prefixIcon: const Icon(Icons.book, color: Colors.teal),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               const SizedBox(height: 10),

//               // 🔹 Input Nomor Ayat
//               TextField(
//                 controller: ayahController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   hintText: "Masukkan nomor ayat (opsional)",
//                   prefixIcon: const Icon(Icons.format_list_numbered,
//                       color: Colors.teal),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Batal",
//                   style: TextStyle(color: Colors.redAccent)),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 _searchSurah(
//                     context, ref, surahController.text, ayahController.text);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.teal,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text("Cari"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ✅ Fungsi untuk Mencari Surah / Ayat dan Navigasi ke Halaman yang Tepat
//   void _searchSurah(BuildContext context, WidgetRef ref, String namaSurah,
//       String nomorSurah) {
//     final surahList = ref.read(quranProvider);
//     int? ayahNum = int.tryParse(nomorSurah);

//     final surah = surahList.firstWhere(
//       (s) =>
//           s.namaLatin.toLowerCase() == namaSurah.toLowerCase() ||
//           s.nama.toLowerCase() == namaSurah.toLowerCase(),
//       orElse: () => Surah(
//           nomor: -1,
//           nama: "",
//           namaLatin: "",
//           jumlahAyat: 0,
//           tempatTurun: "",
//           arti: "",
//           deskripsi: "",
//           ayat: [],
//           audioFull: {"default": "04"}),
//     );

//     if (surah.nomor != -1) {
//       Navigator.pop(context); // Tutup dialog
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SurahPage(
//             surah: surah,
//             targetAyah: ayahNum,
//           ),
//         ),
//       );
//       return;
//     }

//     // Jika Tidak Ditemukan
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text("Surah atau ayat tidak ditemukan!",
//             style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }