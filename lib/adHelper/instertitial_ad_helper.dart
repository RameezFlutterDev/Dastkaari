import 'dart:ui';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdHelper {
  static InterstitialAd? _interstitialAd;
  static VoidCallback? _onAdClosedCallback;

  // Load an Interstitial Ad
  static void loadAd() {
    InterstitialAd.load(
      adUnitId:
          'ca-app-pub-5443412817411779/5190320335', // Replace with your AdMob ID
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;

          // Handle ad dismissal
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              loadAd(); // Load a new ad for the next download

              // Execute callback when the ad is closed
              if (_onAdClosedCallback != null) {
                _onAdClosedCallback!();
                _onAdClosedCallback = null; // Clear callback after execution
              }
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              loadAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  // Show the Ad and set the callback to run after it is closed
  static void showAd(VoidCallback onAdClosed) {
    if (_interstitialAd != null) {
      _onAdClosedCallback = onAdClosed;
      _interstitialAd!.show();
    } else {
      print('Ad not ready yet, opening file directly.');
      onAdClosed(); // Open the file immediately if the ad is not ready
    }
  }
}
