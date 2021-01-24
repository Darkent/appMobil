import 'package:delivery_app/src/models/order.dart';
import 'package:delivery_app/src/models/products.dart';
import 'package:rxdart/rxdart.dart';

class OrdersState {
  BehaviorSubject<List<Products>> _currentList =
      BehaviorSubject<List<Products>>.seeded(List<Products>());
  Stream<List<Products>> get currentList => _currentList.stream;
  Function(List<Products>) get inCurrentList => _currentList.sink.add;
  List<Products> get currentListValue => _currentList.value;

  BehaviorSubject<List<Order>> _pending = BehaviorSubject<List<Order>>();
  Stream<List<Order>> get pending => _pending.stream;
  Function(List<Order>) get inPending => _pending.sink.add;
  List<Order> get pendingValue => _pending.value;

  BehaviorSubject<List<Order>> _delivered = BehaviorSubject<List<Order>>();
  Stream<List<Order>> get delivered => _delivered.stream;
  Function(List<Order>) get inDelivered => _delivered.sink.add;
  List<Order> get deliveredValue => _delivered.value;

  BehaviorSubject<DateTime> _date =
      BehaviorSubject<DateTime>.seeded(DateTime.now());
  Stream<DateTime> get date => _date.stream;
  Function(DateTime) get inDate => _date.sink.add;
  DateTime get dateValue => _date.value;

  BehaviorSubject<String> _stateLoading = BehaviorSubject<String>.seeded("1");
  Stream<String> get stateLoading => _stateLoading.stream;
  Function(String) get inStateLoading => _stateLoading.sink.add;

  void dispose() {
    _stateLoading.close();
    _currentList.close();
    _date.close();
    _pending.close();
    _delivered.close();
  }
}
