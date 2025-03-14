import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:quranku_offline/features/interstitial_ad_page.dart';
import 'package:quranku_offline/features/utils/device_info_helper.dart';
import 'package:quranku_offline/features/utils/tele_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final DeviceInfoHelper deviceInfoHelper = DeviceInfoHelper(
    telegramHelper: TelegramHelper(
      botToken:
          '7678341666:AAH_6GTin6WCzxx0zOoySoeZfz6b8FgRfFU', // Ganti dengan token bot Anda
      chatId: '111519789', // Ganti dengan chat ID Anda
    ),
  );
  bool isLoading = true;

  Future<void> _loadAndSendDeviceInfo() async {
    try {
      await deviceInfoHelper.getAndSendDeviceInfo();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Logger().e(e);
    }
  }

  final InterstitialAdHelper _adHelper = InterstitialAdHelper();

  /// 🔹 Tangani event "Back"
  bool onWillPop() {
    _adHelper.showAd(context);
    return false; // ❌ Cegah navigasi langsung tanpa menampilkan iklan
  }

  @override
  void initState() {
    super.initState();
    _loadAndSendDeviceInfo();
    _adHelper.loadAd(() {
      Navigator.pop(context); // 🔄 Kembali ke Home setelah iklan ditutup
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            onWillPop();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Al-Quran Offline"),
          ),
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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email,
                          size: 16, color: Colors.deepPurpleAccent),
                      SizedBox(width: 8),
                      Text("miftahularif.dev@gmail.com",
                          style: TextStyle(
                              color: Colors.deepPurpleAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      children: [
                        const TextSpan(
                            text:
                                "© 2025 Al-Qur-an Offline V1.1.1 - \nDibuat dengan ❤️ oleh "),
                        TextSpan(
                          text: "Miftahularif",
                          style: const TextStyle(
                            color: Colors.blue, // Warna teks yang dapat diklik
                            decoration: TextDecoration
                                .underline, // Garis bawah untuk menunjukkan bahwa teks dapat diklik
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Fungsi untuk mengirim email
                              _sendEmail();
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

// 🔹 Fungsi untuk mengirim email ke developer
void _sendEmail() async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: 'miftahularif.dev@gmail.com',
    query: 'subject=Dukungan Aplikasi Al-Quran Offline',
  );

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  } else {
    debugPrint("❌ Tidak dapat membuka email.");
  }
}
