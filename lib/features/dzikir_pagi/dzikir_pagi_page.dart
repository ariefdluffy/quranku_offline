import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranku_offline/features/dzikir_pagi/widget/dzikir_card.dart';
import 'package:quranku_offline/features/widget/shimmer_loading.dart';
import '../../core/models/dzikir_pagi_model.dart';
import '../../core/providers/dzikir/dzikir_pagi_provider.dart';

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
      body: Column(
        children: [
          Container(
            alignment: Alignment.center, // Menempatkan teks ke kiri
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16), // Tambahkan padding biar rapi
            child: const Text(
              "Waktunya yang utama dibaca saat masuk waktu Shubuh hingga matahari terbit. Namun boleh juga dibaca sampai matahari akan bergeser ke barat (mendekati waktu Zhuhur)",
              style: TextStyle(
                fontSize: 14,
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: dzikirList.isEmpty
                ? const Center(
                    child: ShimmerLoading(
                    // color: Colors.teal,
                    itemCount: 4,
                  ))
                : ListView.builder(
                    itemCount: dzikirList.length,
                    itemBuilder: (context, index) {
                      DzikirPagi dzikir = dzikirList[index];
                      return DzikirCard(dzikir: dzikir);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
