import 'package:delivery_app/src/models/products.dart';

class Purchase {
  final int id;
  final String address;
  final double amount;
  final String date;
  final String paymentType;
  final List<Products> items;
  final int statusOrderId;
  final String document;
  final String documentExternalId;
  final String numberDocument;
  final List documents;

  Purchase(
      {this.documents,
      this.id,
      this.numberDocument,
      this.address,
      this.amount,
      this.date,
      this.paymentType,
      this.items,
      this.statusOrderId,
      this.document,
      this.documentExternalId});

  factory Purchase.fromJson(Map json) => Purchase(
      id: json['id'],
      address: json['shipping_address'],
      numberDocument: json['number_document'],
      amount: double.tryParse(json['total'].split(",").join("")) ?? 0.0,
      paymentType: json['reference_payment'],
      date: json['created_at'],
      items: json['items']
          .map<Products>((e) => Products.fromJsonPurchase(e))
          .toList(),
      statusOrderId: json['status_order_id'],
      document: json['document'],
      documentExternalId: json['document_external_id'],
      documents: json['documents']);
}
