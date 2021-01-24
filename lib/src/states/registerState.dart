import 'package:delivery_app/src/providers/validator.dart';
import 'package:rxdart/rxdart.dart';

class RegisterState with Validators {
  //TYPE
  BehaviorSubject<bool> _typePerson = BehaviorSubject<bool>.seeded(false);
  Function(bool) get inType => _typePerson.sink.add;
  Stream<bool> get type => _typePerson.stream;
  bool get typeValue => _typePerson.value;
  //NAME
  BehaviorSubject<String> _name = BehaviorSubject<String>();
  Function(String) get inName => _name.sink.add;
  Stream<String> get name => _name.stream.transform(noEmpty);
  String get nameValue => _name.value;

  BehaviorSubject<String> _password = BehaviorSubject<String>();
  Function(String) get inPassword => _password.sink.add;
  Stream<String> get password => _password.stream.transform(noEmpty);
  String get passwordValue => _password.value;

  //MAIL
  BehaviorSubject<String> _mail = BehaviorSubject<String>();
  Function(String) get inMail => _mail.sink.add;
  Stream<String> get mail => _mail.stream.transform(emailValidator);
  String get mailValue => _mail.value;

  //CELULAR
  BehaviorSubject<String> _phone = BehaviorSubject<String>();
  Function(String) get inPhone => _phone.sink.add;
  Stream<String> get phone => _phone.stream.transform(phoneValidator);
  String get phoneValue => _phone.value;

  //DNI
  BehaviorSubject<String> _dni = BehaviorSubject<String>();
  Function(String) get inDni => _dni.sink.add;
  Stream<String> get dni => _dni.stream.transform(dniValidator);
  String get dniValue => _dni.value;
//RUC

  BehaviorSubject<String> _ruc = BehaviorSubject<String>();
  Function(String) get inRuc => _ruc.sink.add;
  Stream<String> get ruc => _ruc.stream.transform(rucValidator);
  String get rucValue => _ruc.value;

  //DIRECCION
  BehaviorSubject<String> _address = BehaviorSubject<String>();
  Function(String) get inAddress => _address.sink.add;
  Stream<String> get address => _address.stream.transform(noEmpty);
  String get addressValue => _address.value;

  BehaviorSubject<bool> _registerDniCustomers =
      BehaviorSubject<bool>.seeded(false);
  Stream<bool> get registerDniCustomers => CombineLatestStream.combine5(
      _name,
      _address,
      _phone,
      _mail,
      _dni,
      (
        a,
        b,
        c,
        d,
        e,
      ) =>
          true);
  Function(bool) get inRegisterDniCustomers => _registerDniCustomers.sink.add;

  BehaviorSubject<bool> _registerDni = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get registerDni => CombineLatestStream.combine6(
      _name,
      _address,
      _phone,
      _mail,
      _password,
      _dni,
      (
        a,
        b,
        c,
        d,
        e,
        f,
      ) =>
          true);
  Function(bool) get inRegisterDni => _registerDni.sink.add;
  BehaviorSubject<bool> _registerRucCustomers =
      BehaviorSubject<bool>.seeded(false);
  Stream<bool> get registerRucCustomers => CombineLatestStream.combine5(
      _name,
      _address,
      _phone,
      _mail,
      _ruc,
      (
        a,
        b,
        c,
        d,
        e,
      ) =>
          true);
  Function(bool) get inRegisterRucCustomers => _registerRucCustomers.sink.add;

  BehaviorSubject<bool> _registerRuc = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get registerRuc => CombineLatestStream.combine6(
      _name,
      _address,
      _phone,
      _mail,
      _password,
      _ruc,
      (
        a,
        b,
        c,
        d,
        e,
        f,
      ) =>
          true);
  Function(bool) get inRegisterRuc => _registerRuc.sink.add;

  void dispose() {
    _registerRucCustomers.close();
    _registerDniCustomers.close();
    _registerRuc.close();
    _typePerson.close();
    _registerDni.close();
    _password.close();
    _address.close();
    _mail.close();
    _phone.close();
    _ruc.close();
    _dni.close();
    _name.close();
  }
}
