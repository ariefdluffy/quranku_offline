// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:quranku_offline/core/providers/quran_provider.dart';
// import 'package:quranku_offline/features/bookmark_page.dart';
// import 'package:quranku_offline/features/widget/shimmer_loading.dart';

// class LengkapPage extends ConsumerWidget {
//   const LengkapPage({super.key});

//   static const int ayahPerPage = 15;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final surahList = ref.watch(quranProvider);
//     final currentPage = ref.watch(quranPaginationProvider);

//     if (surahList.isEmpty) {
//       return const Scaffold(
//         body: Center(
//             child: ShimmerLoading(
//           itemCount: 8,
//         )),
//       );
//     }

//     // Ambil semua ayat dari seluruh surah
//     final allAyahList = surahList.expand((surah) => surah.ayat).toList();
//     int totalPages = (allAyahList.length / ayahPerPage).ceil();

//     // Menentukan ayat yang akan ditampilkan pada halaman saat ini
//     final startIndex = currentPage * ayahPerPage;
//     final endIndex = (startIndex + ayahPerPage < allAyahList.length)
//         ? startIndex + ayahPerPage
//         : allAyahList.length;
//     final currentAyahList = allAyahList.sublist(startIndex, endIndex);

//     // Ambil nama Latin surah pertama di halaman ini
//     String namaSurah = surahList
//         .firstWhere((surah) => surah.nomor == currentAyahList.first.nomorSurah)
//         .namaLatin;

//     return OrientationBuilder(
//       builder: (context, orientation) {
//         bool isLandscape = orientation == Orientation.landscape;

//         if (isPlaying) {
//           SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//         } else {
//           SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//         }

//         return Scaffold(
//           appBar: isLandscape()
//               ? null
//               : AppBar(
//                   title: Text(
//                     namaSurah,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   centerTitle: true,
//                   backgroundColor: Colors.teal,
//                   foregroundColor: Colors.white,
//                   actions: [
//                     IconButton(
//                       icon: const Icon(Icons.bookmark, color: Colors.teal),
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const BookmarkPage(),
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//           body: Column(
//             children: [
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(14.0),
//                   child: SingleChildScrollView(
//                     child: RichText(
//                       textAlign: TextAlign.justify,
//                       textDirection: TextDirection.rtl,
//                       text: TextSpan(
//                         children: _buildAyahList(currentAyahList, surahList),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               _buildPaginationControls(ref, context, currentPage, totalPages),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   bool isLandscape() {
//     return WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.aspectRatio > 1;
//   }

//   List<TextSpan> _buildAyahList(List<Ayah> currentAyahList, List<Surah> surahList) {
//     return currentAyahList.expand((ayah) {
//       String namaSurah = surahList
//           .firstWhere((surah) => surah.nomor == ayah.nomorSurah)
//           .namaLatin;

//       bool isFirstAyah = surahList
//               .firstWhere((surah) => surah.nomor == ayah.nomorSurah)
//               .ayat
//               .first
//               .nomorAyat ==
//           ayah.nomorAyat;

//       bool isLastAyah = surahList
//               .firstWhere((surah) => surah.nomor == ayah.nomorSurah)
//               .ayat
//               .last
//               .nomorAyat ==
//           ayah.nomorAyat;

//       return [
//         if (isFirstAyah) ...[
//           WidgetSpan(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               child: Column(
//                 children: [
//                   const Divider(thickness: 2, color: Colors.teal, indent: 50, endIndent: 50),
//                   Center(
//                     child: Text(
//                       "【 $namaSurah 】",
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.teal,
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//         TextSpan(
//           children: [
//             TextSpan(
//               text: " ${ayah.teksArab} ",
//               style: GoogleFonts.amiri(
//                 fontSize: 28,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black,
//               ),
//             ),
//             WidgetSpan(
//               alignment: PlaceholderAlignment.middle,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 5),
//                 child: Container(
//                   width: 28,
//                   height: 28,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.teal, width: 1),
//                     color: Colors.white,
//                   ),
//                   child: Center(
//                     child: Text(
//                       "${ayah.nomorAyat}",
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.teal,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const WidgetSpan(child: SizedBox(height: 12)),
//           ],
//         ),
//         if (isLastAyah) ...[
//           WidgetSpan(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               child: Divider(
//                 thickness: 2,
//                 color: Colors.teal,
//                 indent: 50,
//                 endIndent: 50,
//               ),
//             ),
//           ),
//           WidgetSpan(
//             child: Center(
//               child: Padding(
//                 padding: const EdgeInsets.only(top: 8, bottom: 12),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.star, color: Colors.teal, size: 18),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8),
//                       child: Text(
//                         "【 $namaSurah 】",
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.teal,
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                     ),
//                     const Icon(Icons.star, color: Colors.teal, size: 18),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       );
//     }).toList();
//   }

//   Widget _buildPaginationControls(WidgetRef ref, BuildContext context, int currentPage, int totalPages) {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           ElevatedButton(
//             onPressed: currentPage > 0
//                 ? () => ref.read(quranPaginationProvider.notifier).previousPage()
//                 : null,
//             child: const Text("Prev"),
//           ),
//           Row(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.search, color: Colors.teal),
//                 onPressed: () => _showGoToPageDialog(context, ref, totalPages),
//               ),
//               Text(
//                 "Hal: ${currentPage + 1} / $totalPages",
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           ElevatedButton(
//             onPressed: currentPage < totalPages - 1
//                 ? () => ref.read(quranPaginationProvider.notifier).nextPage(totalPages)
//                 : null,
//             child: const Text("Next"),
//           ),
//         ],
//       ),
//     );
//   }
// }
