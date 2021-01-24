import 'package:delivery_app/src/models/products.dart';
import 'package:rxdart/rxdart.dart';

class ShopCarState {
  BehaviorSubject<List<Products>> _products = BehaviorSubject<List<Products>>();

  Function(List<Products>) get sendProducts => _products.sink.add;
  Stream<List<Products>> get products => _products.stream;
  List<Products> get allProducts => _products.value;

  BehaviorSubject<double> _subtotal = BehaviorSubject<double>.seeded(0.00);
  Function(double) get sendSubtotal => _subtotal.sink.add;
  Stream<double> get subtotal => _subtotal.stream;
  double get getSubtotal => _subtotal.value;

  ShopCarState() {
    _products.listen((value) {
      double temporal = 0.0;
      value.forEach((element) {
        temporal += double.parse(element.price) * element.quantity;
      });
      _subtotal.sink.add(temporal);
    });
  }
  void dispose() {
    _subtotal.close();
    _products.close();
  }
}
