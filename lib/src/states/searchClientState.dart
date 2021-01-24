import 'package:delivery_app/src/models/client.dart';
import 'package:rxdart/rxdart.dart';

class SearchClientState {
  BehaviorSubject<String> _searchType = BehaviorSubject<String>.seeded("1");

  Stream<String> get searchType => _searchType.stream;
  Function(String) get inSearchType => _searchType.sink.add;
  String get searchTypeValue => _searchType.value;

  BehaviorSubject<String> _typeFieldSearch =
      BehaviorSubject<String>.seeded("DOCUMENT");

  Stream<String> get typeFieldSearch => _typeFieldSearch.stream;
  Function(String) get inTypeFieldSearch => _typeFieldSearch.sink.add;
  String get typeFieldSearchValue => _typeFieldSearch.value;

  BehaviorSubject<List<Client>> _listResults = BehaviorSubject<List<Client>>();
  Stream<List<Client>> get listResults => _listResults.stream;
  Function(List<Client>) get inListResults => _listResults.sink.add;

  BehaviorSubject<String> _loadingText =
      BehaviorSubject<String>.seeded("SIN RESULTADOS");

  Stream<String> get loadingText => _loadingText.stream;
  Function(String) get inLoadingText => _loadingText.sink.add;
  String get loadingTextValue => _loadingText.value;

  BehaviorSubject<Client> _newClient = BehaviorSubject<Client>();
  Stream<Client> get newClient => _newClient.stream;
  Function(Client) get inNewClient => _newClient.sink.add;
  Client get newClientValue => _newClient.value;
  void dispose() {
    _searchType.close();
    _newClient.close();
    _loadingText.close();
    _listResults.close();
    _typeFieldSearch.close();
  }
}
