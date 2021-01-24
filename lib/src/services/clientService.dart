import 'dart:convert';

import 'package:delivery_app/src/models/client.dart';

import 'package:http/http.dart' as http;

class ClientService {
  final Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Authorization': "Bearer zXxR5P5vJB25p9IulQOoh1zoN4RWDK3rXwAbUSooV28qMBXkqi"
  };

  final Map<String, String> documentRequest = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Authorization':
        "Bearer 23e69d028b1b648589cfd7dcdd098adefde53715a680d4810a1370f3391524c1"
  };
  //tu server esta andando?

  final urlSearchDNI = "https://apiperu.dev/api/dni/";
  final urlSearchRUC = "https://apiperu.dev/api/ruc/";
  // final urlSearchDNI = "http://venta.grupopcsystems.online/api/services/dni/";
  // final urlSearchRUC = "http://venta.grupopcsystems.online/api/services/ruc/";
  final urlSearchByName =
      "http://venta.grupopcsystems.online/api/persons/customers/records?column=name&page=1&value=";
  final urlSearchByDocument =
      "http://venta.grupopcsystems.online/api/persons/customers/records?column=number&page=1&value=";

  Future<int> idCustomerFromClient(String query) async {
    http.Response response =
        await http.get("$urlSearchByDocument$query", headers: requestHeaders);
    List<Client> results = json
        .decode(response.body)['data']
        .map<Client>((e) => Client.fromJson(e))
        .toList();
    return results.first.id;
  }

  Future<List<Client>> search(String field, String query) async {
    try {
      if (field == "DOCUMENT") {
        http.Response response = await http.get("$urlSearchByDocument$query",
            headers: requestHeaders);
        List<Client> results = json
            .decode(response.body)['data']
            .map<Client>((e) => Client.fromJson(e))
            .toList();
        return results;
      } else {
        http.Response response =
            await http.get("$urlSearchByName$query", headers: requestHeaders);
        List<Client> results = json
            .decode(response.body)['data']
            .map<Client>((e) => Client.fromJson(e))
            .toList();
        return results;
      }
    } catch (e) {
      return new List<Client>();
    }
  }

  Future<Client> getData(bool field, String document) async {
    http.Response response;
    var _responseData;
    if (field) {
      response =
          await http.get("$urlSearchDNI$document", headers: documentRequest);
      _responseData = json.decode(response.body);
      if (_responseData['success']) {
        return new Client.fromDNI(_responseData['data'], document);
      } else {
        return new Client();
      }
    } else {
      response =
          await http.get("$urlSearchRUC$document", headers: documentRequest);
      _responseData = json.decode(response.body);

      if (_responseData['success']) {
        return new Client.fromRUC(_responseData['data'], document);
      } else {
        return new Client();
      }
    }
  }
}
