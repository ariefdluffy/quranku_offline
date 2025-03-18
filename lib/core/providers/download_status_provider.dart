import 'package:flutter_riverpod/flutter_riverpod.dart';

final downloadStatusProvider = StateProvider<bool>((ref) => false);
final downloadProgressProvider = StateProvider<double>((ref) => 0.0);
