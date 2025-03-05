import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationNotifier extends StateNotifier<int> {
  NavigationNotifier() : super(0); // Halaman default: "Per Surah"

  void changePage(int index) {
    state = index;
  }
}

final navigationProvider =
    StateNotifierProvider<NavigationNotifier, int>((ref) {
  return NavigationNotifier();
});
