import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TafsirPage extends StatefulWidget {
  const TafsirPage({super.key});

  @override
  _TafsirPageState createState() => _TafsirPageState();
}

class _TafsirPageState extends State<TafsirPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tafsir Quran", style: GoogleFonts.poppins()),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
      ),
      backgroundColor: Colors.teal.shade50, // Latar belakang lembut
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image.asset(
              //   'assets/icons/coming-soon.png', // Pastikan ikon ada di folder assets
              //   width: 200,
              // ),
              const SizedBox(height: 20),
              Text(
                "Coming Soon",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Fitur ini sedang dalam pengembangan.\nTunggu update terbaru dari kami!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                label: const Text("Kembali"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
