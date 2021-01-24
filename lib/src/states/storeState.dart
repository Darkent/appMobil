import 'package:rxdart/rxdart.dart';

class StoreState {
  BehaviorSubject<int> _page = BehaviorSubject<int>.seeded(0);
  Stream<int> get page => _page.stream;
  Function(int i) get enterPage => _page.sink.add;

  BehaviorSubject<int> _productsInCar = BehaviorSubject<int>.seeded(0);
  Stream<int> get productsInCar => _productsInCar.stream;
  Function(int i) get sendProductsInCar => _productsInCar.sink.add;

  void dispose() {
    _productsInCar.close();
    _page.close();
  }
}
