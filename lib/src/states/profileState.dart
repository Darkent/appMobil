import 'package:delivery_app/src/providers/validator.dart';
import 'package:rxdart/rxdart.dart';

class ProfileState with Validators {
  List<BehaviorSubject<bool>> _list;
  //NAME
  BehaviorSubject<String> _name = BehaviorSubject<String>();
  Function(String) get inName => _name.sink.add;
  Stream<String> get name => _name.stream.transform(noEmpty);
  String get nameValue => _name.value;

  BehaviorSubject<String> _password = BehaviorSubject<String>();
  Function(String) get inPassword => _password.sink.add;
  Stream<String> get password => _password.stream.transform(noEmpty);
  String get passwordValue => _password.value;

  BehaviorSubject<bool> _passwordEdit = BehaviorSubject<bool>();
  Function(bool) get inPasswordEdit => _passwordEdit.sink.add;
  Stream<bool> get passwordEdit => _passwordEdit.stream;
  //MAIL
  BehaviorSubject<String> _mail = BehaviorSubject<String>();
  Function(String) get inMail => _mail.sink.add;
  Stream<String> get mail => _mail.stream.transform(emailValidator);
  String get mailValue => _mail.value;

  BehaviorSubject<bool> _mailEdit = BehaviorSubject<bool>();
  Function(bool) get inMailEdit => _mailEdit.sink.add;
  Stream<bool> get mailEdit => _mailEdit.stream;
  //CELULAR
  BehaviorSubject<String> _phone = BehaviorSubject<String>();
  Function(String) get inPhone => _phone.sink.add;
  Stream<String> get phone => _phone.stream.transform(phoneValidator);
  String get phoneValue => _phone.value;

  BehaviorSubject<bool> _phoneEdit = BehaviorSubject<bool>();
  Function(bool) get inPhoneEdit => _phoneEdit.sink.add;
  Stream<bool> get phoneEdit => _phoneEdit.stream;
  //DNI
  BehaviorSubject<String> _dni = BehaviorSubject<String>();
  Function(String) get inDni => _dni.sink.add;
  Stream<String> get dni => _dni.stream;
  String get dniValue => _dni.value;

  BehaviorSubject<String> _ruc = BehaviorSubject<String>();
  Function(String) get inRuc => _ruc.sink.add;
  Stream<String> get ruc => _ruc.stream;
  String get rucValue => _ruc.value;

  //DIRECCION
  BehaviorSubject<String> _address = BehaviorSubject<String>();
  Function(String) get inAddress => _address.sink.add;
  Stream<String> get address => _address.stream.transform(noEmpty);
  String get addressValue => _address.value;

  BehaviorSubject<bool> _addressEdit = BehaviorSubject<bool>();
  Function(bool) get inAddressEdit => _addressEdit.sink.add;
  Stream<bool> get addressEdit => _addressEdit.stream;
  BehaviorSubject<bool> _updateClient = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get updateClient => CombineLatestStream.combine3(
      _phone,
      _address,
      _mail,
      (
        a,
        b,
        c,
      ) =>
          true);

  BehaviorSubject<bool> _updateUser = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get updateUser => CombineLatestStream.combine4(
      _phone,
      _address,
      _mail,
      _password,
      (
        a,
        b,
        c,
        d,
      ) =>
          true);
  Function(bool) get inUpdateUser => _updateUser.sink.add;

  ProfileState() {
    _list = [_phoneEdit, _mailEdit, _addressEdit, _passwordEdit];
  }

  void editable(Stream<bool> s) {
    if (s != null) {
      _list.forEach((element) {
        if (element.stream != s) {
          element.sink.add(false);
        } else {
          if (element.value != null && element?.value == true) {
            element.sink.add(false);
          } else {
            element.sink.add(true);
          }
        }
      });
    } else {
      _list.forEach((element) {
        if (element.stream != s) {
          element.sink.add(false);
        } else {
          element.sink.add(false);
        }
      });
    }
  }

  void dispose() {
    _updateUser.close();
    _passwordEdit.close();
    _password.close();
    _updateClient.close();
    _phoneEdit.close();
    _addressEdit.close();
    _mailEdit.close();
    _address.close();
    _mail.close();
    _phone.close();
    _ruc.close();
    _dni.close();

    _name.close();
  }
}
