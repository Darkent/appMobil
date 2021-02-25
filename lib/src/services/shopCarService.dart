import 'dart:convert';
import 'package:delivery_app/src/models/client.dart';
import 'package:delivery_app/src/models/products.dart';
import 'package:delivery_app/src/models/purchase.dart';
import 'package:delivery_app/src/models/user.dart';
import 'package:delivery_app/src/providers/preferences.dart';
import 'package:delivery_app/src/utils/const.dart';

import 'package:http/http.dart' as http;

class ShopCarService {
  PreferencesUser preferencesUser = PreferencesUser();

  final tokenAdmin = "$globalUrl/api/users/type";
  final urlFirebase = "https://fcm.googleapis.com/fcm/send";
  final urlPurchases = "$globalUrl/api/order-notes/user/";
  final urlPaymentStatus = "$globalUrl/api/order-notes/status";
  final urlPayment = "$globalUrl/api/order-notes";
  final idProduct = "$globalUrl/api/items/record/";

  final keyFCM = "$globalUrl/api/companies/record";
  String formatDate(DateTime _date) {
    return "${_format(_date.year)}-${_format(_date.month)}-${_format(_date.day)}";
  }

  String _format(int b) {
    String z = b.toString();

    return z.length == 1 ? "0" + z : z;
  }

  Future<bool> sendProducts(List<Products> products, double subtotal,
      Client client, String document, DateTime date, String externalid) async {
    List<Map> allProducts = [];
    User user;
    for (int i = 0; i < products.length; i++) {
      Map temp = await getProduct(products[i]);
      allProducts.add(temp);
    }

    String _document = document == "FACTURA"
        ? "01"
        : document == "BOLETA DE VENTA"
            ? "03"
            : "08";
    user = User.fromjson(json.decode(preferencesUser.userData));

    String _date = date.toString().split(" ")[0];

    Map body = {
      "document": _document,
      "document_number": "",
      "observation": "",
      "prefix": "PD",
      "establishment_id": 1,
      "date_of_issue": _date,
      "time_of_issue": "11:49:40",
      "customer_id": client.id, //si seras jeje
      "currency_type_id": "PEN",
      "purchase_order": null,
      "exchange_rate_sale": "1",
      "total_prepayment": 0,
      "total_charge": 0,
      "total_discount": 0,
      "total_exportation": 0,
      "total_free": 0,
      "total_taxed": (subtotal / 1.18).toStringAsFixed(2),
      "total_unaffected": 0,
      "total_exonerated": 0,
      "total_igv": ((subtotal / 1.18) * 0.18).toStringAsFixed(2),
      "total_base_isc": 0,
      "total_isc": 0,
      "total_base_other_taxes": 0,
      "total_other_taxes": 0,
      "total_taxes": ((subtotal / 1.18) * 0.18).toStringAsFixed(2),
      "total_value": (subtotal / 1.18).toStringAsFixed(2),
      "total": subtotal,
      "operation_type_id": null,
      "date_of_due": _date,
      "delivery_date": _date,
      "items": allProducts,
      "charges": [],
      "discounts": [],
      "attributes": [],
      "guides": [],
      "payment_method_type_id": "10",
      "additional_information": null,
      "shipping_address": "",
      "actions": {"format_pdf": "a4"},
      "user_id": user.id
    };

    http.Response response = await http.post(urlPayment,
        body: json.encode(body), headers: globalRequestHeaders);

    Map bodyStatus = {
      "external_id": json.decode(response.body)['data']["external_id"]
    };
    if (response.statusCode == 200) {
      //Enviar para cambiar el status del pedido--------
      http.Response responseStatus = await http.post(urlPaymentStatus,
          body: json.encode(bodyStatus), headers: globalRequestHeaders);
      //--------------- ---------------------------------

      if (responseStatus.statusCode == 200) {
        List<dynamic> temporal = preferencesUser.purchases;
        temporal.add(json.decode(response.body)['data']['external_id']);
        List<String> temporal2 = [];
        temporal.forEach((element) {
          temporal2.add(element.toString());
        });
        preferencesUser.purchases = temporal2;

        if (user.type != "admin") {
          await sendNotification(client.name);
        }
        return true;
      }
    }

    return false;
  }

  Future sendNotification(String clientName) async {
    String key = await getKey();

    Map<String, String> _headers = {
      "Content-type": "application/json",
      "Authorization": "key=$key"
    };
    Map _body = {
      "to": "/topics/newOrder",
      "priority": "high",
      "notification": {
        "title": clientName.toUpperCase(),
        "body": "Acabo de realizar un pedido!",
      },
      "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK"}
    };
    http.Response response = await http.post(urlFirebase,
        body: json.encode(_body), headers: _headers);

