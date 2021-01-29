import 'dart:convert';

import 'package:http/http.dart';

class RegisterService {
  final Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Authorization': "Bearer zXxR5P5vJB25p9IulQOoh1zoN4RWDK3rXwAbUSooV28qMBXkqi"
  };
  final urlUpdateClient = "http://venta.grupopcsystems.online/api/perfil";
  final urlRegisterCustomers = "http://venta.grupopcsystems.online/api/persons";

  final urlRegisterClient =
      "http://venta.grupopcsystems.online/api/ecommerce/storeUser";
  Future<Map<String, dynamic>> register(Map body) async {
    print(body);
    Response response = await post(urlRegisterCustomers,
        body: json.encode(body), headers: requestHeaders);

    if (response.statusCode == 200) {
      int id = json.decode(response.body)['id'];

      return {"success": true, "id": id};
    }

    return {"success": false};
  }

  Future<bool> registerClient(Map body) async {
    Response response = await post(urlRegisterClient,
        body: json.encode(body), headers: requestHeaders);

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<bool> update(Map body) async {
    Response response = await post(urlRegisterCustomers,
        body: json.encode(body), headers: requestHeaders);

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<bool> updateClient(Map body) async {
    Response response = await post(urlUpdateClient,
        body: json.encode(body), headers: requestHeaders);

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }
}
