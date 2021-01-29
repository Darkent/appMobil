import 'dart:convert';

import 'package:http/http.dart' as http;

final urlDocuments = "http://venta.grupopcsystems.online/api/documents/record/";
final urlNoteSales = "http://venta.grupopcsystems.online/api/sale-note/record/";
final Map<String, String> requestHeaders = {
  'Content-type': 'application/json',
  'Accept': 'application/json',
  'Authorization': "Bearer zXxR5P5vJB25p9IulQOoh1zoN4RWDK3rXwAbUSooV28qMBXkqi"
};
Future<String> urlPdf(int idOrder, {bool saleNote}) async {
  http.Response response;
  if (saleNote) {
    response = await http.get("$urlNoteSales$idOrder", headers: requestHeaders);
    Map body = json.decode(response.body);
    if (response.statusCode == 200) {
      return body['data']['external_id'];
    }
    return "";
  } else {
    response = await http.get("$urlDocuments$idOrder", headers: requestHeaders);
    Map body = json.decode(response.body);
    if (response.statusCode == 200) {
      return body['data']['external_id'];
    }
  }

  print(response.body);

  return "";
}
