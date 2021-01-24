import 'dart:convert';
import 'package:delivery_app/src/models/order.dart';
import 'package:http/http.dart';

class OrdersService {
  final Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Authorization': "Bearer zXxR5P5vJB25p9IulQOoh1zoN4RWDK3rXwAbUSooV28qMBXkqi"
  };
  final urlOrders = "http://venta.grupopcsystems.online/api/order-notes/lists";

  Future<List<Order>> getAllOrders() async {
    Response response = await get(urlOrders, headers: requestHeaders);
    // Map body = json.decode(response.body);

    if (response.statusCode == 200) {
      Map body = json.decode(response.body);

      List<Order> results =
          body['data'].map<Order>((e) => Order.fromJson(e)).toList();

      return results;
    } else {
      return [];
    }
  }
}
