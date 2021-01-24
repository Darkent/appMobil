class User {
  int id;
  String name;
  String type;
  String number;
  String address;
  String telephone;
  String token;
  String email;
  String identityDocumentTypeId;

  User(
      {this.id,
      this.name,
      this.type,
      this.number,
      this.address,
      this.telephone,
      this.token,
      this.email,
      this.identityDocumentTypeId});

  factory User.fromjson(Map json) => User(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      number: json['number'] ?? "00000000",
      address: json['address'] ?? "-",
      telephone: json['telephone'] ?? "999999999",
      token: json['token'],
      email: json['email'],
      identityDocumentTypeId: json['identity_document_type_id']);
}
