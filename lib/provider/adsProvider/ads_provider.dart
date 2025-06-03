import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdProvider extends ChangeNotifier {
  late BannerAd _topBannerAd;
  late BannerAd _bottomBannerAd;
  bool _isTopBannerAdLoaded = false;
  bool _isBottomBannerAdLoaded = false;

  bool get isTopBannerAdLoaded => _isTopBannerAdLoaded;
  bool get isBottomBannerAdLoaded => _isBottomBannerAdLoaded;
  BannerAd get topBannerAd => _topBannerAd;
  BannerAd get bottomBannerAd => _bottomBannerAd;

  AdProvider() {
    _loadTopBannerAd();
    _loadBottomBannerAd();
  }

  void _loadTopBannerAd() {
    _topBannerAd = BannerAd(
      adUnitId: "ca-app-pub-5443412817411779/2122192884",
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isTopBannerAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          print('Top banner failed to load: $error');
          ad.dispose();
        },
      ),
    );
    _topBannerAd.load();
  }

  void _loadBottomBannerAd() {
    _bottomBannerAd = BannerAd(
      adUnitId: "ca-app-pub-5443412817411779/6537276159",
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBottomBannerAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          print('Bottom banner failed to load: $error');
          ad.dispose();
        },
      ),
    );
    _bottomBannerAd.load();
  }

  @override
  void dispose() {
    _topBannerAd.dispose();
    _bottomBannerAd.dispose();
    super.dispose();
  }
}
