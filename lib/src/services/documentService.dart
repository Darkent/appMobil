import 'dart:convert';

import 'package:delivery_app/src/models/client.dart';
import 'package:delivery_app/src/models/documents.dart';
import 'package:delivery_app/src/models/order.dart';
import 'package:delivery_app/src/models/products.dart';
import 'package:delivery_app/src/models/series.dart';
import 'package:delivery_app/src/models/user.dart';
import 'package:delivery_app/src/utils/const.dart';

import 'package:http/http.dart' as http;
import 'package:delivery_app/src/providers/preferences.dart';

class DocumentService {
  PreferencesUser preferencesUser = PreferencesUser();

  final keyFCM = "$globalUrl/api/companies/record";
  final urlFirebase = "https://fcm.googleapis.com/fcm/send";
  final urlTokenUser =
      "$globalUrl/api/users/filter?column=number&page=1&value=";
  final url = "$globalUrl/api/documents";
  final urlClients = "$globalUrl/api/documents/generar_documents";
  final urlSaleNotePdf = "$globalUrl/api/sale-note/record/";
  final urlSaleNote = "$globalUrl/api/sale-note";
  final urlUpdate = "$globalUrl/api/orders/status/update";
  final urlUpdateItems = "$globalUrl/api/order-notes/update";

  final urlSeries = "$globalUrl/api/documents/tables";

  final urlNotes =
      "$globalUrl/api/sale-notes/records?column=customer_id&page=1&series&value";

  final urlDocuments =
      "$globalUrl/api/documents/records?category_id&customer_id&d_end&d_start&date_of_issue&document_type_id&item_id&number&page=1&pending_payment=false&series&state_type_id";

  Future<List<Document>> getDocuments() async {
    List<Document> documents = [];
    http.Response response;
    Map parsed;
    response = await http.get(urlDocuments, headers: globalRequestHeaders);
    if (response.statusCode == 200) {
      parsed = json.decode(response.body);
      documents.addAll(
          parsed['data'].map<Document>((d) => Document.documents(d)).toList());
    }

    response = await http.get(urlNotes, headers: globalRequestHeaders);
    if (response.statusCode == 200) {
      parsed = json.decode(response.body);
      documents.addAll(
          parsed['data'].map<Document>((d) => Document.noteSales(d)).toList());
    }

    return documents;
  }

