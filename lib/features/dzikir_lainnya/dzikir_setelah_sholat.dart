import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranku_offline/core/models/dzikir_setelah_sholat.dart';
import 'package:quranku_offline/core/providers/dzikir/dzikir_setelah_sholat_provider.dart';
import 'package:quranku_offline/features/dzikir_lainnya/widget/dzikir_card_setelah_sholat.dart';
import 'package:quranku_offline/features/widget/shimmer_loading.dart';

class DzikirSetelahSholatPage extends ConsumerWidget {
  const DzikirSetelahSholatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dzikirSetelahSholatList = ref.watch(dzikirSetelahSholatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dzikir Setelah Sholat",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor:
          Colors.teal.shade50, // Background dengan nuansa hijau lembut
      body: Column(
        children: [
          Expanded(
            child: dzikirSetelahSholatList.isEmpty
                ? const Center(
                    child: ShimmerLoading(
                    // color: Colors.teal,
                    itemCount: 8,
                  ))
                : ListView.builder(
                    itemCount: dzikirSetelahSholatList.length,
                    itemBuilder: (context, index) {
                      DzikirSetelahSholat dzikir =
                          dzikirSetelahSholatList[index];
                      return DzikirCardSetelahSholat(dzikir: dzikir);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
