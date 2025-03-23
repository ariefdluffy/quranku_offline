import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quranku_offline/features/dzikir_lainnya/dzikir_setelah_sholat.dart';
import 'package:quranku_offline/features/dzikir_lainnya/tafsir/tafsir_page.dart';

class HomeDzikirLainnyaPage extends StatefulWidget {
  const HomeDzikirLainnyaPage({super.key});

  @override
  State<HomeDzikirLainnyaPage> createState() => _HomeDzikirLainnyaPageState();
}

class _HomeDzikirLainnyaPageState extends State<HomeDzikirLainnyaPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
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
        title: Text("Dzikir & Lainnya", style: GoogleFonts.poppins()),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.tealAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard(
                    "Dzikir setelah Sholat", Icons.mosque, Colors.teal, () {
                  Navigator.push(
                    context,
                    (MaterialPageRoute(builder: (context) {
                      return const DzikirSetelahSholatPage();
                    })),
                  );
                }),
                _buildMenuCard("Tafsir Quran", Icons.menu_book, Colors.orange,
                    () {
                  Navigator.push(
                    context,
                    (MaterialPageRoute(builder: (context) {
                      return const TafsirPage();
                    })),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        shadowColor: color.withOpacity(0.5),
        color: color,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
