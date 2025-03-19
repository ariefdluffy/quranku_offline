import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranku_offline/core/models/dzikir_petang_model.dart';
import 'package:quranku_offline/core/providers/dzikir/dzikir_petang_provider.dart';
import 'package:quranku_offline/features/dzikir_petang/widget/dzikir_card.dart';
import 'package:quranku_offline/features/widget/shimmer_loading.dart';

class DzikirPetangPage extends ConsumerWidget {
  const DzikirPetangPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dzikirList = ref.watch(dzikirPetangProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dzikir Petang",
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
                horizontal: 12, vertical: 12), // Tambahkan padding biar rapi
            child: const Text(
              "Waktunya menurut pendapat yang paling tepat adalah dari tenggelam matahari atau waktu Maghrib hingga pertengahan malam. Pertengahan malam dihitung dari waktu Maghrib hingga Shubuh, taruhlah sekitar 10 jam, sehingga pertengahan malam sekitar jam 11 malam",
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
                    itemCount: 10,
                  ))
                : ListView.builder(
                    itemCount: dzikirList.length,
                    itemBuilder: (context, index) {
                      DzikirPetang dzikir = dzikirList[index];
                      return DzikirPetangCard(dzikir: dzikir);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
