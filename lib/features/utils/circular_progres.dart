import 'package:flutter/material.dart';

class IconCircularProgress extends StatelessWidget {
  final IconData icon;
  final double progress;

  IconCircularProgress({required this.icon, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: progress,
          strokeWidth: 6,
          valueColor: AlwaysStoppedAnimation(Colors.green),
        ),
        Icon(icon, color: Colors.green),
      ],
    );
  }
}
