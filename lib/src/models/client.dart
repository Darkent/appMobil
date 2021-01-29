import 'package:delivery_app/src/models/user.dart';

class Client {
  int id;
  String name;
  String number;
  String address;
  String telephone;
  String email;
  String identityDocumentTypeId;

  Client(
      {this.id,
      this.name,
      this.number,
      this.address,
      this.telephone,
      this.email,
      this.identityDocumentTypeId});

  factory Client.fromJson(Map json) => Client(
      id: json['id'],
      name: json['name'],
      number: json['number'],
      address: json['address'] ?? "-",
      telephone: json['telephone']?.split("-")?.join() ?? "000000000",
      email: json['email'] ?? "-",
      identityDocumentTypeId: json['identity_document_type_id']);

  factory Client.fromDNI(Map json, String document, {int id}) => Client(
      id: id ?? null,
      name: json['nombre_completo'],
      address: "-",
      email: "-",
      identityDocumentTypeId: "1",
      number: document,
      telephone: "-");

  factory Client.fromRUC(Map json, String document, {int id}) => Client(
      id: id ?? null,
      identityDocumentTypeId: "6",
      number: document,
      name: json['nombre_o_razon_social'],
      address: json['direccion_completa'] ?? json['direccion']);

  factory Client.fromUser(User user) => Client(
      id: user.id,
      address: user.address,
      email: user.email,
      name: user.name,
      identityDocumentTypeId: user.identityDocumentTypeId,
      telephone: user.telephone,
      number: user.number);
}
