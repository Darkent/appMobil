import 'package:delivery_app/src/models/client.dart';
import 'package:delivery_app/src/models/products.dart';

class Order {
  int id;
  String soap;
  String externalId;
  String date;
  String delivery;
  String identifier;
  String username;
  int userId;
  int customerId;
  String number;
  String moneda;
  String exportacion;
  String inafecta;
  List<Products> items;
  Client customer;
  String exonerado;
  String subtotal;
  String igv;
  String total;
  String statetypeid;
  String estado;
  String document;
  String documentNumber;
  List documents;
  Customers customers;

  Order(
      {this.id,
      this.soap,
      this.externalId,
      this.date,
      this.delivery,
      this.identifier,
      this.username,
      this.customer,
      this.number,
      this.moneda,
      this.userId,
      this.customerId,
      this.exportacion,
      this.inafecta,
      this.items,
      this.exonerado,
      this.subtotal,
      this.igv,
      this.total,
      this.statetypeid,
      this.estado,
      this.document,
      this.documentNumber,
      this.documents,
      this.customers});

  factory Order.fromJson(Map json) => Order(
      id: json['id'],
      externalId: json['external_id'],
      date: json['date_of_issue'],
      delivery: json['delivery_date'],
      identifier: json['identifier'],
      username: json['user_name'],
      number: json['customer_number'] ?? "-",
      customerId: json['customer_id'] ?? "-",
      userId: json['user_id'] ?? "-",
      customer: Client(
          id: json['customer_id'],
          name: json['customer_name'],
          email: json['customers']['email'] ?? "-",
          telephone: json['customers']['telephone'] ?? "-",
          address: json['customers']['address'] ?? "-",
          number: json['customers']['number']),
      items: json['items']
          .map<Products>((e) => Products.fromJsonPurchase(e))
          .toList(),
      moneda: json['currency_type_id'],
      exportacion: json['total_exportation'],
      inafecta: json['total_unaffected'],
      exonerado: json['total_exonerated'],
      subtotal: json['total_taxed'],
      igv: json['total_igv'],
      total: json['total'],
      statetypeid: json['state_type_id'],
      estado: json['state_type_description'],
      document:
          json['document'] ?? "-", //json['document_type_id']['sale_notes']);
      documentNumber: json['document_number'],
      documents: json['documents'],
      customers: Customers.fromJson(json['customers']));
}

class Customers {
  final String name;
  final String email;
  final String number;
  final String address;
  final String telephone;
  final String countryId;
  final IdDescription country;
  final IdDescription district;
  final IdDescription province;
  final IdDescription department;
  final IdDescription identityDocumentType;
  final int perceptionAgent = 0;

  Customers(
      {this.name,
      this.email,
      this.number,
      this.address,
      this.telephone,
      this.countryId,
      this.country,
      this.district,
      this.province,
      this.department,
      this.identityDocumentType});

  factory Customers.fromJson(Map json) => Customers(
      name: json['name'],
      email: json['email'],
      number: json['number'],
      address: json['address'],
      telephone: json['telephone'],
      countryId: json['country_id'],
      department: IdDescription.fromJson(json['department']),
      country: IdDescription.fromJson(json['country']),
      district: IdDescription.fromJson(json['district']),
      province: IdDescription.fromJson(json['province']),
      identityDocumentType:
          IdDescription.fromJson(json['identity_document_type']));
}

class IdDescription {
  final String id;
  final String description;

  IdDescription({this.id, this.description});

  factory IdDescription.fromJson(Map json) =>
      IdDescription(description: json['description'], id: json['id']);
}
