import 'package:rxdart/rxdart.dart';

class HomeState {
  BehaviorSubject<int> _page = BehaviorSubject<int>.seeded(0);
  Stream<int> get page => _page.stream;

  Function(int i) get enterPage => _page.sink.add;

  BehaviorSubject<int> _notification = BehaviorSubject<int>.seeded(0);
  Stream<int> get notification => _notification.stream;
  Function(int i) get addNotification => _notification.sink.add;
  int get notificationValue => _notification.value;

  void dispose() {
    _notification.close();
    _page.close();
  }
}
