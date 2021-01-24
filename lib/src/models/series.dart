import 'dart:convert';

class Series {
  final int id;
  final String documentTypeId;
  final String number;

  Series({this.id, this.documentTypeId, this.number});

  factory Series.fromJson(Map json) => Series(
      id: json['id'],
      documentTypeId: json['document_type_id'],
      number: json['number']);

  String seriesToString() {
    return json.encode({
      "id": this.id,
      "document_type_id": this.documentTypeId,
      "number": this.number
    });
  }

  factory Series.stringToSeries(String map) {
    return Series.fromJson(json.decode(map));
  }
}
