import 'dart:convert';

import 'package:delivery_app/src/providers/preferences.dart';
import 'package:http/http.dart';

class LoginService {
  final PreferencesUser preferencesUser = PreferencesUser();
  static const String url = "http://venta.grupopcsystems.online/api/login";

  final Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };

  Future<bool> loginRequest(Map body) async {
    final Response response =
        await post(url, body: json.encode(body), headers: requestHeaders);

    final parsed = jsonDecode(response.body);

    try {
      if (response.statusCode == 200 && parsed['success']) {
        preferencesUser.userData = parsed;

        return true;
      } else if (response.statusCode == 500) {
        return false;
      }
    } catch (e) {
      return false;
    }
    return false;
  }
}
