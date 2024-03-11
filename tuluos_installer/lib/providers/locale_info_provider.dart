import 'package:flutter_riverpod/flutter_riverpod.dart';

// enum LocaleInfo { region, zone, locale }

class LocaleInfoNotifier extends StateNotifier<Map<String, String?>> {
  LocaleInfoNotifier()
      : super({"Region": "Asia", "Zone": "Kolkata", "Locale": "en_IN UTF-8"});

  void addLocaleInfo(String key, String? value) {
    var newState = {...state};

    newState[key] = value;
    state = {...newState};
  }
}

final localeInfoProvider =
    StateNotifierProvider<LocaleInfoNotifier, Map<String, String?>>(
        (ref) => LocaleInfoNotifier());
