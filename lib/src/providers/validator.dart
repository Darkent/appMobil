import 'dart:async';

mixin Validators {
  final StreamTransformer emailValidator =
      StreamTransformer<String, String>.fromHandlers(
          handleData: (String email, EventSink<String> sink) {
    if (email == "-" ||
        RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(email)) {
      sink.add(email);
    } else {
      sink.addError("Ingrese un correo valido");
    }
  });

  final StreamTransformer noEmpty =
      StreamTransformer<String, String>.fromHandlers(
          handleData: (String value, EventSink<String> sink) {
    if (value.length != 0 && value != null) {
      sink.add(value);
    } else {
      sink.addError("El campo es obligatorio");
    }
  });

  final StreamTransformer dniValidator =
      StreamTransformer<String, String>.fromHandlers(
          handleData: (String dni, EventSink<String> sink) {
    if (RegExp(r'^[0-9]{8}$').hasMatch(dni)) {
      sink.add(dni);
    } else {
      sink.addError("DNI inválido");
    }
  });

  final StreamTransformer rucValidator =
      StreamTransformer<String, String>.fromHandlers(
          handleData: (String ruc, EventSink<String> sink) {
    if (RegExp(r'^[0-9]{11}$').hasMatch(ruc)) {
      sink.add(ruc);
    } else {
      sink.addError("RUC inválido");
    }
  });

  final StreamTransformer phoneValidator =
      StreamTransformer<String, String>.fromHandlers(
          handleData: (String phone, EventSink<String> sink) {
    if (RegExp(r'^[0-9]{7}$').hasMatch(phone) ||
        RegExp(r'^\9[0-9]{8}$').hasMatch(phone)) {
      sink.add(phone);
    } else {
      sink.addError("Teléfono inválido");
    }
  });
}
