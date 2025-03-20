import 'package:flutter_riverpod/flutter_riverpod.dart';

final downloadProgressProvider = StateProvider<double>((ref) => 0.0);
final downloadMessageProvider =
    StateProvider<String>((ref) => "Menunggu unduhan...");
