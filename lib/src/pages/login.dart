import 'package:delivery_app/main.dart';
import 'package:delivery_app/src/pages/home.dart';
import 'package:delivery_app/src/pages/register.dart';
import 'package:delivery_app/src/services/loginService.dart';
import 'package:delivery_app/src/states/loginState.dart';
import 'package:delivery_app/src/utils/colors.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final double width;
  final double height;
  LoginPage({this.width, this.height, Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double width;
  double height;
  double top;
  LoginState loginState;
  LoginService loginService;
  @override
  void initState() {
    super.initState();
    loginService = LoginService();
    loginState = LoginState();
    width = widget.width;
    height = widget.height;
    top = (height * .45) * -1;
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
      backgroundColor: visitColor,
      body: SingleChildScrollView(
        child: Container(
          width: width,
          height: height,
          child: Container(
            width: width,
            height: height,
            child: Stack(
              children: [
                Container(
                  width: width,
                  height: height,
                ),
                Positioned(
                  child: Container(
                    height: height * .6,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: width,
                          decoration: BoxDecoration(
                              color: visitColor,
                              image: DecorationImage(
                                  image: NetworkImage(
                                      'https://media.bizj.us/view/img/11066947/grocery-store*750xx2096-1181-0-57.jpg'),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                      Colors.green.withOpacity(0.2),
                                      BlendMode.luminosity))),
                        ),
                        Container(
                          width: width,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              gradient: LinearGradient(
                                  begin: FractionalOffset.topCenter,
                                  end: FractionalOffset.bottomCenter,
                                  colors: [
                                    visitColor.withOpacity(0.3),
                                    visitColor.withOpacity(0.5),
                                    visitColor.withOpacity(0.8),
                                    visitColor.withOpacity(1)
                                  ],
                                  stops: [
                                    0.0,
                                    .6,
                                    .9,
                                    1.1
                                  ])),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: height * .05,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      "BIENVENIDO",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: width * .07,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      "Inicia sesión para empezar a comprar",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: width * .05),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: width * .1,
                  top: height * .26,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(width * .05)),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(width * 0.05, height * 0.05,
                          width * 0.05, height * 0.05),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StreamBuilder(
                            stream: loginState.user,
                            builder: (context, snapshot) => Container(
                              width: width * .6,
                              child: TextField(
                                onChanged: loginState.sendUser,
                                decoration: InputDecoration(
                                  hintText: "Email",
                                  errorText: snapshot.error,
                                  prefixIcon: Icon(Icons.person),
                                  isDense: true,
                                  contentPadding: EdgeInsets.fromLTRB(
                                      width * .02,
                                      width * .03,
                                      width * .02,
                                      width * .03),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height * .025,
                          ),
                          StreamBuilder(
                            stream: loginState.password,
                            builder: (context, snapshot) => Container(
                              width: width * .6,
                              child: TextField(
                                onChanged: loginState.sendPassword,
                                obscureText: true,
                                decoration: InputDecoration(
                                  errorText: snapshot.error,
                                  hintText: "Contraseña",
                                  prefixIcon: Icon(Icons.lock),
                                  isDense: true,
                                  contentPadding: EdgeInsets.fromLTRB(
                                      width * .02,
                                      width * .03,
                                      width * .02,
                                      width * .03),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height * .05,
                          ),
                          StreamBuilder(
                            initialData: false,
                            stream: loginState.submit,
                            builder: (context, snapshot) => Container(
                              width: width * .65,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(color: visitColor),
                                    borderRadius: new BorderRadius.circular(
                                        width * .015)),
                                elevation: 0,
                                color: visitColor,
                                textColor: Colors.white,
                                onPressed: snapshot.data
                                    ? () async {
                                        Map body = {
                                          "email": "${loginState.userValue}",
                                          "password":
                                              "${loginState.passwordValue}"
                                        };

                                        if (await loginService
                                            .loginRequest(body)) {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomePage(
                                                        pwd: loginState
                                                            .passwordValue,
                                                        height: height,
                                                        width: width,
                                                      )));
                                        } else {
                                          message(
                                              "El usuario y/o contraseña no existe.");
                                        }
                                      }
                                    : () => message("Ingresa datos validos."),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text("Ingresar"),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  top: height * .65,
                  child: Center(
                      child: Container(
                          padding: EdgeInsets.all(10),
                          child: Center(
                            child: RichText(
                              text: TextSpan(
                                text: '¿No tienes una cuenta?',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ))),
                ),
                Positioned.fill(
                    top: height * .85,
                    child: Column(
                      children: [
                        Container(
                          width: width * .65,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color: visitColor),
                                borderRadius:
                                    new BorderRadius.circular(width * .015)),
                            elevation: 0,
                            color: adminColor,
                            textColor: Colors.white,
                            onPressed: () async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Register(
                                            visitor: true,
                                            height: height,
                                            width: width,
                                          )));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                "Registrate",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    loginState.dispose();
    super.dispose();
  }
}
