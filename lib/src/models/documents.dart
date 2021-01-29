import 'package:delivery_app/src/utils/const.dart';

class Document {
  bool saleNote;
  String externalId;
  String number;
  String date;
  String total;
  String igv;
  String base;
  CustomerDocument customerDocument;
  String pdfUrl;
  Document(
      {this.saleNote,
      this.externalId,
      this.number,
      this.date,
      this.total,
      this.igv,
      this.base,
      this.customerDocument,
      this.pdfUrl});

  factory Document.documents(Map json) => Document(
      pdfUrl: "$globalUrl/downloads/document/pdf/${json['external_id']}/a4",
      externalId: json['external_id'],
      base: json['total_taxed'],
      igv: json['total_igv'],
      total: json['total'],
      customerDocument: CustomerDocument(
          name: json['customer_name'], number: json['customer_number']),
      date: json['date_of_issue'],
      number: json['number'],
      saleNote: false);

  factory Document.noteSales(Map json) => Document(
      pdfUrl: "$globalUrl/api/sale-note/print/${json['external_id']}/a4",
      externalId: json['external_id'],
      base: json['total_taxed'],
      igv: json['total_igv'],
      total: json['total'],
      customerDocument: CustomerDocument(
          name: json['customer_name'], number: json['customer_number']),
      date: json['date_of_issue'],
      number: json['full_number'],
      saleNote: true);
}

class CustomerDocument {
  String name;
  String number;

  CustomerDocument({this.name, this.number});
}
