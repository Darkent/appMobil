import 'dart:async';

import 'package:delivery_app/src/models/client.dart';
import 'package:delivery_app/src/models/order.dart';
import 'package:delivery_app/src/models/products.dart';
import 'package:delivery_app/src/pages/viewPdf.dart';
import 'package:delivery_app/src/providers/preferences.dart';
import 'package:delivery_app/src/services/documentPdf.dart';
import 'package:delivery_app/src/services/documentService.dart';
import 'package:delivery_app/src/services/ordersService.dart';
import 'package:delivery_app/src/states/ordersState.dart';
import 'package:delivery_app/src/utils/colors.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class DocumentsPage extends StatefulWidget {
  final double width;
  final double height;
  DocumentsPage({Key key, this.width, this.height}) : super(key: key);

  @override
  _DocumentsPageState createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double width;
  double height;
  DocumentService documentService;
  StreamSubscription streamSubscription;
  List<Order> orders;
  OrdersService ordersService;
  PreferencesUser preferencesUser;
  OrdersState ordersState;
  Color colorPrimary;
  @override
  void initState() {
    super.initState();
    ordersState = OrdersState();
    colorPrimary = adminColor;
    preferencesUser = PreferencesUser();
    streamSubscription = preferencesUser.receive.stream.listen((event) {
      requestOrders();
    });
    width = widget.width;
    height = widget.height; // TODO: implement initState
    preferencesUser.newNotification = true;
    documentService = DocumentService();
    orders = [];
    ordersService = OrdersService();
    requestOrders();
  }

  @override
  void dispose() {
    preferencesUser.newNotification = false;
    streamSubscription.cancel();
    // preferencesUser.receive.
    ordersState.dispose();
    super.dispose();
  }

  void requestOrders() async {
    orders = await ordersService.getAllOrders();

    List<Order> _pending = [];
    List<Order> _delivered = [];

    orders.forEach((Order order) {
      if (order.documents.isEmpty) {
        _pending.add(order);
      } else {
        _delivered.add(order);
      }
    });

    ordersState.inDelivered(_delivered);
    ordersState.inPending(_pending);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrimary,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: width * .05),
              child: Icon(Icons.description),
            ),
            Text("Entregado")
          ],
        ),
      ),
      body: Center(
        child: StreamBuilder(
          stream: ordersState.delivered,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return orderShow(snapshot.data);
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Container orderShow(List<Order> list) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(list.length, (int idx) {
            Order e = list[idx];
            return GestureDetector(
              onTap: () async {
                await show(e).then((value) {
                  if (value != null) {
                    if (value) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PdfViewer(
                                    order: e,
                                    externalId: e.externalId,
                                  )));
                    } else {
                      message("Documento emitido");
                      requestOrders();
                    }
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: width * .9,
                  child: Card(
                      margin: EdgeInsets.zero,
                      child: Row(
                        children: [
                          Container(
                            width: width * .9,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: width,
                                  decoration:
                                      BoxDecoration(color: colorSecondary),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      e.customer.name,
                                      maxLines: 1,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: width * .045,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          e.number.length > 8
                                              ? "RUC: "
                                              : "DNI: ",
                                          style: TextStyle(
                                              fontSize: width * .04,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          e.number,
                                          style:
                                              TextStyle(fontSize: width * .04),
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Fecha Pedido: ",
                                          style: TextStyle(
                                              fontSize: width * .035,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          formatDate(e.date),
                                          style:
                                              TextStyle(fontSize: width * .035),
                                        ),
                                      ],
                                    )),
                                e.documents.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              "Fecha Emisión: ",
                                              style: TextStyle(
                                                  fontSize: width * .035,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              formatDate(e.date),
                                              style: TextStyle(
                                                  fontSize: width * .035),
                                            ),
                                          ],
                                        ))
                                    : Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              "Documento a emitir: ",
                                              style: TextStyle(
                                                  fontSize: width * .035,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              documentToEmit(e.documentNumber),
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
                                                  fontWeight: FontWeight.bold),
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
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "S/. ${e.total}",
                                              style: TextStyle(
                                                  color: colorSecondary,
                                                  fontSize: width * .035,
                                                  fontWeight: FontWeight.bold),
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
                      )),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  String formatDateToString(DateTime _date) {
    return "${_format(_date.day)}/${_format(_date.month)}/${_format(_date.year)}";
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

  Future show(Order order) async {
    List<Products> tmp = [];
    order.items.forEach((element) {
      tmp.add(element);
    });
    print(order.id);

    int originalSize = tmp.length;
    ordersState.inCurrentList(tmp);
    Client customer = order.customer;
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
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              height: height * .005,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                customer.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: width * .045),
                              ),
                            ),
                            Container(
                              width: width,
                              child: Column(
                                children: [
                                  Table(
                                    children: [
                                      TableRow(children: [
                                        Text(
                                          customer.number.length > 8
                                              ? "RUC: "
                                              : "DNI: ",
                                          style: TextStyle(
                                              fontSize: width * .035,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          customer.number,
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
                                          customer.email,
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
                                          customer.address,
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
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                order.document.toUpperCase(),
                                                style: TextStyle(
                                                    fontSize: width * .035),
                                              ),
                                            ])
                                          : TableRow(children: [
                                              Text(
                                                "N° de Documento: ",
                                                style: TextStyle(
                                                    fontSize: width * .035,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                order.documents
                                                    .first['number_full'],
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
                                          order.total,
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
                                child: StreamBuilder(
                                  stream: ordersState.currentList,
                                  builder: (context, snapshot) => ListView(
                                    children: tmp
                                        .map<Widget>((e) => Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Card(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: width * .75,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            e.description,
                                                            maxLines: 2,
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text(
                                                            "S/.${(double.parse(e.subtotal) * 1.18).toStringAsFixed(2)}",
                                                            maxLines: 1,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                "Cant.: ",
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              Text(
                                                                e.quantity
                                                                    .toString(),
                                                                maxLines: 1,
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    scrollDirection: Axis.vertical,
                                  ),
                                )),
                            Row(
                              mainAxisAlignment: order.documents.isEmpty
                                  ? MainAxisAlignment.spaceAround
                                  : MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RaisedButton(
                                    onPressed: () async {
                                      Navigator.pop(context, true);
                                    },
                                    child: Text("Ver Documento",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    textColor: Colors.white,
                                    color: adminColor,
                                  ),
                                ),
                                RaisedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Cerrar",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  color: colorSecondary,
                                  textColor: Colors.white,
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
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) => null);
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

  void message(String _message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 2),
        backgroundColor: adminColor,
        behavior: SnackBarBehavior.floating,
        content: Text(
          _message,
          textAlign: TextAlign.justify,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        )));
  }
}
