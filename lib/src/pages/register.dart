import 'dart:convert';

import 'package:delivery_app/src/models/client.dart';
import 'package:delivery_app/src/models/user.dart';
import 'package:delivery_app/src/pages/home.dart';
import 'package:delivery_app/src/providers/preferences.dart';
import 'package:delivery_app/src/services/clientService.dart';
import 'package:delivery_app/src/services/loginService.dart';
import 'package:delivery_app/src/services/registerService.dart';
import 'package:delivery_app/src/states/registerState.dart';
import 'package:delivery_app/src/utils/colors.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  final bool visitor;
  final double width;
  final double height;
  Register({this.width, this.height, this.visitor, Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController name;
  TextEditingController address;
  double width;
  double height;
  TextEditingController number;
  RegisterState registerState;
  RegisterService registerService;
  PreferencesUser preferencesUser;
  ClientService clientService;
  LoginService loginService;
  bool visitor;
  User user;
  Color colorPrimary;
  @override
  void initState() {
    super.initState();
    loginService = LoginService();
    preferencesUser = PreferencesUser();
    visitor = widget.visitor;
    colorPrimary = Colors.blue;
    if (visitor == null) {
      preferencesUser = PreferencesUser();

      user = User.fromjson(json.decode(preferencesUser.userData));
      if (user.type == "admin") {
        colorPrimary = adminColor;
      } else if (user.type == "seller") {
        colorPrimary = sellerColor;
      }
    }
    clientService = ClientService();
    registerService = RegisterService();
    registerState = RegisterState();
    name = TextEditingController();
    address = TextEditingController();
    number = TextEditingController();
    width = widget.width;
    height = widget.height;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrimary,
        title: Text("Ingresar cliente"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("RUC"),
                  StreamBuilder(
                    initialData: false,
                    stream: registerState.type,
                    builder: (context, snapshot) => Switch(
                        value: snapshot.data,
                        onChanged: (v) {
                          name.clear();
                          address.clear();
                          number.clear();
                          registerState.inType(v);
                        }),
                  ),
                  Text("DNI")
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StreamBuilder(
                      initialData: false,
                      stream: registerState.type,
                      builder: (context, snapshot) => field(
                          snapshot.data ? registerState.dni : registerState.ruc,
                          snapshot.data
                              ? registerState.inDni
                              : registerState.inRuc,
                          snapshot.data ? "Ingrese DNI" : "Ingrese RUC",
                          snapshot.data
                              ? Icons.assignment_ind
                              : Icons.filter_9_plus,
                          keyboard: TextInputType.number,
                          controller: number)),
                  IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () async {
                        String query = registerState.typeValue
                            ? registerState.dniValue
                            : registerState.rucValue;

                        Client temporal = await clientService.getData(
                            registerState.typeValue, query);

                        if (registerState.typeValue) {
                          registerState.inName(temporal.name);
                          name.text = temporal.name;
                        } else {
                          registerState.inName(temporal.name);
                          registerState.inAddress(temporal.address);
                          name.text = temporal.name;
                          address.text = temporal.address;
                        }
                      })
                ],
              ),
              Divider(),
              StreamBuilder(
                  initialData: false,
                  stream: registerState.type,
                  builder: (context, snapshot) => field(
                      registerState.name,
                      registerState.inName,
                      snapshot.data ? "Ingrese Nombre" : "Ingrese Razon Social",
                      snapshot.data ? Icons.person : Icons.business,
                      controller: name)),
              field(registerState.mail, registerState.inMail, "Ingrese Email",
                  Icons.email,
                  keyboard: TextInputType.emailAddress),
              field(registerState.phone, registerState.inPhone,
                  "Ingrese Celular", Icons.phone,
                  keyboard: TextInputType.phone),
              field(registerState.address, registerState.inAddress,
                  "Ingrese Dirección", Icons.location_on,
                  controller: address),
              visitor != null
                  ? field(registerState.password, registerState.inPassword,
                      "Ingrese su contraseña", Icons.vpn_key,
                      pwd: true)
                  : SizedBox(),
              Container(
                width: width * .65,
                child: StreamBuilder(
                  stream: registerState.type,
                  initialData: false,
                  builder: (context, snapshot) {
                    if (snapshot.data) {
                      return StreamBuilder(
                          initialData: false,
                          stream: visitor != null
                              ? registerState.registerDni
                              : registerState.registerDniCustomers,
                          builder: (context, snapshot) => RaisedButton(
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(color: colorPrimary),
                                    borderRadius: new BorderRadius.circular(
                                        width * .015)),
                                elevation: 0,
                                color: colorPrimary,
                                textColor: Colors.white,
                                onPressed: () async {
                                  if (snapshot.data && number.text.isNotEmpty) {
                                    if (visitor != null) {
                                      Map body = dataClient(false);
                                      if (await registerService
                                          .registerClient(body)) {
                                        Map login = {
                                          "email": body['email'],
                                          "password": body['pswd']
                                        };
                                        if (await loginService
                                            .loginRequest(login)) {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomePage(
                                                        height: height,
                                                        width: width,
                                                        pwd: body['pswd'],
                                                      )));
                                        }
                                      }
                                    } else {
                                      Map body = data(false);
                                      Map _response =
                                          await registerService.register(body);
                                      if (_response['success']) {
                                        Navigator.pop(
                                            context, Client.fromJson(body));
                                      }
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text("Registrate"),
                                ),
                              ));
                    } else {
                      return StreamBuilder(
                          initialData: false,
                          stream: visitor != null
                              ? registerState.registerRuc
                              : registerState.registerRucCustomers,
                          builder: (context, snapshot) => RaisedButton(
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(color: colorPrimary),
                                    borderRadius: new BorderRadius.circular(
                                        width * .015)),
                                elevation: 0,
                                color: colorPrimary,
                                textColor: Colors.white,
                                onPressed: () async {
                                  if (snapshot.data && number.text.isNotEmpty) {
                                    if (visitor != null) {
                                      Map body = dataClient(true);
                                      if (await registerService
                                          .registerClient(body)) {
                                        Map login = {
                                          "email": body['email'],
                                          "password": body['pswd']
                                        };
                                        if (await loginService
                                            .loginRequest(login)) {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomePage(
                                                        height: height,
                                                        width: width,
                                                        pwd: body['pswd'],
                                                      )));
                                        }
                                      }
                                    } else {
                                      Map body = data(true);
                                      Map _response =
                                          await registerService.register(body);
                                      if (_response['success']) {
                                        Navigator.pop(
                                            context, Client.fromJson(body));
                                      }
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text("Registrate"),
                                ),
                              ));
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Map dataClient(bool ruc) {
    Map _data = {};
    _data.putIfAbsent("pswd", () => registerState.passwordValue);
    _data.putIfAbsent("address", () => registerState.addressValue);
    _data.putIfAbsent("email", () => registerState.mailValue);
    _data.putIfAbsent("name", () => registerState.nameValue);
    _data.putIfAbsent("telephone", () => registerState.phoneValue);
    _data.putIfAbsent("establishment_id", () => "1");
    _data.putIfAbsent("identity_document_type_id", () => ruc ? "6" : "1");
    _data.putIfAbsent(
        "number", () => ruc ? registerState.rucValue : registerState.dniValue);

    return _data;
  }

  Map data(bool ruc) {
    Map _data = {
      "country_id": "PE",
      "addresses": [],
      "percentage_perception": 0,
      "perception_agent": false,
      "type": "customers"
    };
    _data.putIfAbsent("address", () => registerState.addressValue);
    _data.putIfAbsent("email", () => registerState.mailValue);
    _data.putIfAbsent("name", () => registerState.nameValue);
    _data.putIfAbsent("telephone", () => registerState.phoneValue);
    _data.putIfAbsent("identity_document_type_id", () => ruc ? "6" : "1");
    _data.putIfAbsent(
        "number", () => ruc ? registerState.rucValue : registerState.dniValue);

    return _data;
  }

  StreamBuilder field(Stream stream, Function sink, String label, IconData icon,
      {bool pwd, TextInputType keyboard, TextEditingController controller}) {
    return StreamBuilder(
        stream: stream,
        builder: (context, snapshot) => Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                width: width * .75,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    // override textfield's icon color when selected
                    primaryColor: colorPrimary,
                  ),
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboard ?? TextInputType.text,
                    onChanged: sink,
                    obscureText: pwd ?? false,
                    decoration: InputDecoration(
                      errorText: snapshot.error,
                      hintText: label,
                      suffixIcon: Icon(icon),
                      isDense: true,
                      contentPadding: EdgeInsets.fromLTRB(
                          width * .02, width * .03, width * .02, width * .03),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorPrimary)),
                    ),
                  ),
                ),
              ),
            ));
  }

  @override
  void dispose() {
    registerState.dispose();
    super.dispose();
  }
}
