import 'package:delivery_app/src/models/categories.dart';
import 'package:delivery_app/src/models/products.dart';
import 'package:flutter/material.dart';

class AppGlobalState extends ChangeNotifier {
  List<Category> _categories = [];
  List<Products> _products = [];
  List<List<Products>> _productsByCategory = [];
  Category _category;

  get productsByCategory => _productsByCategory;
  set productsByCategory(List<List<Products>> productsByCategory) {
    this._productsByCategory = productsByCategory;
    notifyListeners();
  }

  get category => _category;
  set category(Category category) {
    this._category = category;
    notifyListeners();
  }

  get products => _products;
  set products(List<Products> products) {
    this._products = products;
    notifyListeners();
  }

  get categories => _categories;
  set categories(List<Category> categories) {
    this._categories = categories;
    notifyListeners();
  }
}
