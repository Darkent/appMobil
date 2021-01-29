import 'package:delivery_app/src/models/documents.dart';
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

  BehaviorSubject<bool> _selectF = BehaviorSubject<bool>.seeded(true);
  Stream<bool> get selectF => _selectF.stream;
  Function(bool) get inSelectF => _selectF.sink.add;
  bool get selectFValue => _selectF.value;

  BehaviorSubject<bool> _selectB = BehaviorSubject<bool>.seeded(true);
  Stream<bool> get selectB => _selectB.stream;
  Function(bool) get inSelectB => _selectB.sink.add;
  bool get selectBValue => _selectB.value;

  BehaviorSubject<bool> _selectN = BehaviorSubject<bool>.seeded(true);
  Stream<bool> get selectN => _selectN.stream;
  Function(bool) get inSelectN => _selectN.sink.add;
  bool get selectNValue => _selectN.value;

  BehaviorSubject<String> _selectTypeSearch =
      BehaviorSubject<String>.seeded("documento");
  Stream<String> get selectTypeSearch => _selectTypeSearch.stream;
  Function(String) get inSelectTypeSearch => _selectTypeSearch.sink.add;
  String get selectTypeSearchValue => _selectTypeSearch.value;

  BehaviorSubject<List<Document>> _documents =
      BehaviorSubject<List<Document>>();
  Stream<List<Document>> get documents => _documents.stream;
  Function(List<Document>) get inDocuments => _documents.sink.add;
  List<Document> get documentsValue => _documents.value;

  OrdersState();
  void dispose() {
    _documents.close();
    _selectTypeSearch.close();
    _selectN.close();
    _selectB.close();
    _selectF.close();
    _stateLoading.close();
    _currentList.close();
    _date.close();
    _pending.close();
    _delivered.close();
  }
}
