import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AdBannerState();
  }
}

class _AdBannerState extends State<AdBanner> {
  final bool _isDebug = true;
  // final AdSize _adSize = AdSize.banner;
  // String _adUnitId = '';
  // BannerAd? _bannerAd;

  @override
  void initState() {
    // _adUnitId = _isDebug
    //     ? 'ca-app-pub-3940256099942544/2435281174' // for testing ad on iOS
    //     : Platform.isIOS
    //         ? 'ca-app-pub-2501695247150172/7859270807' // for App store
    //         : ''; // for Google Play store
    // if (_adUnitId.isNotEmpty) {
    //   _loadAd();
    // }
    super.initState();
  }

  @override
  void dispose() {
    // _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: SizedBox(
      // width: _adSize.width.toDouble(),
      // height: _adSize.height.toDouble(),
      // child: _bannerAd == null ? const SizedBox.shrink() : AdWidget(ad: _bannerAd!),
    ),);
  }

  // void _loadAd() {
  //   final bannerAd = BannerAd(
  //     size: _adSize,
  //     adUnitId: _adUnitId,
  //     listener: BannerAdListener(
  //       onAdLoaded: (ad) {
  //         if (!mounted) {
  //           ad.dispose();
  //           return;
  //         }
  //         setState(() {
  //           _bannerAd = ad as BannerAd;
  //         });
  //       },
  //       onAdFailedToLoad: (ad, error) {
  //         debugPrint('$runtimeType _loadAd failed: $error');
  //         ad.dispose();
  //       },
  //     ),
  //     request: const AdRequest(),
  //   );
  //   bannerAd.load();
  // }
}
