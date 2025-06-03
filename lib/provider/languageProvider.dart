import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void toggleLanguage() {
    _locale =
        _locale.languageCode == 'en' ? const Locale('ur') : const Locale('en');
    notifyListeners();
  }

  String get currentLanguageLabel =>
      _locale.languageCode == 'en' ? 'اردو' : 'EN';
}
