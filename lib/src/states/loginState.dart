import 'package:delivery_app/src/providers/validator.dart';
import 'package:rxdart/rxdart.dart';

class LoginState with Validators {
  BehaviorSubject<String> _user = BehaviorSubject<String>();
  Function(String) get sendUser => _user.sink.add;
  Stream<String> get user => _user.stream.transform(emailValidator);
  String get userValue => _user.value;

  BehaviorSubject<String> _password = BehaviorSubject<String>();
  Function(String) get sendPassword => _password.sink.add;
  Stream<String> get password => _password.stream.transform(noEmpty);
  String get passwordValue => _password.value;

  BehaviorSubject<bool> _submit = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get submit => CombineLatestStream.combine2(
      _user,
      _password,
      (
        a,
        b,
      ) =>
          true);

  void dispose() {
    _submit.close();
    _user.close();
    _password.close();
  }
}
