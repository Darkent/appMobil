import 'dart:convert';

import 'package:delivery_app/main.dart';
import 'package:delivery_app/src/models/purchase.dart';
import 'package:delivery_app/src/models/user.dart';
import 'package:delivery_app/src/pages/viewPdf.dart';
import 'package:delivery_app/src/providers/preferences.dart';
import 'package:delivery_app/src/services/shopCarService.dart';
import 'package:delivery_app/src/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PurchasesPage extends StatefulWidget {
  final double width;
  final double height;
  PurchasesPage({this.width, this.height, Key key}) : super(key: key);

  @override
  _PurchasesPageState createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double width;
  double height;
  PreferencesUser preferencesUser;
  ShopCarService shopCarService;
  List<dynamic> externalIds;
  List<Purchase> purchases;
  NumberFormat format;
  User user;
  @override
  void initState() {
    super.initState();
    format = NumberFormat("#,##0.00", "en_US");
    purchases = [];
    shopCarService = ShopCarService();
    preferencesUser = PreferencesUser();
    user = User.fromjson(json.decode(preferencesUser.userData));
    colorPrimary = visitColor;
    width = widget.width;
    height = widget.height;
    print(user.id);
  }

  void message(String _message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 2),
        backgroundColor: colorSecondary,
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
        appBar: AppBar(
          backgroundColor: colorPrimary,
          elevation: 0,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(right: width * .05),
                child: Icon(Icons.view_list),
              ),
              Text("Historial de compras")
            ],
          ),
        ),
        body: Container(
          child: FutureBuilder(
              future: shopCarService.getAllPurchases(user.id),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.isEmpty) {
                    return Center(child: Text("No tiene pedidos realizados"));
                  } else {
                    return orderShow(snapshot.data);
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ));
  }

  Container orderShow(List<Purchase> list) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: list
              .map<Widget>((e) => GestureDetector(
                    onTap: () async {
                      await show(e).then((value) {
                        if (value != null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PdfViewer(
                                        user: user,
                                        purchase: e,
                                        document: e.document,
                                        externalId: e.documentExternalId,
                                      )));
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Center(
                        child: Container(
                          width: width * .9,
                          height: height * .23,
                          child: Card(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: width * .75,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                            e.documents.isEmpty
                                                ? "PEDIDO PENDIENTE"
                                                : "PAGO PROCESADO",
                                            style: TextStyle(
                                                color: e.documents.isEmpty
                                                    ? colorPrimary
                                                    : colorSecondary,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Row(
                                            children: [
                                              Text(
                                                "Fecha Pedido: ",
                                                style: TextStyle(
                                                    fontSize: width * .035,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                formatDate(e.date),
                                                style: TextStyle(
                                                    fontSize: width * .035),
                                              ),
                                            ],
                                          )),
                                      e.documents.isNotEmpty
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Fecha Emisión: ",
                                                    style: TextStyle(
                                                        fontSize: width * .035,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    formatDate(e.date),
                                                    style: TextStyle(
                                                        fontSize: width * .035),
                                                  ),
                                                ],
                                              ))
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Documento solicitado: ",
                                                    style: TextStyle(
                                                        fontSize: width * .035,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    documentToEmit(e.document),
                                                    style: TextStyle(
                                                        fontSize: width * .035),
                                                  ),
                                                ],
                                              )),
                                      Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    "Items: ",
                                                    style: TextStyle(
                                                        fontSize: width * .035,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    e.items.length.toString(),
                                                    style: TextStyle(
                                                        fontSize: width * .035),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "Total: ",
                                                    style: TextStyle(
                                                        fontSize: width * .035,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    "S/. ${e.amount.toStringAsFixed(2)}",
                                                    style: TextStyle(
                                                        color: colorSecondary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: width * .035),
                                                  ),
                                                ],
                                              ),
                                              SizedBox()
                                            ],
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Future show(Purchase order) {
    return showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return SafeArea(
            child: Transform(
              transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
              child: Opacity(
                opacity: a1.value,
                child: Dialog(
                  insetPadding: EdgeInsets.all(height * .01),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Container(
                      width: width * .97,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            height: height * .005,
                          ),
                          Container(
                            width: width,
                            child: Column(
                              children: [
                                Table(
                                  children: [
                                    TableRow(children: [
                                      Text(
                                        user.number.length == 8
                                            ? "DNI"
                                            : "RUC: ",
                                        style: TextStyle(
                                            fontSize: width * .035,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        user.number,
                                        style:
                                            TextStyle(fontSize: width * .035),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      Text(
                                        "Email",
                                        style: TextStyle(
                                            fontSize: width * .035,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        user.email,
                                        style:
                                            TextStyle(fontSize: width * .035),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      Text(
                                        "Fecha Pedido: ",
                                        style: TextStyle(
                                            fontSize: width * .035,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        formatDate(order.date),
                                        style:
                                            TextStyle(fontSize: width * .035),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      Text(
                                        "Dirección: ",
                                        style: TextStyle(
                                            fontSize: width * .035,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        user.address,
                                        style:
                                            TextStyle(fontSize: width * .035),
                                      ),
                                    ]),
                                    order.documents.isEmpty
                                        ? TableRow(children: [
                                            Text(
                                              "Documento de Pago: ",
                                              style: TextStyle(
                                                  fontSize: width * .035,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              documentToEmit(order.document),
                                              style: TextStyle(
                                                  fontSize: width * .035),
                                            ),
                                          ])
                                        : TableRow(children: [
                                            Text(
                                              "N° de Documento: ",
                                              style: TextStyle(
                                                  fontSize: width * .035,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              order.documents
                                                      .first["number_full"] ??
                                                  order.documents
                                                      .first["identifier"],
                                              style: TextStyle(
                                                  fontSize: width * .035),
                                            ),
                                          ]),
                                    TableRow(children: [
                                      Text(
                                        "Número de items: ",
                                        style: TextStyle(
                                            fontSize: width * .035,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        order.items.length.toString(),
                                        style:
                                            TextStyle(fontSize: width * .035),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      Text(
                                        "Precio total: ",
                                        style: TextStyle(
                                            fontSize: width * .035,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        order.amount.toStringAsFixed(2),
                                        style:
                                            TextStyle(fontSize: width * .035),
                                      ),
                                    ]),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: height * .3,
                            width: width * .9,
                            child: ListView(
                              children: order.items
                                  .map<Widget>((e) => Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              width: width * .75,
                                              height: height * .13,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    e.description,
                                                    maxLines: 2,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    "S/.${(double.parse(e.subtotal) * 1.18).toStringAsFixed(2)}",
                                                    maxLines: 1,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Cant.: ",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        e.quantity.toString(),
                                                        maxLines: 1,
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              scrollDirection: Axis.vertical,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              order.documents.isEmpty
                                  ? SizedBox()
                                  : Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: RaisedButton(
                                        onPressed: () async {
                                          Navigator.pop(context, true);
                                        },
                                        child: Text("Ver Documento"),
                                        textColor: Colors.white,
                                        color: Colors.blue,
                                      ),
                                    ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: RaisedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Cerrar"),
                                  textColor: Colors.white,
                                  color: colorPrimary,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) => null);
  }

  String formatDate(String date) {
    DateTime _date = DateTime.parse(date);

    return "${_format(_date.day)}/${_format(_date.month)}/${_format(_date.year)}";
  }

  String _format(int b) {
    String z = b.toString();

    return z.length == 1 ? "0" + z : z;
  }

  String documentToEmit(String code) {
    switch (code) {
      case "01":
        return "FACTURA";
        break;
      case "03":
        return "BOLETA";
        break;
      case "08":
        return "NOTA DE VENTA";
        break;
      default:
        return "-";
        break;
    }
  }
}
