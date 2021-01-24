import 'dart:convert';

import 'package:http/http.dart' as http;

final urlDocuments = "http://venta.grupopcsystems.online/api/documents/record/";
final Map<String, String> requestHeaders = {
  'Content-type': 'application/json',
  'Accept': 'application/json',
  'Authorization': "Bearer zXxR5P5vJB25p9IulQOoh1zoN4RWDK3rXwAbUSooV28qMBXkqi"
};
Future<String> urlPdf(int idOrder) async {
  http.Response response =
      await http.get("$urlDocuments$idOrder", headers: requestHeaders);

  if (response.statusCode == 200) {
    Map body = json.decode(response.body);

    return body['data']['external_id'];
  }

  return "";
}
