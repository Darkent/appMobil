import 'dart:convert';

import 'package:delivery_app/main.dart';
import 'package:delivery_app/src/models/client.dart';
import 'package:delivery_app/src/models/order.dart';
import 'package:delivery_app/src/models/products.dart';
import 'package:delivery_app/src/models/series.dart';
import 'package:delivery_app/src/models/user.dart';
import 'package:delivery_app/src/pages/searchClient.dart';
import 'package:delivery_app/src/pages/viewPdf.dart';
import 'package:delivery_app/src/providers/preferences.dart';
import 'package:delivery_app/src/services/clientService.dart';
import 'package:delivery_app/src/services/documentService.dart';
import 'package:delivery_app/src/services/shopCarService.dart';
import 'package:delivery_app/src/states/paymentState.dart';
import 'package:delivery_app/src/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class PaymentPage extends StatefulWidget {
  final double width;
  final double height;
  final double subtotal;
  final DateTime date;
  final String externalId;

  PaymentPage(
      {this.width,
      this.height,
      this.subtotal,
      this.date,
      this.externalId,
      Key key})
      : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // List<String> _documents;
  int idCustomer;
  double width;
  double height;
  double subtotal;
  String externalId;
  DateTime date;
  ShopCarService shopCarService;
  PaymentState paymentState;
  PreferencesUser preferencesUser;
  DocumentService documentService;
  User user;
  Client client;
  Color colorPrimary;
  List<Products> restoreProducts;
  bool test;
  List<Series> series;
  @override
  void initState() {
    super.initState();
    test = false;
    idCustomer = 0;
    documentService = DocumentService();
    paymentState = PaymentState();
    // _documents = ["FACTURA", "BOLETA DE VENTA", "NOTA DE VENTA"];

    preferencesUser = PreferencesUser();
    user = User.fromjson(json.decode(preferencesUser.userData));
    series = preferencesUser.series
        .map<Series>((str) => Series.stringToSeries(str))
        .toList();
    if (user.type == "client" && user.number.length == 8) {
      colorPrimary = visitColor;
    } else if (user.type == "admin") {
      colorPrimary = adminColor;
    } else {
      colorPrimary = sellerColor;
    }

    shopCarService = ShopCarService();
    // paymentState.inDocument(_documents[0]);
    subtotal = widget.subtotal;
    width = widget.width;
    height = widget.height;
    restoreProducts = json
        .decode(preferencesUser.productsCar)
        .map<Products>((e) => Products.fromJsonQuantity(e))
        .toList();
    if (user.type == "client") {
      client = Client.fromUser(user);
      paymentState.inClient(client);
    }
    if (user.type != "admin") {
      getIdCustomer();
    }
  }

  getIdCustomer() async {
    idCustomer = await ClientService().idCustomerFromClient(client.number);
  }

  Series _getSerie(String document) {
    switch (document) {
      case "FACTURA":
        return series.firstWhere((serie) => serie.documentTypeId == "01");
        break;
      case "BOLETA DE VENTA":
        return series.firstWhere((serie) => serie.documentTypeId == "03");
        break;
      case "NOTA DE VENTA":
        return series.firstWhere((serie) => serie.documentTypeId == "80");
        break;
      default:
        return Series();
        break;
    }
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
      appBar: AppBar(
        backgroundColor: colorPrimary,
        elevation: 0,
        centerTitle: true,
        title: Text("Realizar Pedido"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: height * .015,
            ),
            Container(
              child: RaisedButton.icon(
                icon: Icon(MaterialCommunityIcons.search_web),
                label: Text("Seleccione el Cliente para enviar pedido"),
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(width * .015)),
                elevation: 0,
                color: colorSecondary,
                textColor: Colors.white,
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchClient(
                          height: height,
                          width: width,
                        ),
                      )).then((client) {
                    if (client != null) {
                      Client _tmp = client;
                      print(_tmp.number);
                      if (_tmp.number.length == 8) {
                        paymentState.inDocument("NOTA DE VENTA");
                      } else {
                        paymentState.inDocument("FACTURA");
                      }
                      paymentState.inClient(client);
                    }
                  });
                },
              ),
            ),
            StreamBuilder<Client>(
              stream: paymentState.client,
              builder: (context, AsyncSnapshot<Client> snapshote) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    snapshote.data != null
                        ? Row(
                            mainAxisAlignment: user.type == "admin"
                                ? MainAxisAlignment.spaceAround
                                : MainAxisAlignment.center,
                            children: [
                              StreamBuilder(
                                initialData: "NOTA DE VENTA",
                                stream: paymentState.document,
                                builder: (context, snapshot) {
                                  print(snapshot.data);
                                  List<String> initRuc = [
                                    "FACTURA",
                                    "BOLETA DE VENTA",
                                    "NOTA DE VENTA"
                                  ];
                                  List<String> initDni = [
                                    "NOTA DE VENTA",
                                    "FACTURA",
                                    "BOLETA DE VENTA"
                                  ];
                                  return DropdownButton(
                                      value: snapshot.data,
                                      items: (snapshote.data.number.length == 8
                                              ? initDni
                                              : initRuc)
                                          .map<DropdownMenuItem>(
                                              (e) => DropdownMenuItem(
                                                    child: Text(e),
                                                    value: e,
                                                  ))
                                          .toList(),
                                      onChanged: (v) =>
                                          paymentState.inDocument(v));
                                },
                              ),
                              user.type == "admin"
                                  ? StreamBuilder(
                                      initialData: DateTime.now(),
                                      stream: paymentState.date,
                                      builder: (context, snapshot) {
                                        return GestureDetector(
                                          onTap: () =>
                                              selectDate(paymentState.inDate),
                                          child: Container(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  color: colorPrimary,
                                                ),
                                                Text(
                                                  formatDateToString(
                                                      snapshot.data),
                                                  style: TextStyle(
                                                      fontSize: width * .045),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : SizedBox()
                            ],
                          )
                        : SizedBox(),
                    Container(
                      child: RaisedButton.icon(
                        icon: Icon(MaterialCommunityIcons.bag_carry_on_check),
                        label: Text(user.type == "admin"
                            ? "Emitir Comprobante"
                            : "Confirmar Pedido"),
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: colorPrimary),
                            borderRadius:
                                new BorderRadius.circular(width * .015)),
                        elevation: 0,
                        color: colorPrimary,
                        textColor: Colors.white,
                        onPressed: () async {
                          if (paymentState.clientValue != null) {
                            if (paymentState.documentValue != "FACTURA" ||
                                paymentState.clientValue.number.length != 8) {
                              if (user.type == "admin") {
                                sendOrder(isAdmin: true).then((value) async {
                                  print(value);
                                  if (test) {
                                    print("borrando carrito");
                                    await preferencesUser.deleteCar();

                                    Future.delayed(Duration(milliseconds: 100),
                                        () {
                                      if (value == null) {
                                        Navigator.pop(context, true);
                                      } else {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => PdfViewer(
                                                    document: value,
                                                    client: paymentState
                                                        .clientValue,
                                                    date: formatDateToString(
                                                      paymentState.dateValue,
                                                    ))),
                                            result: true);
                                      }
                                    });
                                  } else {}
                                });
                              } else {
                                sendOrder(isAdmin: false).then((value) async {
                                  print(value);
                                  if (test) {
                                    await preferencesUser.deleteCar();

                                    Future.delayed(Duration(milliseconds: 100),
                                        () {
                                      Navigator.pop(context, true);
                                    });
                                  } else {}
                                });
                              }
                            } else {
                              errorMessage();
                            }
                          } else {
                            message("Se necesitan los datos del cliente");
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(
              height: height * .035,
            ),
            StreamBuilder(
                stream: paymentState.client,
                builder: (context, AsyncSnapshot<Client> snapshot) {
                  Client temporal = snapshot.data;
                  if (!snapshot.hasData) {
                    return SizedBox();
                  } else {
                    return Center(
                      child: Container(
                        width: width * .9,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "DATOS DEL CLIENTE",
                                      style: TextStyle(
                                          color: Colors.black.withOpacity(.4),
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      width: width * .8,
                                      child: Table(
                                        columnWidths: {
                                          0: FractionColumnWidth(.3),
                                          1: FractionColumnWidth(.7)
                                        },
                                        children: [
                                          TableRow(children: [
                                            Text(
                                              "NOMBRE",
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(.4),
                                                  fontSize: width * .04,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              temporal.name,
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(.4),
                                                  fontSize: width * .04,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ]),
                                          TableRow(children: [
                                            Text(
                                              temporal.identityDocumentTypeId ==
                                                      "1"
                                                  ? "DNI"
                                                  : "RUC",
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(.4),
                                                  fontSize: width * .04,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              temporal.number ?? "-",
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(.4),
                                                  fontSize: width * .04,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ]),
                                          TableRow(children: [
                                            Text(
                                              "DIRECCION",
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(.4),
                                                  fontSize: width * .04,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              temporal.address ?? "-",
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(.4),
                                                  fontSize: width * .04,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ]),
                                          TableRow(children: [
                                            Text(
                                              "CELULAR",
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(.4),
                                                  fontSize: width * .04,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              temporal.telephone ?? "-",
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(.4),
                                                  fontSize: width * .04,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ]),
                                        ],
                                      ),
                                    ),
                                    Divider(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                }),
            SizedBox(
              height: height * .05,
            ),
            Center(
              child: Container(
                width: width * .9,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Text(
                          "Resumen",
                          style: TextStyle(
                              fontSize: width * .05,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: height * 0.05,
                        ),
                        Column(
                          children: [
                            Container(
                              width: width * .8,
                              child: Table(
                                columnWidths: {
                                  0: FractionColumnWidth(.7),
                                  1: FractionColumnWidth(.3)
                                },
                                children: [
                                  TableRow(children: [
                                    Text(
                                      "Subtotal (${restoreProducts.length}  items)",
                                      style: TextStyle(
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "S/.${format.format((subtotal / 1.18))}",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ]),
                                  TableRow(children: [
                                    Text(
                                      "Descuento",
                                      style: TextStyle(
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "S/. 0.00",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ]),
                                ],
                              ),
                            ),
                            Divider(),
                            Container(
                              width: width * .8,
                              child: Table(
                                columnWidths: {
                                  0: FractionColumnWidth(.7),
                                  1: FractionColumnWidth(.3)
                                },
                                children: [
                                  TableRow(children: [
                                    Text(
                                      "Delivery",
                                      style: TextStyle(
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "S/. 0.00",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ]),
                                  TableRow(children: [
                                    Text(
                                      "IGV",
                                      style: TextStyle(
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "S/.${(format.format((subtotal / 1.18) * 0.18))} ",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ]),
                                  TableRow(children: [
                                    Text(
                                      "Impuesto por empaque",
                                      style: TextStyle(
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "S/. 0.00",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: width * .9,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Container(
                              width: width * .8,
                              child: Table(
                                columnWidths: {
                                  0: FractionColumnWidth(.7),
                                  1: FractionColumnWidth(.3)
                                },
                                children: [
                                  TableRow(children: [
                                    Text(
                                      "TOTAL",
                                      style: TextStyle(
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "S/.${format.format(subtotal)} ",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ]),
                                ],
                              ),
                            ),
                            Divider(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> sendOrder({bool isAdmin}) {
    Series _series = _getSerie(paymentState.documentValue);
    Future<bool> future;
    if (isAdmin) {
      if (_series.documentTypeId != "80") {
        Map body = documentService.documentEmited(
            products: restoreProducts,
            client: paymentState.clientValue,
            date: paymentState.dateValue,
            series: _series.number,
            type: _series.documentTypeId,
            total: subtotal);

        future = documentService.emitirDocumentoDirectamente(body);
      } else {
        Order order = Order(
            customer: paymentState.clientValue,
            subtotal: subtotal.toStringAsFixed(2),
            items: restoreProducts);

        Map _tmp = documentService.saleNote(order, paymentState.dateValue);
        debugPrint(_tmp.toString(), wrapWidth: 1024);

        future = documentService.emitedNoteSale(_tmp, order);
      }
    } else {
      Client client = paymentState.clientValue;

      if (user.number == paymentState.clientValue.number) {
        client.id = idCustomer;
      }
      future = shopCarService.sendProducts(restoreProducts, subtotal, client,
          paymentState.documentValue, paymentState.dateValue, externalId);
    }

    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "PROCESANDO",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  FutureBuilder(
                    future: future,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      } else {
                        if (snapshot.data) {
                          test = true;
                          return Column(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  color: colorSecondary, size: width * .15),
                              Text(
                                  isAdmin
                                      ? "DOCUMENTO EMITIDO CON EXITO"
                                      : "Pedido realizado con exito!"
                                          .toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Column(
                                children: [
                                  isAdmin
                                      ? RaisedButton(
                                          color: colorPrimary,
                                          textColor: Colors.white,
                                          child: Text("VER DOCUMENTO"),
                                          onPressed: () {
                                            print(preferencesUser.tmpPdf);

                                            Navigator.pop(context,
                                                _series.documentTypeId);
                                          },
                                        )
                                      : SizedBox(),
                                  RaisedButton(
                                    color: colorPrimary,
                                    textColor: Colors.white,
                                    child: Text("CERRAR"),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              )
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              Icon(Icons.error,
                                  color: Colors.redAccent, size: width * .15),
                              Text("Hubo un problema. No se realizo el pedido."
                                  .toUpperCase()),
                            ],
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ));
  }

  Future<void> selectDate(Function(DateTime) sink) async {
    final DateTime picked = await showDatePicker(
      helpText: "Elija la fecha",
      context: context,
      locale: Locale('es'),
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: colorPrimary,
            accentColor: colorPrimary,
            colorScheme: ColorScheme.light(primary: colorPrimary),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child,
        );
      },
    );
    if (picked != null) {
      sink(picked);
    }
  }

  Future errorMessage() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error,
                    color: Colors.red,
                    size: width * .15,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Las facturas solo pueden ser emitidas a empresas."
                          .toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  RaisedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("CERRAR"),
                    color: colorPrimary,
                    textColor: Colors.white,
                  )
                ],
              ),
            ));
  }

  String formatDateToString(DateTime _date) {
    return "${_format(_date.day)}/${_format(_date.month)}/${_format(_date.year)}";
  }

  String _format(int b) {
    String z = b.toString();

    return z.length == 1 ? "0" + z : z;
  }

  @override
  void dispose() {
    paymentState.dispose();
    super.dispose();
  }
}
