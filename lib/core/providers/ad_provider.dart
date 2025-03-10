import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final bannerAdProvider =
    StateNotifierProvider<BannerAdNotifier, BannerAd?>((ref) {
  return BannerAdNotifier();
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

  void _loadBannerAd() {
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
}