  Future<List<Series>> getSeries() async {
    http.Response response =
        await http.get(urlSeries, headers: globalRequestHeaders);
    if (response.statusCode == 200) {
      Map parsed = json.decode(response.body);
      return parsed['series']
          .map<Series>((serie) => Series.fromJson(serie))
          .toList();
    }
    return [];
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

  Future<bool> deletedItems(Map order) async {
    http.Response response = await http.post(urlUpdateItems,
        body: json.encode(order), headers: globalRequestHeaders);
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
    // debugPrint(body.toString(), wrapWidth: 1024);
    http.Response response;
    if (!deletedI) {
      response = await http.post(urlClients,
          body: json.encode(body), headers: globalRequestHeaders);

      if (response.statusCode == 200) {
        sendNotification(order.number);

        return true;
      }
    } else {
      Map _body = orderUpdate(order, items);
      if (await deletedItems(_body)) {
        response = await http.post(urlClients,
            body: json.encode(body), headers: globalRequestHeaders);

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
        body: json.encode(body), headers: globalRequestHeaders);

    if (response.statusCode == 200) {
      PreferencesUser _preferenceUser = PreferencesUser();

      Map body = json.decode(response.body);

      _preferenceUser.tmpPdf = body['data']['external_id'];
      if (order.number != null) {
        sendNotification(order.number);
      }
      return true;
    }

    return false;
  }

  Map documentE(
      {Series serie,
      String type,
      DateTime date,
      Order order,
      List<Products> items}) {
    String _date = date.toString().split(" ")[0];
    String igv = (double.parse(order.subtotal.split(",").join()) * .18)
        .toStringAsFixed(2);
    String base = order.subtotal.split(",").join();
    String total = (double.parse(order.subtotal.split(",").join()) * 1.18)
        .toStringAsFixed(2);

    return {
      "document_type_id": serie.documentTypeId,
      "series_id": serie.id,
      "establishment_id": 1,
      "number": "#",
      "date_of_issue": _date,
      "time_of_issue": "17:34:01",
      "customer_id": order.customerId,
      "currency_type_id": "PEN",
      "purchase_order": null,
      "exchange_rate_sale": "1.000",
      "total_prepayment": "0.00",
      "total_charge": "0.00",
      "total_discount": "0.00",
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
      "total_taxes": igv,
      "total_value": base,
      "total": total,
      "operation_type_id": "0101",
      "date_of_due": _date,
      "items": items.map<Map>((product) => newItems(product)).toList(),
      "charges": {},
      "discounts": {},
      "attributes": [],
      "guides": {},
      "additional_information": null,
      "actions": {"format_pdf": "a4"},
      "user_id": 1,
      "order_note_id": order.id,
      "is_receivable": false,
      "payments": [
        {
          "id": null,
          "document_id": null,
          "date_of_payment": _date,
          "payment_method_type_id": "01",
          "payment_destination_id": "cash",
          "reference": null,
          "payment": double.parse(total)
        }
      ],
      "hotel": {},
      "prefix": null
    };
    // return {
    //   "type": "invoice",
    //   "group_id": "01",
    //   "user_id": 1,
    //   "establishment_id": 1,
    //   "establishment": {
    //     "country_id": "PE",
    //     "country": {"id": "PE", "description": "PERU"},
    //     "department_id": "05",
    //     "department": {"id": "-", "description": "-"},
    //     "province_id": "-",
    //     "province": {"id": "-", "description": "-"},
    //     "district_id": "-",
    //     "district": {"id": "-", "description": "-"},
    //     "urbanization": null,
    //     "address": "-",
    //     "email": "-",
    //     "telephone": "-",
    //     "code": "0000",
    //     "trade_address": null,
    //     "web_address": null,
    //     "aditional_information": null
    //   },
    //   "soap_type_id": "01",
    //   "state_type_id": "01",
    //   "ubl_version": "2.1",
    //   "filename": "",
    //   "document_type_id": type,
    //   "series": serie,
    //   "number": "#",
    //   "date_of_issue": _date,
    //   "time_of_issue": "18:40:53",
    //   "customer_id": order.customer.id,
    //   "customer": {
    //     "identity_document_type_id": _customers.number.length == 8 ? "1" : "6",
    //     "identity_document_type": {
    //       "id": _customers.number.length == 8 ? "1" : "6",
    //       "description": _customers.number.length == 8 ? "DNI" : "RUC"
    //     },
    //     "number": _customers.number ?? "-",
    //     "name": _customers.name ?? "-",
    //     "trade_name": _customers.name ?? "-",
    //     "country_id": "PE",
    //     "country": {"id": "PE", "description": "PERU"},
    //     "department_id": _customers.department.id ?? "15",
    //     "department": {
    //       "id": _customers.department.id ?? "15",
    //       "description": _customers.department.description ?? "LIMA"
    //     },
    //     "province_id": _customers.province.id ?? "1501",
    //     "province": {
    //       "id": _customers.province.id ?? "1501",
    //       "description": _customers.province.description ?? "LIMA"
    //     },
    //     "district_id": _customers.district.id ?? "150110",
    //     "district": {
    //       "id": _customers.district.id ?? "150110",
    //       "description": _customers.district.description ?? "COMAS"
    //     },
    //     "address": _customers.address ?? "-",
    //     "email": _customers.email ?? "-",
    //     "telephone": _customers.telephone ?? "-",
    //     "perception_agent": 0
    //   },
    //   "currency_type_id": "PEN",
    //   "purchase_order": null,
    //   "quotation_id": null,
    //   "sale_note_id": null,
    //   "order_note_id": order.id,
    //   "exchange_rate_sale": "1.000",
    //   "total_prepayment": "0.00",
    //   "total_discount": "0.00",
    //   "total_charge": "0.00",
    //   "total_exportation": "0.00",
    //   "total_free": "0.00",
    //   "total_taxed": base,
    //   "total_unaffected": "0.00",
    //   "total_exonerated": "0.00",
    //   "total_igv": igv,
    //   "total_base_isc": "0.00",
    //   "total_isc": "0.00",
    //   "total_base_other_taxes": "0.00",
    //   "total_other_taxes": "0.00",
    //   "total_plastic_bag_taxes": 0,
    //   "total_taxes": igv,
    //   "total_value": base,
    //   "total": total,
    //   "has_prepayment": 0,
    //   "affectation_type_prepayment": null,
    //   "was_deducted_prepayment": 0,
    //   "items": items.map<Map>((product) => newItems(product)).toList(),
    //   "charges": null,
    //   "discounts": null,
    //   "prepayments": null,
    //   "guides": null,
    //   "related": null,
    //   "perception": null,
    //   "detraction": null,
    //   "invoice": {"operation_type_id": "0101", "date_of_due": "2021-01-17"},
    //   "note": null,
    //   "hotel": [],
    //   "transport": [],
    //   "additional_information": null,
    //   "plate_number": null,
    //   "legends": [
    //     {"code": 1000, "value": NumeroLetras().convertir(total)}
    //   ],
    //   "actions": {
    //     "send_email": false,
    //     "send_xml_signed": true,
    //     "format_pdf": "a4"
    //   },
    //   "data_json": null,
    //   "payments": [
    //     {
    //       "id": null,
    //       "document_id": null,
    //       "date_of_payment": "2021-01-17",
    //       "payment_method_type_id": "01",
    //       "payment_destination_id": "cash",
    //       "reference": null,
    //       "payment": 0
    //     }
    //   ],
    //   "send_server": false
    // };
  }

  Future<bool> emitirDocumentoDirectamente(Map body) async {
    http.Response response = await http.post(url,
        body: json.encode(body), headers: globalRequestHeaders);

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
      "id": product.id,
      "order_note_id": product.orderId,
      "item_id": product.itemId,
      "item": {
        "id": product.itemId,
        "is_set": false,
        "has_igv": true,
        "unit_price": product.price,
        "warehouses": [
          {
            "stock": product.stock,
            "warehouse_id": 1,
            "warehouse_description": "Almacén Oficina Principal"
          }
        ],
        "description": product.description,
        "presentation": [],
        "unit_type_id": "NIU",
        "item_unit_types": [],
        "sale_unit_price": product.unitPrice,
        "currency_type_id": "PEN",
        "full_description": product.description,
        "calculate_quantity": false,
        "purchase_unit_price": "110.000000",
        "currency_type_symbol": "S/",
        "sale_affectation_igv_type_id": "10",
        "purchase_affectation_igv_type_id": "10"
      },
      "quantity": "1.0000",
      "unit_value": product.unitValue,
      "affectation_igv_type_id": "10",
      "total_base_igv": product.totalBaseIgv,
      "percentage_igv": "18.00",
      "total_igv": product.totalIgv,
      "system_isc_type_id": null,
      "total_base_isc": "0.00",
      "percentage_isc": "0.00",
      "total_isc": "0.00",
      "total_base_other_taxes": "0.00",
      "percentage_other_taxes": "0.00",
      "total_other_taxes": "0.00",
      "total_taxes": product.totalIgv,
      "price_type_id": "01",
      "unit_price": product.unitPrice,
      "total_value": product.unitValue,
      "total_charge": "0.00",
      "total_discount": "0.00",
      "total": product.total,
      "attributes": {},
      "discounts": {},
      "charges": {},
      "affectation_igv_type": {
        "id": "10",
        "active": 1,
        "exportation": 0,
        "free": 0,
        "description": "Gravado - Operación Onerosa"
      },
      "system_isc_type": null,
      "price_type": {
        "id": "01",
        "active": 1,
        "description": "Precio unitario (incluye el IGV)"
      }
    };

    // return {
    //   "item_id": product.itemId,
    //   "item": {
    //     "description": product.description,
    //     "item_type_id": "-",
    //     "internal_id": "-",
    //     "item_code": "-",
    //     "item_code_gs1": null,
    //     "unit_type_id": "NIU",
    //     "presentation": [],
    //     "amount_plastic_bag_taxes": "-",
    //     "is_set": 0,
    //     "lots": [],
    //     "IdLoteSelected": null
    //   },
    //   "quantity": product.quantity,
    //   "unit_value": (double.parse(product.price) / 1.18).toStringAsFixed(2),
    //   "price_type_id": "01",
    //   "unit_price": product.price,
    //   "affectation_igv_type_id": "10",
    //   "total_base_igv":
    //       ((double.parse(product.price) / 1.18) * product.quantity)
    //           .toStringAsFixed(2),
    //   "percentage_igv": "18.00",
    //   "total_igv":
    //       (((double.parse(product.price) / 1.18) * .18) * product.quantity)
    //           .toStringAsFixed(2),
    //   "system_isc_type_id": null,
    //   "total_base_isc": "0.00",
    //   "percentage_isc": "0.00",
    //   "total_isc": "0.00",
    //   "total_base_other_taxes": "0.00",
    //   "percentage_other_taxes": "0.00",
    //   "total_other_taxes": "0.00",
    //   "total_plastic_bag_taxes": 0,
    //   "total_taxes":
    //       (((double.parse(product.price) / 1.18) * .18) * product.quantity)
    //           .toStringAsFixed(2),
    //   "total_value": ((double.parse(product.price) / 1.18) * product.quantity)
    //       .toStringAsFixed(2),
    //   "total_charge": "0.00",
    //   "total_discount": "0.00",
    //   "total":
    //       (double.parse(product.price) * product.quantity).toStringAsFixed(2),
    //   "attributes": null,
    //   "discounts": null,
    //   "charges": null,
    //   "warehouse_id": null,
    //   "additional_information": null,
    //   "name_product_pdf": null
    // };
  }

  String formatDate(DateTime _date) {
    return "${_format(_date.year)}-${_format(_date.month)}-${_format(_date.day)}";
  }

  String _format(int b) {
    String z = b.toString();

    return z.length == 1 ? "0" + z : z;
  }

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
      "order_note_id": order.id,
      "paid": 1,
      "series": "N001",
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
      "actions": {"format_pdf": "a4"},
      "payments": [
        {
          "id": null,
          "document_id": null,
          "sale_note_id": null,
          "date_of_payment": formatDate(date),
          "payment_method_type_id": "01",
          "payment_destination_id": "cash",
          "reference": null,
          "payment": double.parse(order.total)
        }
      ],
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
