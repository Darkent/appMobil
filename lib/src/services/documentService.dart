import 'dart:convert';

import 'package:delivery_app/src/models/client.dart';
import 'package:delivery_app/src/models/order.dart';
import 'package:delivery_app/src/models/products.dart';
import 'package:delivery_app/src/models/series.dart';
import 'package:delivery_app/src/models/user.dart';
import 'package:delivery_app/src/utils/numerosLetras.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:delivery_app/src/providers/preferences.dart';

class DocumentService {
  PreferencesUser preferencesUser = PreferencesUser();
  final Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Authorization': "Bearer zXxR5P5vJB25p9IulQOoh1zoN4RWDK3rXwAbUSooV28qMBXkqi"
  };
  final keyFCM = "http://venta.grupopcsystems.online/api/companies/record";
  final urlFirebase = "https://fcm.googleapis.com/fcm/send";
  final urlTokenUser =
      "http://venta.grupopcsystems.online/api/users/filter?column=number&page=1&value=";
  final url = "http://venta.grupopcsystems.online/api/documents";
  final urlClients = "http://venta.grupopcsystems.online/api/generar_documents";
  final urlSaleNotePdf =
      "http://venta.grupopcsystems.online/api/sale-note/record/";
  final urlSaleNote = "http://venta.grupopcsystems.online/api/sale-note";
  final urlUpdate =
      "http://venta.grupopcsystems.online/api/orders/status/update";
  final urlUpdateItems =
      "http://venta.grupopcsystems.online/api/order-notes/update";

  final urlSeries = "http://venta.grupopcsystems.online/api/documents/tables";

  Future<List<Series>> getSeries() async {
    http.Response response = await http.get(urlSeries, headers: requestHeaders);
    if (response.statusCode == 200) {
      Map parsed = json.decode(response.body);
      return parsed['series']
          .map<Series>((serie) => Series.fromJson(serie))
          .toList();
    }
    return [];
  }

  Future<String> getKey() async {
    http.Response response = await http.get(keyFCM, headers: requestHeaders);
    if (response.statusCode == 200) {
      Map parsed = json.decode(response.body);
      if (parsed['data'].isNotEmpty) {
        return parsed['data']['key'];
      }
    }
    return "";
  }

  Future<bool> deletedItems(Map order) async {
    // List<Map> _items = [];
    // items.forEach((element) {
    //   _items.add(productToMap(element));
    // });
    // Map body = {"id": id, "items": _items};
    http.Response response = await http.post(urlUpdateItems,
        body: json.encode(order), headers: requestHeaders);
    if (response.statusCode == 200) {
      Map parsed = json.decode(response.body);
      if (parsed['success']) {
        return true;
      }
    }

    return false;
  }

  Future<String> getTokenUser(String document) async {
    http.Response response = await http.get("$urlTokenUser$document");

    if (response.statusCode == 200) {
      Map parsed = json.decode(response.body);
      if (parsed['data'].isNotEmpty) {
        return parsed['data'][0]['token_firebase'];
      }
    }
    return "";
  }

  Future sendNotification(String number) async {
    String key = await getKey();

    Map<String, String> _headers = {
      "Content-type": "application/json",
      "Authorization": "key=$key"
    };
    Map _body = {
      "to": "/topics/$number",
      "priority": "high",
      "notification": {
        "title": "DOCUMENTO EMITIDO",
        "body": "El documento por su pedido ya ha sido emitido.",
      },
      "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK"}
    };
    http.Response response = await http.post(urlFirebase,
        body: json.encode(_body), headers: _headers);

    if (response.statusCode == 200) {
    } else {}
  }

  //ITEMS
  Map itemsF(Products products) {
    return {
      "codigo_interno": products.internCode,
      "descripcion": products.description,
      "codigo_producto_sunat": "51121703",
      "unidad_de_medida": "NIU",
      "cantidad": products.quantity,
      "valor_unitario": double.parse(products.price) / 1.18,
      "codigo_tipo_precio": "01",
      "precio_unitario": products.price,
      "codigo_tipo_afectacion_igv": "10",
      "total_base_igv":
          (double.parse(products.price) / 1.18) * products.quantity,
      "porcentaje_igv": 18,
      "total_igv":
          ((double.parse(products.price) / 1.18) * .18) * products.quantity,
      "total_impuestos":
          ((double.parse(products.price) / 1.18) * .18) * products.quantity,
      "total_valor_item":
          (double.parse(products.price) / 1.18) * products.quantity,
      "total_item": double.parse(products.price) * products.quantity
    };
  }

  Future<bool> emitir(Map body,
      {List<Products> items, int id, bool deletedI, Order order}) async {
    http.Response response;
    if (!deletedI) {
      response = await http.post(urlClients,
          body: json.encode(body), headers: requestHeaders);
      debugPrint(response.body, wrapWidth: 1024);
      if (response.statusCode == 200) {
        sendNotification(order.number);

        return true;
      }
    } else {
      Map _body = orderUpdate(order, items);
      if (await deletedItems(_body)) {
        response = await http.post(urlClients,
            body: json.encode(body), headers: requestHeaders);

        if (response.statusCode == 200) {
          sendNotification(order.number);

          return true;
        }
      }
    }

    return false;
  }

  Future<bool> emitedNoteSale(Map body, Order order) async {
    http.Response response = await http.post(urlSaleNote,
        body: json.encode(body), headers: requestHeaders);

    if (response.statusCode == 200) {
      PreferencesUser _preferenceUser = PreferencesUser();
      debugPrint(response.body.toString(), wrapWidth: 1024);
      Map body = json.decode(response.body);

      _preferenceUser.tmpPdf = body['data']['external_id'];
      if (order.number != null) {
        sendNotification(order.number);
      }
      return true;
    }
    debugPrint(response.body, wrapWidth: 1024);
    return false;
  }

  Map documentE(
      {String serie,
      String type,
      DateTime date,
      Order order,
      List<Products> items}) {
    Customers _customers = order.customers;
    String _date = date.toString().split(" ")[0];
    String igv = (double.parse(order.subtotal.split(",").join()) * .18)
        .toStringAsFixed(2);
    String base = order.subtotal.split(",").join();
    String total = (double.parse(order.subtotal.split(",").join()) * 1.18)
        .toStringAsFixed(2);

    return {
      "type": "invoice",
      "group_id": "01",
      "user_id": 1,
      "establishment_id": 1,
      "establishment": {
        "country_id": "PE",
        "country": {"id": "PE", "description": "PERU"},
        "department_id": "05",
        "department": {"id": "-", "description": "-"},
        "province_id": "-",
        "province": {"id": "-", "description": "-"},
        "district_id": "-",
        "district": {"id": "-", "description": "-"},
        "urbanization": null,
        "address": "-",
        "email": "-",
        "telephone": "-",
        "code": "0000",
        "trade_address": null,
        "web_address": null,
        "aditional_information": null
      },
      "soap_type_id": "01",
      "state_type_id": "01",
      "ubl_version": "2.1",
      "filename": "",
      "document_type_id": type,
      "series": serie,
      "number": "#",
      "date_of_issue": _date,
      "time_of_issue": "18:40:53",
      "customer_id": order.customer.id,
      "customer": {
        "identity_document_type_id": _customers.number.length == 8 ? "1" : "6",
        "identity_document_type": {
          "id": _customers.number.length == 8 ? "1" : "6",
          "description": _customers.number.length == 8 ? "DNI" : "RUC"
        },
        "number": _customers.number ?? "-",
        "name": _customers.name ?? "-",
        "trade_name": _customers.name ?? "-",
        "country_id": _customers.countryId ?? "-",
        "country": {
          "id": _customers.country.id ?? "-",
          "description": _customers.country.description ?? "-"
        },
        "department_id": _customers.department.id ?? "-",
        "department": {
          "id": _customers.department.id ?? "-",
          "description": _customers.department.description ?? "-"
        },
        "province_id": _customers.province.id,
        "province": {
          "id": _customers.province.id ?? "-",
          "description": _customers.province.description ?? "-"
        },
        "district_id": _customers.district.id ?? "-",
        "district": {
          "id": _customers.district.id ?? "-",
          "description": _customers.district.description ?? "-"
        },
        "address": _customers.address ?? "-",
        "email": _customers.email ?? "-",
        "telephone": _customers.telephone ?? "-",
        "perception_agent": 0
      },
      "currency_type_id": "PEN",
      "purchase_order": null,
      "quotation_id": null,
      "sale_note_id": null,
      "order_note_id": order.id,
      "exchange_rate_sale": "1.000",
      "total_prepayment": "0.00",
      "total_discount": "0.00",
      "total_charge": "0.00",
      "total_exportation": "0.00",
      "total_free": "0.00",
      "total_taxed": base,
      "total_unaffected": "0.00",
      "total_exonerated": "0.00",
      "total_igv": igv,
      "total_base_isc": "0.00",
      "total_isc": "0.00",
      "total_base_other_taxes": "0.00",
      "total_other_taxes": "0.00",
      "total_plastic_bag_taxes": 0,
      "total_taxes": igv,
      "total_value": base,
      "total": total,
      "has_prepayment": 0,
      "affectation_type_prepayment": null,
      "was_deducted_prepayment": 0,
      "items": items.map<Map>((product) => newItems(product)).toList(),
      "charges": null,
      "discounts": null,
      "prepayments": null,
      "guides": null,
      "related": null,
      "perception": null,
      "detraction": null,
      "invoice": {"operation_type_id": "0101", "date_of_due": "2021-01-17"},
      "note": null,
      "hotel": [],
      "transport": [],
      "additional_information": null,
      "plate_number": null,
      "legends": [
        {"code": 1000, "value": NumeroLetras().convertir(total)}
      ],
      "actions": {
        "send_email": false,
        "send_xml_signed": true,
        "format_pdf": "a4"
      },
      "data_json": null,
      "payments": [
        {
          "id": null,
          "document_id": null,
          "date_of_payment": "2021-01-17",
          "payment_method_type_id": "01",
          "payment_destination_id": "cash",
          "reference": null,
          "payment": 0
        }
      ],
      "send_server": false
    };
  }

  Future<bool> emitirDocumentoDirectamente(Map body) async {
    http.Response response =
        await http.post(url, body: json.encode(body), headers: requestHeaders);

    if (response.statusCode == 200) {
      Map body = json.decode(response.body);
      if (body['success']) {
        PreferencesUser _preferenceUser = PreferencesUser();

        _preferenceUser.tmpPdf = body['data']['external_id'];
        return true;
      }
    }

    return false;
  }

  Map documentEmited(
      {List<Products> products,
      String series,
      Client client,
      DateTime date,
      String type,
      double total}) {
    User user;
    user = User.fromjson(json.decode(preferencesUser.userData));
    double _total = total;
    return {
      "serie_documento": series,
      "numero_documento": "#",
      "user_id": user.id,
      "fecha_de_emision": formatDate(date),
      "hora_de_emision": "10:11:11",
      "codigo_tipo_operacion": "0101",
      "codigo_tipo_documento": type,
      "codigo_tipo_moneda": "PEN",
      "fecha_de_vencimiento": formatDate(date),
      "numero_orden_de_compra": "-",
      "datos_del_cliente_o_receptor": {
        "codigo_tipo_documento_identidad":
            client.number.length == 8 ? "1" : "6",
        "numero_documento": client.number,
        "apellidos_y_nombres_o_razon_social": client.name,
        "codigo_pais": "PE",
        "ubigeo": "150101",
        "direccion": client.address ?? "-",
        "correo_electronico": client.email ?? "-",
        "telefono": client.telephone ?? "-"
      },
      "totales": {
        "total_exportacion": 0.00,
        "total_operaciones_gravadas": (_total / 1.18),
        "total_operaciones_inafectas": 0.00,
        "total_operaciones_exoneradas": 0.00,
        "total_operaciones_gratuitas": 0.00,
        "total_igv": (_total / 1.18) * .18,
        "total_impuestos": (_total / 1.18) * .18,
        "total_valor": (_total / 1.18),
        "total_venta": _total,
      },
      "items": products.map<Map>((e) => itemsF(e)).toList(),
      // "acciones": {"enviar_email": true},
      "informacion_adicional": "Forma de pago:Efectivo|Caja: 1"
    };
  }

  Map orderUpdate(Order order, List<Products> products) {
    return {
      "id": order.id,
      "date_of_issue": order.date,
      "establishment_id": 1,
      "user_id": order.userId,
      "customer_id": order.customerId,
      "currency_type_id": "PEN",
      "items": products.map<Map>((o) => updateItems(o)).toList(),
      "exchange_rate_sale": 1,
      "total_taxed": order.subtotal,
      "total_igv": order.igv,
      "total": order.total
    };
  }

  Map updateItems(Products products) {
    return {
      "id": products.id,
      "item_id": products.itemId,
      "item": {
        "id": products.itemId,
        "is_set": false,
        "has_igv": true,
        "unit_price": products.unitPrice,
        "warehouses": [
          {
            "stock": products.stock,
            "warehouse_id": 1,
            "warehouse_description": "Almacén Oficina Principal"
          }
        ],
        "description": products.description,
        "presentation": [],
        "unit_type_id": "NIU",
        "item_unit_types": [],
        "sale_unit_price": products.unitPrice,
        "currency_type_id": "PEN",
        "full_description": products.description,
        "calculate_quantity": false,
        "purchase_unit_price": "110.000000",
        "currency_type_symbol": "S/",
        "sale_affectation_igv_type_id": "10",
        "purchase_affectation_igv_type_id": "10"
      },
      "quantity": products.quantity.toString(),
      "unit_value": products.unitValue,
      "affectation_igv_type_id": "10",
      "total_base_igv": products.totalBaseIgv,
      "percentage_igv": "18.00",
      "total_igv": products.totalIgv,
      "total_taxes": products.totalTaxes,
      "price_type_id": "01",
      "unit_price": products.unitPrice,
      "total_value": products.totalValue,
      "total": products.total,
    };
  }

  Map newItems(Products product) {
    return {
      "item_id": product.itemId,
      "item": {
        "description": product.description,
        "item_type_id": "-",
        "internal_id": "-",
        "item_code": "-",
        "item_code_gs1": null,
        "unit_type_id": "NIU",
        "presentation": [],
        "amount_plastic_bag_taxes": "-",
        "is_set": 0,
        "lots": [],
        "IdLoteSelected": null
      },
      "quantity": product.quantity,
      "unit_value": (double.parse(product.price) / 1.18).toStringAsFixed(2),
      "price_type_id": "01",
      "unit_price": product.price,
      "affectation_igv_type_id": "10",
      "total_base_igv":
          ((double.parse(product.price) / 1.18) * product.quantity)
              .toStringAsFixed(2),
      "percentage_igv": "18.00",
      "total_igv":
          (((double.parse(product.price) / 1.18) * .18) * product.quantity)
              .toStringAsFixed(2),
      "system_isc_type_id": null,
      "total_base_isc": "0.00",
      "percentage_isc": "0.00",
      "total_isc": "0.00",
      "total_base_other_taxes": "0.00",
      "percentage_other_taxes": "0.00",
      "total_other_taxes": "0.00",
      "total_plastic_bag_taxes": 0,
      "total_taxes":
          (((double.parse(product.price) / 1.18) * .18) * product.quantity)
              .toStringAsFixed(2),
      "total_value": ((double.parse(product.price) / 1.18) * product.quantity)
          .toStringAsFixed(2),
      "total_charge": "0.00",
      "total_discount": "0.00",
      "total":
          (double.parse(product.price) * product.quantity).toStringAsFixed(2),
      "attributes": null,
      "discounts": null,
      "charges": null,
      "warehouse_id": null,
      "additional_information": null,
      "name_product_pdf": null
    };
  }

  String formatDate(DateTime _date) {
    return "${_format(_date.year)}-${_format(_date.month)}-${_format(_date.day)}";
  }

  String _format(int b) {
    String z = b.toString();

    return z.length == 1 ? "0" + z : z;
  }

  // Map bill(Order order, DateTime date) {
  //   Client client = order.customer;
  //   User user;
  //   user = User.fromjson(json.decode(preferencesUser.userData));

  //   double _total = double.parse(order.total);
  //   return {
  //     "serie_documento": "F001",
  //     "numero_documento": "#",
  //     "user_id": user.id,
  //     "fecha_de_emision": formatDate(date),
  //     "hora_de_emision": "10:11:11",
  //     "codigo_tipo_operacion": "0101",
  //     "codigo_tipo_documento": "01",
  //     "codigo_tipo_moneda": "PEN",
  //     "fecha_de_vencimiento": formatDate(date),
  //     "numero_orden_de_compra": "-",
  //     "datos_del_cliente_o_receptor": {
  //       "codigo_tipo_documento_identidad":
  //           client.number.length == 8 ? "1" : "6",
  //       "numero_documento": client.number,
  //       "apellidos_y_nombres_o_razon_social": client.name,
  //       "codigo_pais": "PE",
  //       "ubigeo": "150101",
  //       "direccion": client.address,
  //       "correo_electronico": client.email,
  //       "telefono": client.telephone
  //     },
  //     "totales": {
  //       "total_exportacion": 0.00,
  //       "total_operaciones_gravadas": (_total / 1.18),
  //       "total_operaciones_inafectas": 0.00,
  //       "total_operaciones_exoneradas": 0.00,
  //       "total_operaciones_gratuitas": 0.00,
  //       "total_igv": (_total / 1.18) * .18,
  //       "total_impuestos": (_total / 1.18) * .18,
  //       "total_valor": (_total / 1.18),
  //       "total_venta": _total,
  //     },
  //     "items": order.items.map<Map>((e) => itemsF(e)).toList(),
  //     // "acciones": {"enviar_email": true},
  //     "informacion_adicional": "Forma de pago:Efectivo|Caja: 1"
  //   };
  // }

  // Map voucher(Order order, DateTime date) {
  //   double _total = double.parse(order.total);
  //   Client client = order.customer;
  //   User user;
  //   user = User.fromjson(json.decode(preferencesUser.userData));
  //   return {
  //     "serie_documento": "B001",
  //     "numero_documento": "#",
  //     "user_id": user.id,
  //     "fecha_de_emision": formatDate(date),
  //     "hora_de_emision": "10:11:11",
  //     "codigo_tipo_operacion": "0101",
  //     "codigo_tipo_documento": "03",
  //     "codigo_tipo_moneda": "PEN",
  //     "fecha_de_vencimiento": formatDate(date),
  //     "numero_orden_de_compra": "",
  //     "datos_del_cliente_o_receptor": {
  //       "codigo_tipo_documento_identidad":
  //           client.number.length == 8 ? "1" : "6",
  //       "numero_documento": client.number,
  //       "apellidos_y_nombres_o_razon_social": client.name,
  //       "codigo_pais": "PE",
  //       "ubigeo": "150101",
  //       "direccion": client.address,
  //       "correo_electronico": client.email,
  //       "telefono": client.telephone
  //     },
  //     "totales": {
  //       "total_exportacion": 0.00,
  //       "total_operaciones_gravadas": (_total / 1.18),
  //       "total_operaciones_inafectas": 0.00,
  //       "total_operaciones_exoneradas": 0.00,
  //       "total_operaciones_gratuitas": 0.00,
  //       "total_igv": (_total / 1.18) * .18,
  //       "total_impuestos": (_total / 1.18) * .18,
  //       "total_valor": (_total / 1.18),
  //       "total_venta": _total,
  //     },
  //     "items": order.items.map<Map>((e) => itemsF(e)).toList(),
  //     // "acciones": {"enviar_email": true}
  //   };
  // }

  Map saleNote(Order order, DateTime date) {
    if (order.total == null) {
      order.total = (double.parse(order.subtotal) * 1.18).toStringAsFixed(2);
    }
    Client client = order.customer;
    double _total = double.parse(order.total);

    User user;
    user = User.fromjson(json.decode(preferencesUser.userData));
    return {
      "establishment_id": 1,
      "document_type_id": "80",
      "paid": 1,
      "series_id": 10,
      "prefix": "NV",
      "number": "#",
      "user_id": user.id,
      "date_of_issue": formatDate(date),
      "time_of_issue": "00:00:00",
      "customer_id": client.id,
      "currency_type_id": "PEN",
      "purchase_order": null,
      "exchange_rate_sale": 0,
      "total_prepayment": 0,
      "total_charge": 0,
      "total_discount": 0,
      "total_exportation": 0,
      "total_free": 0,
      "total_taxed": (_total / 1.18),
      "total_unaffected": 0,
      "total_exonerated": 0,
      "total_igv": (_total / 1.18) * .18,
      "total_base_isc": 0,
      "total_isc": 0,
      "total_base_other_taxes": 0,
      "total_other_taxes": 0,
      "total_taxes": (_total / 1.18) * .18,
      "total_value": (_total / 1.18),
      "total": order.total,
      "operation_type_id": "0101",
      "date_of_due": formatDate(date),
      "items": order.items.map<Map>((e) => itemsSaleNote(e)).toList(),
      "additional_information": null,
      "actions": {"format_pdf": "a4"}
    };
  }

  Map itemsSaleNote(Products product) {
    return {
      "item_id": product.itemId,
      "item": {
        "id": product.itemId,
        "item_id": product.itemId,
        "full_description": product.description,
        "description": product.description,
        "currency_type_id": "PEN",
        "internal_id": product.internCode ?? "P001",
        "currency_type_symbol": "S/",
        "sale_unit_price": product.price,
        "purchase_unit_price": product.price,
        "unit_type_id": "NIU",
        "sale_affectation_igv_type_id": "10",
        "purchase_affectation_igv_type_id": "10",
        "calculate_quantity": false,
        "has_igv": true,
        "is_set": false,
        "edit_unit_price": false,
        "aux_quantity": 1,
        "edit_sale_unit_price": product.price,
        "aux_sale_unit_price": product.price,
        "image_url": product.image ?? "-",
        "warehouses": [
          {
            "warehouse_description": "Almacén Oficina Principal",
            "stock": product.stock
          }
        ],
        "category_id": null,
        "sets": [],
        "unit_type": [],
        "unit_price": product.price,
        "presentation": null
      },
      "currency_type_id": "PEN",
      "quantity": product.quantity,
      "unit_value": double.parse(product.price) / 1.18,
      "affectation_igv_type_id": "10",
      "affectation_igv_type": {
        "id": "10",
        "active": 1,
        "exportation": 0,
        "free": 0,
        "description": "Gravado - Operación Onerosa"
      },
      "total_base_igv": (double.parse(product.price) / 1.18) * product.quantity,
      "percentage_igv": 18,
      "total_igv":
          ((double.parse(product.price) / 1.18) * .18) * product.quantity,
      "system_isc_type_id": null,
      "total_base_isc": 0,
      "percentage_isc": 0,
      "total_isc": 0,
      "total_base_other_taxes": 0,
      "percentage_other_taxes": 0,
      "total_other_taxes": 0,
      "total_plastic_bag_taxes": 0,
      "total_taxes":
          ((double.parse(product.price) / 1.18) * .18) * product.quantity,
      "price_type_id": "01",
      "unit_price": double.parse(product.price),
      "total_value": (double.parse(product.price) / 1.18) * product.quantity,
      "total_discount": 0,
      "total_charge": 0,
      "total": double.parse(product.price) * product.quantity,
      "attributes": [],
      "charges": [],
      "discounts": []
    };
  }
}
