import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 80, color: Colors.teal),
              const SizedBox(height: 16),
              const Text(
                "Al-Qur'an Offline",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Membantu Anda membaca Al-Quran offline \ngratis tanpa koneksi internet.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                "© Miftahul Arif | V.1.1.0",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              // const SizedBox(height: 8),
              // Text(
              //   "V.1.1.0",
              //   style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
