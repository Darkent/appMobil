class NumeroLetras {
  RegExp r = RegExp("[0-9]");

  List _unidades = [
    "",
    "un ",
    "dos ",
    "tres ",
    "cuatro ",
    "cinco ",
    "seis ",
    "siete ",
    "ocho ",
    "nueve "
  ];
  List _decenas = [
    "die ",
    "once ",
    "doce ",
    "trece ",
    "catorce ",
    "quince ",
    "dieciseis ",
    "diecisiete ",
    "dieciocho ",
    "diecinueve ",
    "veinte ",
    "treinta ",
    "cuarenta ",
    "cincuenta ",
    "sesenta ",
    "setenta ",
    "ochenta ",
    "noventa "
  ];
  List _centenas = [
    "",
    "ciento ",
    "doscientos ",
    "trecientos ",
    "cuatrocientos ",
    "quinientos ",
    "seiscientos ",
    "setecientos ",
    "ochocientos ",
    "novecientos "
  ];

  NumeroLetras();

  /* funciones para convertir los numeros a literales */
  _getUnidades(String numero) {
    // 1 - 9
    //si tuviera algun 0 antes se lo quita -> 09 = 9 o 009=9
    String nume = numero.substring(numero.length - 1);
    return _unidades[int.parse(nume)];
  }

  _getDecenas(String num) {
    // 99
    int n = int.parse(num);
    if (n < 10) {
      //para casos como -> 01 - 09
      return _getUnidades(num);
    } else if (n > 19) {
      //para 20...99
      String u = _getUnidades(num);
      if (u == "") {
        //para 20,30,40,50,60,70,80,90
        return _decenas[int.parse(num.substring(0, 1)) + 8];
      } else {
        return _decenas[int.parse(num.substring(0, 1)) + 8] + "y " + u;
      }
    } else {
      //numeros entre 11 y 19
      return _decenas[n - 10];
    }
  }

  _getCentenas(String num) {
    // 999 o 099
    if (int.parse(num) > 99) {
      //es centena
      if (int.parse(num) == 100) {
        //caso especial
        return "cien ";
      } else {
        return _centenas[int.parse(num.substring(0, 1))] +
            _getDecenas(num.substring(1));
      }
    } else {
      //por Ej. 099
      //se quita el 0 antes de convertir a decenas
      return _getDecenas(int.parse(num).toString());
    }
  }

  _getMiles(String numero) {
    // 999 999
    //obtiene las centenas
    String c = numero.substring(numero.length - 3);
    //obtiene los miles
    String m = numero.substring(0, numero.length - 3);
    String n = "";
    //se comprueba que miles tenga valor entero
    if (int.parse(m) > 0) {
      n = _getCentenas(m);

      return (n == "un" ? "" : "$n") + "mil " + _getCentenas(c);
    } else {
      return "" + _getCentenas(c);
    }
  }

  _getMillones(String numero) {
    String miles = numero.substring(numero.length - 6);

    String millon = numero.substring(0, numero.length - 6);
    String n = "";
    if (millon.length > 1) {
      n = _getCentenas(millon) + "millones ";
    } else {
      n = _getUnidades(millon) + "millon ";
    }
    return n + _getMiles(miles);
  }

  String convertir(String numero) {
    String literal = "";
    if (r.hasMatch(numero)) {
      List num = numero.split(".");
      if (int.parse(num[0]) == 0) {
        literal = "cero ";
      } else if (int.parse(num[0]) > 999999) {
        literal = _getMillones(num[0]);
      } else if (int.parse(num[0]) > 999) {
        literal = _getMiles(num[0]);
      } else if (int.parse(num[0]) > 99) {
        literal = _getCentenas(num[0]);
      } else if (int.parse(num[0]) > 9) {
        literal = _getDecenas(num[0]);
      } else {
        literal = _getUnidades(num[0]);
      }

      if (num.length != 1) {
        literal += " con ${num[1]}/100 soles ";
      }
      return (literal.toUpperCase());
    } else {
      return literal = null;
    }
  }
}
