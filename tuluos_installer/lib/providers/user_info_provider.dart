import 'package:flutter_riverpod/flutter_riverpod.dart';

// enum LocaleInfo { region, zone, locale }

class UserInfoNotifier extends StateNotifier<Map<String, String>> {
  UserInfoNotifier()
      : super({
          "FullName": "",
          "UserName": "",
          "HostName": "TuluOS",
          "UserPassword": "",
          "RootPassword": ""
        });

  void addUserInfo(String key, String value) {
    var newState = {...state};

    newState[key] = value;
    state = {...newState};
  }
}

final userInfoProvider =
    StateNotifierProvider<UserInfoNotifier, Map<String, String>>(
        (ref) => UserInfoNotifier());
