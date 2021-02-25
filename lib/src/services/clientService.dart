import 'dart:convert';

import 'package:delivery_app/src/models/client.dart';
import 'package:delivery_app/src/utils/const.dart';

import 'package:http/http.dart' as http;

class ClientService {
  final Map<String, String> documentRequest = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Authorization':
        "Bearer 23e69d028b1b648589cfd7dcdd098adefde53715a680d4810a1370f3391524c1"
  };
  //tu server esta andando?

  // final urlSearchDNI = "https://apiperu.dev/api/dni/";
  // final urlSearchRUC = "https://apiperu.dev/api/ruc/";
  final urlSearchDNI =
      "http://grupopcsystems.xyz/api/GHieD96xE0lrwjbRWDsvzIELebuWL3UiUONO1pfVjtPk2GqVmM/dni/";
  final urlSearchRUC =
      "http://grupopcsystems.xyz/api/GHieD96xE0lrwjbRWDsvzIELebuWL3UiUONO1pfVjtPk2GqVmM/ruc/";
  // final urlSearchDNI = "$globalUrl/api/services/dni/";
  // final urlSearchRUC = "$globalUrl/api/services/ruc/";
  final urlSearchByName =
      "$globalUrl/api/persons/customers/records?column=name&page=1&value=";
  final urlSearchByDocument =
      "$globalUrl/api/persons/customers/records?column=number&page=1&value=";

  Future<int> idCustomerFromClient(String query) async {
    http.Response response = await http.get("$urlSearchByDocument$query",
        headers: globalRequestHeaders);
    var results = json.decode(response.body)['data'];

    if (results.isEmpty) {
      return null;
    }
    List<Client> _results =
        results.map<Client>((e) => Client.fromJson(e)).toList();

    return _results.first.id;
  }

  Future<List<Client>> search(String field, String query) async {
    try {
      if (field == "DOCUMENT") {
        http.Response response = await http.get("$urlSearchByDocument$query",
            headers: globalRequestHeaders);
        List<Client> results = json
            .decode(response.body)['data']
            .map<Client>((e) => Client.fromJson(e))
            .toList();
        print(response.body);
        return results;
      } else {
        http.Response response = await http.get("$urlSearchByName$query",
            headers: globalRequestHeaders);
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
      response = await http.get("$urlSearchDNI$document");
      _responseData = json.decode(response.body);
      if (_responseData['success']) {
        return new Client.fromDNI(_responseData['data'], document);
      } else {
        return new Client();
      }
    } else {
      response = await http.get("$urlSearchRUC$document");
      _responseData = json.decode(response.body);

      if (_responseData['success']) {
        return new Client.fromRUC(_responseData['data'], document);
      } else {
        return new Client();
      }
    }
  }
}
