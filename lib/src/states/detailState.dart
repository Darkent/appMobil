import 'package:rxdart/rxdart.dart';

class DetailState {
  BehaviorSubject<int> _quantityProduct = BehaviorSubject<int>.seeded(0);

  Stream<int> get quantityProduct => _quantityProduct.stream;

  Function(int) get sendQuantityProduct => _quantityProduct.sink.add;

  int get valueQuantityProduct => _quantityProduct.value;
  get increment {
    _quantityProduct.sink.add(_quantityProduct.value + 1);
  }

  get decrement {
    if (_quantityProduct.value != 0) {
      _quantityProduct.sink.add(_quantityProduct.value - 1);
    }
  }

  void dispose() {
    _quantityProduct.close();
  }
}
