import 'dart:convert';

import 'package:delivery_app/src/models/client.dart';
import 'package:delivery_app/src/models/user.dart';
import 'package:delivery_app/src/pages/login.dart';
import 'package:delivery_app/src/providers/preferences.dart';
import 'package:delivery_app/src/services/registerService.dart';
import 'package:delivery_app/src/states/profileState.dart';
import 'package:delivery_app/src/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class ProfilePage extends StatefulWidget {
  final Client client;
  final double width;
  final double height;
  ProfilePage({this.client, this.width, this.height, Key key})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PreferencesUser preferencesUser;
  dynamic user;
  double width;
  double height;
  ProfileState profileState;
  RegisterService registerService;
  TextEditingController addressController;
  TextEditingController mailController;
  TextEditingController phoneController;
  TextEditingController passwordController;
  Color colorPrimary;
  Color colorSecondary;

  @override
  void initState() {
    super.initState();
    colorPrimary = visitColor;
    colorSecondary = adminColor;
    profileState = ProfileState();
    registerService = RegisterService();
    width = widget.width;
    height = widget.height;
    preferencesUser = PreferencesUser();
    if (widget.client == null) {
      if (preferencesUser.userData.length != 1) {
        user = User.fromjson(json.decode(preferencesUser.userData));
        if (user.type == "admin") {
          colorPrimary = adminColor;
          colorSecondary = visitColor;
        } else if (user.type == "seller") {
          colorSecondary = visitColor;
          colorPrimary = sellerColor;
        }
      }
    } else {
      user = widget.client;
    }

    if (user != null) {
      phoneController = TextEditingController(text: user.telephone);
      mailController = TextEditingController(text: user.email);
      addressController = TextEditingController(text: user.address);
      passwordController = TextEditingController();

      initForm();
    }
  }

  void initForm() {
    profileState.inPhone(user.telephone);
    profileState.inMail(user.email);
    profileState.inAddress(user.address);
  }

  void message(String _message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 2),
        backgroundColor: colorPrimary,
        behavior: SnackBarBehavior.floating,
        content: Text(
          _message,
          textAlign: TextAlign.justify,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: colorPrimary,
        elevation: 0,
        centerTitle: true,
        title: Text("Configuración de perfil"),
        actions: [
          user == null
              ? SizedBox()
              : GestureDetector(
                  onTap: () async {
                    await preferencesUser.reset();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(
                            height: height,
                            width: width,
                          ),
                        ));
                  },
                  child: Text("Cerrar sesión")),
        ],
      ),
      body: SingleChildScrollView(
          child: user == null
              ? Container(
                  width: width,
                  height: height * .8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: height * .01,
                      ),
                      Image.asset("assets/imgs/login_.png"),
                      SizedBox(
                        height: height * .15,
                      ),
                      Container(
                        width: width * .85,
                        child: Text(
                          "Inicia sesión o registrate para poder ver tu perfil",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: width * .05, color: Colors.black),
                        ),
                      ),
                      Container(
                        width: width * .65,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: colorPrimary),
                              borderRadius:
                                  new BorderRadius.circular(width * .015)),
                          elevation: 0,
                          color: colorPrimary,
                          textColor: Colors.white,
                          onPressed: () async {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(
                                    height: height,
                                    width: width,
                                  ),
                                ));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text("Iniciar sesión"),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: width,
                          decoration: BoxDecoration(
                              color: colorPrimary,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(width * .04),
                                  bottomRight: Radius.circular(width * .04))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Center(
                                  child: Text(
                                    user.name,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: width * .04),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    user.number,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: width * .04),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: height * .025,
                          ),
                          editable(
                              phoneController,
                              "Celular",
                              profileState.phone,
                              profileState.inPhone,
                              profileState.phoneEdit,
                              profileState.inPhoneEdit,
                              keyboard: TextInputType.phone),
                          editable(
                              mailController,
                              "Email",
                              profileState.mail,
                              profileState.inMail,
                              profileState.mailEdit,
                              profileState.inMailEdit,
                              keyboard: TextInputType.emailAddress),
                          editable(
                              addressController,
                              "Dirección",
                              profileState.address,
                              profileState.inAddress,
                              profileState.addressEdit,
                              profileState.inAddressEdit),
                          user is User
                              ? editable(
                                  passwordController,
                                  "Nueva contraseña",
                                  profileState.password,
                                  profileState.inPassword,
                                  profileState.passwordEdit,
                                  profileState.inPasswordEdit,
                                  pwd: true)
                              : SizedBox(),
                          SizedBox(
                            height: height * .05,
                          ),
                          StreamBuilder<Object>(
                              initialData: false,
                              stream: user is User
                                  ? profileState.updateUser
                                  : profileState.updateClient,
                              builder: (context, snapshot) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: width * .65,
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          side:
                                              BorderSide(color: colorSecondary),
                                          borderRadius:
                                              new BorderRadius.circular(
                                                  width * .015)),
                                      elevation: 0,
                                      color: colorSecondary,
                                      textColor: Colors.white,
                                      onPressed: () async {
                                        if (snapshot.data) {
                                          Map temporal = {
                                            "email": mailController.text,
                                            "telephone": phoneController.text,
                                            "address": addressController.text
                                          };
                                          if (user is User) {
                                            User tmp = user;
                                            temporal.putIfAbsent("password",
                                                () => passwordController.text);
                                            temporal.putIfAbsent(
                                                "number", () => tmp.number);
                                            temporal.putIfAbsent(
                                                "name", () => tmp.name);
                                            temporal.putIfAbsent(
                                                "id", () => tmp.id);

                                            if (await registerService
                                                .updateClient(temporal)) {
                                              await preferencesUser.reset();
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        LoginPage(
                                                      height: height,
                                                      width: width,
                                                    ),
                                                  ));
                                            } else {
                                              message(
                                                  "Ocurrió un error, verifique los datos");
                                            }
                                          } else {
                                            Client tmp = user;
                                            temporal.putIfAbsent(
                                                "type", () => "customers");
                                            temporal.putIfAbsent(
                                                "number", () => tmp.number);
                                            temporal.putIfAbsent(
                                                "id", () => tmp.id);
                                            temporal.putIfAbsent(
                                                "name", () => tmp.name);
                                            temporal.putIfAbsent(
                                                "identity_document_type_id",
                                                () =>
                                                    tmp.identityDocumentTypeId);
                                            temporal.putIfAbsent(
                                                "country_id", () => "PE");
                                            if (await registerService
                                                .update(temporal)) {
                                              message("Datos Actualizados");
                                              tmp.email = mailController.text;
                                              tmp.telephone =
                                                  phoneController.text;
                                              tmp.address =
                                                  addressController.text;
                                              Navigator.pop(context, tmp);
                                            } else {
                                              message(
                                                  "Ocurrió un error, verifique los datos");
                                            }
                                          }
                                        }
                                      },
                                      child: Text(
                                        "Enviar cambios",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ],
                      )
                    ],
                  ),
                )),
    );
  }

  StreamBuilder editable(TextEditingController ctrl, String label,
      Stream stream, Function sink, Stream streamEdit, Function sinkEdit,
      {bool pwd, bool noEditable, TextInputType keyboard}) {
    return StreamBuilder(
      initialData: false,
      stream: streamEdit,
      builder: (context, snap) => Container(
        margin: EdgeInsets.only(top: height * .012),
        width: width * .85,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(label,
                    style: TextStyle(
                        color: snap.data
                            ? colorPrimary
                            : Colors.black.withOpacity(.5).withOpacity(.5))),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: StreamBuilder(
                    stream: stream,
                    builder: (context, snapshot) => TextFormField(
                        keyboardType: keyboard ?? TextInputType.text,
                        obscureText: pwd ?? false,
                        onTap: () => ctrl.selection = TextSelection(
                            baseOffset: 0, extentOffset: ctrl.text.length),
                        cursorColor: colorPrimary,
                        enabled: snap.data,
                        onChanged: sink,
                        controller: ctrl,
                        style: TextStyle(
                            color: snap.data
                                ? colorPrimary
                                : Colors.black.withOpacity(.5)),
                        decoration: InputDecoration(
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(204, 68, 0, 1))),
                          errorText: snapshot.error,
                          errorStyle: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                          contentPadding: EdgeInsets.all(height * .015),
                          isDense: true,
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: snap.data
                                    ? colorPrimary
                                    : Colors.black.withOpacity(.5),
                                width: 0.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: snap.data
                                    ? colorPrimary
                                    : Colors.black.withOpacity(.5),
                                width: 0.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: colorPrimary)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: colorPrimary)),
                        )),
                  ),
                ),
                SizedBox(
                  width: width * .01,
                ),
                noEditable == null
                    ? GestureDetector(
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: snap.data
                                  ? colorSecondary
                                  : Colors.transparent),
                          child: Icon(
                            Icons.edit,
                            color: snap.data
                                ? Colors.white
                                : Colors.black.withOpacity(.5),
                          ),
                        ),
                        onTap: () {
                          profileState.editable(streamEdit);
                        },
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          FontAwesome.edit,
                          color: Colors.transparent,
                        ),
                      )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    profileState.dispose();
    super.dispose();
  }
}
