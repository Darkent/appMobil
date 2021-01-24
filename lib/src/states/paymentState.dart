import 'package:delivery_app/src/models/client.dart';
import 'package:rxdart/rxdart.dart';

class PaymentState {
  BehaviorSubject<List<String>> _documents = BehaviorSubject<List<String>>();
  Stream<List<String>> get documents => _documents.stream;
  Function(List<String>) get inDocuments => _documents.sink.add;
  List<String> get documentsValue => _documents.value;

  BehaviorSubject<String> _document = BehaviorSubject<String>();
  Stream<String> get document => _document.stream;
  Function(String) get inDocument => _document.sink.add;
  String get documentValue => _document.value;

  BehaviorSubject<Client> _client = BehaviorSubject<Client>();
  Stream<Client> get client => _client.stream;
  Function(Client) get inClient => _client.sink.add;
  Client get clientValue => _client.value;

  BehaviorSubject<DateTime> _date =
      BehaviorSubject<DateTime>.seeded(DateTime.now());
  Stream<DateTime> get date => _date.stream;
  Function(DateTime) get inDate => _date.sink.add;
  DateTime get dateValue => _date.value;
  void dispose() {
    _date.close();
    _documents.close();
    _client.close();
    _document.close();
  }
}