    if (response.statusCode == 200) {
    } else {}
  }

  Future<String> getToken() async {
    http.Response response =
        await http.get(tokenAdmin, headers: globalRequestHeaders);
    if (response.statusCode == 200) {
      Map parsed = json.decode(response.body);
      if (parsed['data'].isNotEmpty) {
        return parsed['data'][0]['token_firebase'];
      }
    }
    return "";
  }

  Future<String> getKey() async {
    http.Response response =
        await http.get(keyFCM, headers: globalRequestHeaders);
    if (response.statusCode == 200) {
      Map parsed = json.decode(response.body);
      if (parsed['data'].isNotEmpty) {
        return parsed['data']['key'];
      }
    }
    return "";
  }

  Future<Map> getProduct(Products product) async {
    http.Response response = await http.get("$idProduct${product.id}",
        headers: globalRequestHeaders);
    Map productReturn = {};

    productReturn =
        newProduct(json.decode(response.body)['data'], product.quantity);
    // productReturn.putIfAbsent(
    //     "sub_total", () => double.parse(product.price) * product.quantity);
    // productReturn.putIfAbsent("cantidad", () => product.quantity);

    return productReturn;
  }

//SE AGREGO
  Map newProduct(Map oldProduct, int qty) {
    return {
      "item_id": oldProduct['id'],
      "item": {
        "id": oldProduct['id'],
        "full_description": oldProduct['description'],
        "description": oldProduct['description'],
        "currency_type_id": "PEN",
        "currency_type_symbol": "S/",
        "sale_unit_price": oldProduct['sale_unit_price'],
        "purchase_unit_price": oldProduct['purchase_unit_price'],
        "unit_type_id": "NIU",
        "sale_affectation_igv_type_id": "10",
        "purchase_affectation_igv_type_id": "10",
        "is_set": false,
        "has_igv": true,
        "calculate_quantity": false,
        "item_unit_types": [],
        "warehouses": [
          {
            "warehouse_id": 1,
            "warehouse_description": "Almacén Oficina Principal",
            "stock": oldProduct['stock']
          }
        ],
        "unit_price": oldProduct['sale_unit_price'],
        "presentation": {}
      },
      "currency_type_id": "PEN",
      "quantity": qty,
      "unit_value": double.tryParse(oldProduct['sale_unit_price']) ?? 0.0,
      "affectation_igv_type_id": "10",
      "affectation_igv_type": {
        "id": "10",
        "active": 1,
        "exportation": 0,
        "free": 0,
        "description": "Gravado - Operación Onerosa"
      },
      "total_base_igv":
          ((double.tryParse(oldProduct['sale_unit_price']) ?? 0.0) * qty) /
              1.18,
      "percentage_igv": 18,
      "total_igv":
          (((double.tryParse(oldProduct['sale_unit_price']) ?? 0.0) * qty) /
                  1.18) *
              .18,
      "system_isc_type_id": null,
      "total_base_isc": 0,
      "percentage_isc": 0,
      "total_isc": 0,
      "total_base_other_taxes": 0,
      "percentage_other_taxes": 0,
      "total_other_taxes": 0,
      "total_plastic_bag_taxes": 0,
      "total_taxes":
          (((double.tryParse(oldProduct['sale_unit_price']) ?? 0.0) * qty) /
                  1.18) *
              .18,
      "price_type_id": "01",
      "unit_price": (double.tryParse(oldProduct['sale_unit_price']) ?? 0.0),
      "total_value":
          ((double.tryParse(oldProduct['sale_unit_price']) ?? 0.0) * qty) /
              1.18,
      "total_discount": 0,
      "total_charge": 0,
      "total": (double.tryParse(oldProduct['sale_unit_price']) ?? 0.0) * qty,
      "attributes": [],
      "charges": [],
      "discounts": []
    };
  }

  Future<List<Purchase>> getAllPurchases(int id) async {
    List<Purchase> temporal = [];
    http.Response response =
        await http.get("$urlPurchases$id", headers: globalRequestHeaders);

    if (response.statusCode == 200) {
      temporal = json
          .decode(response.body)['data']
          .map<Purchase>((e) => Purchase.fromJson(e))
          .toList();

      return temporal;
    }

    return [];
  }
}
