import 'dart:convert';

import 'package:delivery_app/src/utils/const.dart';
import 'package:http/http.dart' as http;

final urlDocuments = "$globalUrl/api/documents/record/";
final urlNoteSales = "$globalUrl/api/sale-note/record/";
final Map<String, String> globalRequestHeaders = {
  'Content-type': 'application/json',
  'Accept': 'application/json',
  'Authorization': "Bearer zXxR5P5vJB25p9IulQOoh1zoN4RWDK3rXwAbUSooV28qMBXkqi"
};
Future<String> urlPdf(int idOrder, {bool saleNote}) async {
  http.Response response;
  if (saleNote) {
    response =
        await http.get("$urlNoteSales$idOrder", headers: globalRequestHeaders);
    Map body = json.decode(response.body);
    if (response.statusCode == 200) {
      return body['data']['external_id'];
    }
    return "";
  } else {
    response =
        await http.get("$urlDocuments$idOrder", headers: globalRequestHeaders);
    Map body = json.decode(response.body);
    if (response.statusCode == 200) {
      return body['data']['external_id'];
    }
  }

  return "";
}
