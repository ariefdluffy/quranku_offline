import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

final bannerAdProvider =
    StateNotifierProvider<BannerAdNotifier, BannerAd?>((ref) {
  final provider = BannerAdNotifier();
  return provider;
});

final interstitialAdProvider =
    StateNotifierProvider<InterstitialAdNotifier, InterstitialAd?>((ref) {
  return InterstitialAdNotifier();
});

class InterstitialAdNotifier extends StateNotifier<InterstitialAd?> {
  InterstitialAdNotifier() : super(null) {
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId:
          'ca-app-pub-2393357737286916/6950010590', // ✅ Ganti dengan ID asli
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => state = ad,
        onAdFailedToLoad: (error) => state = null,
      ),
    );
  }

  void showAd() {
    if (state != null) {
      state!.show();
      _loadInterstitialAd(); // ✅ Muat ulang iklan setelah ditampilkan
    }
  }
}

class BannerAdNotifier extends StateNotifier<BannerAd?> {
  BannerAdNotifier() : super(null) {
    _loadBannerAd();
  }

  void _loadBannerAd() async {
    final BannerAd banner = BannerAd(
      size: AdSize.banner,
      adUnitId:
          'ca-app-pub-2393357737286916/9178085661', // ✅ Ganti dengan ID asli
      listener: BannerAdListener(
        onAdLoaded: (ad) => state = ad as BannerAd,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          state = null;
        },
      ),
      request: const AdRequest(),
    );
    banner.load();
  }

  void reloadAd() {
    state?.dispose(); // Hapus instance sebelumnya
    _loadBannerAd(); // Muat ulang iklan baru
  }
}

final bannerAdProviderPerSurah = Provider.autoDispose<BannerAd?>((ref) {
  final BannerAd bannerAd = BannerAd(
    size: AdSize.banner,
    adUnitId:
        'ca-app-pub-2393357737286916/2808898682', // ✅ Ganti dengan ID Asli
    listener: BannerAdListener(
      onAdLoaded: (ad) => ref.onDispose(() => ad.dispose()),
      onAdFailedToLoad: (ad, error) {
        Logger().e("Ad Failed to Load: $error");
        ad.dispose();
      },
    ),
    request: const AdRequest(),
  );

  bannerAd.load(); // ✅ Pastikan iklan dimuat sebelum ditampilkan
  return bannerAd;
});
