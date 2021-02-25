//http://demo.grupodubai.online/api/items/category/2 PRODUCTOS 2 ID
//http://demo.grupodubai.online/api/categories/records?column=name&page=1 CATEGORIAS
//http://demo.grupodubai.online/api/items/record/6 DETALLE 6 ID
//Bearer 9Um22l1L4AKUQUxSYIJVTRHV8ZrmwZEFsKqRajaDcSuQEZGyLz  TOKEN
import 'dart:convert';

import 'package:delivery_app/src/models/categories.dart';
import 'package:delivery_app/src/models/products.dart';
import 'package:delivery_app/src/utils/const.dart';
import 'package:http/http.dart';

class ProductsServices {
  //TEST

  final String _productsUrl = "$globalUrl/api/items/category/";
  final String _categoriesUrl =
      "$globalUrl/api/categories/records?column=name&page=1";

  Future<List<Category>> getCategories() async {
    final Response _response =
        await get(_categoriesUrl, headers: globalRequestHeaders);
    Map<String, dynamic> _data = json.decode(_response.body);
    List<Category> _categories =
        _data['data'].map<Category>((e) => Category.fromJson(e)).toList();

    return _categories;
  }

  Future<List<Products>> getProducts(int id) async {
    final Response _response =
        await get("$_productsUrl$id", headers: globalRequestHeaders);
    Map<String, dynamic> _data = json.decode(_response.body);
    List<Products> _products =
        _data['data'].map<Products>((e) => Products.fromJson(e)).toList();
    return _products;
  }

  Future<List<dynamic>> allProductsAndCategories() async {
    List<Products> _products = [];

    final Response _response =
        await get(_categoriesUrl, headers: globalRequestHeaders);
    Map<String, dynamic> _data = json.decode(_response.body);
    List<Category> _categories =
        _data['data'].map<Category>((e) => Category.fromJson(e)).toList();

    for (int i = 0; i < _categories.length; i++) {
      List<Products> temporal = await getProducts(_categories[i].id);
      _products.addAll(temporal);
    }

    return [_categories, _products];
  }

  Future<List<dynamic>> noInternet() async {
    List<Products> _products = [];
    List<Category> _categories = List.generate(
        4, (index) => Category(id: index + 1, name: "Categoria $index"));

    for (int i = 0; i < _categories.length; i++) {
      List<Products> temporal = List.generate(
          25,
          (index) => Products(
              categoryId: _categories[i].id,
              id: DateTime.now().microsecond,
              currency: "S/",
              description:
                  "Producto Nuevo ${i * (index + 1)}${DateTime.now().microsecond} ",
              price: "136.45",
              stock: "999"));
      _products.addAll(temporal);
    }

    return [_categories, _products];
  }
}
