import 'dart:convert';

import 'package:delivery_app/src/utils/const.dart';
import 'package:http/http.dart';

class RegisterService {
  final urlUpdateClient = "$globalUrl/api/perfil";
  final urlRegisterCustomers = "$globalUrl/api/persons";

  final urlRegisterClient = "$globalUrl/api/ecommerce/storeUser";
  Future<Map<String, dynamic>> register(Map body) async {
    Response response = await post(urlRegisterCustomers,
        body: json.encode(body), headers: globalRequestHeaders);

    if (response.statusCode == 200) {
      int id = json.decode(response.body)['id'];

      return {"success": true, "id": id};
    }

    return {"success": false};
  }

  Future<bool> registerClient(Map body) async {
    Response response = await post(urlRegisterClient,
        body: json.encode(body), headers: globalRequestHeaders);

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<bool> update(Map body) async {
    Response response = await post(urlRegisterCustomers,
        body: json.encode(body), headers: globalRequestHeaders);

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<bool> updateClient(Map body) async {
    Response response = await post(urlUpdateClient,
        body: json.encode(body), headers: globalRequestHeaders);

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }
}
