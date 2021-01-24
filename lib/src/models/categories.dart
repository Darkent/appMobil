import 'package:delivery_app/src/models/products.dart';

class Category {
  int id;
  String name;
  String icono;
  List<Products> products;
  Category({this.id, this.name, this.icono, this.products});

  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(id: json['id'], name: json['name'], icono: json['icono']);
}
