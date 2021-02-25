import 'dart:convert';
import 'package:delivery_app/src/models/order.dart';
import 'package:delivery_app/src/utils/const.dart';
import 'package:http/http.dart';

class OrdersService {
  final urlOrders = "$globalUrl/api/order-notes/lists";

  Future<List<Order>> getAllOrders() async {
    Response response = await get(urlOrders, headers: globalRequestHeaders);
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
