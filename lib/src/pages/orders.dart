import 'dart:async';

import 'package:delivery_app/main.dart';
import 'package:delivery_app/src/models/client.dart';
import 'package:delivery_app/src/models/order.dart';
import 'package:delivery_app/src/models/products.dart';
import 'package:delivery_app/src/models/series.dart';
import 'package:delivery_app/src/pages/viewPdf.dart';
import 'package:delivery_app/src/providers/preferences.dart';
import 'package:delivery_app/src/services/documentService.dart';
import 'package:delivery_app/src/services/ordersService.dart';
import 'package:delivery_app/src/states/ordersState.dart';
import 'package:delivery_app/src/utils/colors.dart';
import 'package:flutter/material.dart';

class OrdersPage extends StatefulWidget {
  final double width;
  final double height;
  OrdersPage({this.width, this.height, Key key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double width;
  double height;
  TextEditingController queryController;
  OrdersService ordersService;
  OrdersState ordersState;
  List<Order> orders;
  DocumentService documentService;
  StreamSubscription streamSubscription;
  List<Series> series;
  PreferencesUser preferencesUser;
  Color colorPrimary;
  bool emiting;
  @override
  void initState() {
    super.initState();
    emiting = false;
    queryController = TextEditingController();
    colorPrimary = adminColor;
    preferencesUser = PreferencesUser();
    streamSubscription = preferencesUser.receive.stream.listen((event) {
      requestOrders();
    });
    preferencesUser.newNotification = true;
    ordersState = OrdersState();
    documentService = DocumentService();
    orders = [];
    ordersService = OrdersService();
    series = preferencesUser.series
        .map<Series>((str) => Series.stringToSeries(str))
        .toList();
    width = widget.width;
    height = widget.height;
    requestOrders();
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

  Series _getSerie(String document) {
    switch (document) {
      case "01":
        return series.firstWhere((serie) => serie.documentTypeId == document);
        break;
      case "03":
        return series.firstWhere((serie) => serie.documentTypeId == document);
        break;
      case "08":
        return series.firstWhere((serie) => serie.documentTypeId == "80");
        break;
      default:
        return Series();
        break;
    }
  }

  _search() {
    List<Order> _order = List.from(orders);
    if (queryController.text.isNotEmpty) {
      String _query = queryController.text;
      var _number = int.tryParse(_query) ?? null;
      print(_number);
      if (_number != null) {
        _order = _order.where((o) {
          if (o.customer.number.contains(_query)) {
            return true;
          } else {
            return false;
          }
        }).toList();
      } else {
        _order = _order.where((o) {
          if (o.customer.name.toUpperCase().contains(_query.toUpperCase())) {
            return true;
          } else {
            return false;
          }
        }).toList();
      }
    }
    if (!ordersState.selectFValue) {
      _order.removeWhere((o) => o.document == "01");
    }
    if (!ordersState.selectBValue) {
      _order.removeWhere((o) => o.document == "03");
    }
    if (!ordersState.selectNValue) {
      _order.removeWhere((o) => o.document == "08");
    }
    print(_order.length);
    ordersState.inPending(_order);
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
            Text("Pendiente")
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Column(
              children: [
                Container(
                  color: colorPrimary,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextField(
                            controller: queryController,
                            decoration: InputDecoration(
                              hintText: "Buscar..",
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.fromLTRB(width * .02,
                                  width * .03, width * .02, width * .03),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: colorPrimary)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: colorPrimary)),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                            child: Icon(
                          Icons.search,
                          size: width * .1,
                        )),
                        onTap: _search,
                      )
                    ],
                  ),
                ),
                Container(
                  color: colorPrimary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Text("Factura"),
                          StreamBuilder<bool>(
                            initialData: true,
                            stream: ordersState.selectF,
                            builder: (context, AsyncSnapshot<bool> snapshot) {
                              return Checkbox(
                                activeColor: colorSecondary,
                                onChanged: (b) {
                                  ordersState.inSelectF(b);
                                },
                                value: snapshot.data,
                              );
                            },
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text("Boleta de V."),
                          StreamBuilder<bool>(
                            initialData: true,
                            stream: ordersState.selectB,
                            builder: (context, AsyncSnapshot<bool> snapshot) {
                              return Checkbox(
                                activeColor: colorSecondary,
                                onChanged: (b) {
                                  ordersState.inSelectB(b);
                                },
                                value: snapshot.data,
                              );
                            },
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text("Nota de V."),
                          StreamBuilder<bool>(
                            initialData: true,
                            stream: ordersState.selectN,
                            builder: (context, AsyncSnapshot<bool> snapshot) {
                              return Checkbox(
                                activeColor: colorSecondary,
                                onChanged: (b) {
                                  ordersState.inSelectN(b);
                                },
                                value: snapshot.data,
                              );
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            Expanded(
              child: StreamBuilder(
                stream: ordersState.pending,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart,
                              size: width * .08,
                              color: colorSecondary,
                            ),
                            Text("Aún no tiene pedidos.")
                          ],
                        ),
                      );
                    } else {
                      return orderShow(snapshot.data);
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container orderShow(List<Order> list) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: list
              .map<Widget>((e) => GestureDetector(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: width,
                                        decoration: BoxDecoration(
                                            color: colorSecondary),
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
                                                    color: Colors.black,
                                                    fontSize: width * .04,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                e.number,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: width * .04),
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
                                                    color: Colors.black,
                                                    fontSize: width * .035,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                formatDate(e.date),
                                                style: TextStyle(
                                                    color: Colors.black,
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
                                                        color: Colors.black,
                                                        fontSize: width * .035,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    formatDate(e.date),
                                                    style: TextStyle(
                                                        color: Colors.black,
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
                                                    "Documento a emitir: ",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: width * .035,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    documentToEmit(e.document),
                                                    style: TextStyle(
                                                        color: Colors.black,
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
                                                        color: Colors.black,
                                                        fontSize: width * .035,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    e.items.length.toString(),
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: width * .035),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "Total: ",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: width * .035,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    "S/. ${e.total}",
                                                    style: TextStyle(
                                                        color: colorSecondary,
                                                        fontSize: width * .035,
                                                        fontWeight:
                                                            FontWeight.bold),
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
                  ))
              .toList(),
        ),
      ),
    );
  }

  Future show(Order order) {
    List<Products> tmp = [];
    order.items.forEach((element) {
      tmp.add(element);
    });
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
                  backgroundColor: Colors.transparent,
                  insetPadding: EdgeInsets.all(height * .01),
                  elevation: 0,
                  child: Card(
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
                                                color: Colors.black,
                                                fontSize: width * .035,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            customer.number,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: width * .035),
                                          ),
                                        ]),
                                        TableRow(children: [
                                          Text(
                                            "Email",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: width * .035,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            customer.email,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: width * .035),
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
                                            style: TextStyle(
                                                fontSize: width * .035),
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
                                            style: TextStyle(
                                                fontSize: width * .035),
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
                                                  documentToEmit(
                                                      order.document),
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
                                                  order.document.toUpperCase(),
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
                                          StreamBuilder(
                                              stream: ordersState.currentList,
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return Text(
                                                    snapshot.data.length
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: width * .035),
                                                  );
                                                } else {
                                                  return SizedBox();
                                                }
                                              })
                                        ]),
                                        TableRow(children: [
                                          Text(
                                            "Precio total: ",
                                            style: TextStyle(
                                                fontSize: width * .035,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          StreamBuilder(
                                            stream: ordersState.currentList,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                List<Products> _products =
                                                    snapshot.data;
                                                var _total = _products.fold(
                                                    0,
                                                    (suma, next) =>
                                                        suma +
                                                        double.parse(
                                                            next.price));

                                                return Text(
                                                  _total.toString(),
                                                  style: TextStyle(
                                                      fontSize: width * .035),
                                                );
                                              } else {
                                                return SizedBox();
                                              }
                                            },
                                          )
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
                                      children:
                                          List.generate(tmp.length, (int idx) {
                                        Products e = tmp[idx];
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
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
                                                            style: TextStyle(
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
                                                order.documents.isEmpty
                                                    ? GestureDetector(
                                                        child: Icon(
                                                          Icons.delete,
                                                          color:
                                                              Colors.redAccent,
                                                        ),
                                                        onTap: () {
                                                          tmp.removeWhere(
                                                              (element) =>
                                                                  element.id ==
                                                                  e.id);

                                                          ordersState
                                                              .inCurrentList(
                                                                  tmp);
                                                        },
                                                      )
                                                    : SizedBox(),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                      scrollDirection: Axis.vertical,
                                    ),
                                  )),
                              Row(
                                mainAxisAlignment: order.documents.isEmpty
                                    ? MainAxisAlignment.spaceAround
                                    : MainAxisAlignment.end,
                                children: [
                                  order.documents.isEmpty
                                      ? Column(
                                          children: [
                                            Text("Fecha de Emision: "),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  child: StreamBuilder(
                                                    initialData: DateTime.now(),
                                                    stream: ordersState.date,
                                                    builder: (context, snap) =>
                                                        Text(formatDateToString(
                                                            snap.data)),
                                                  ),
                                                  onTap: () => selectDate(
                                                      ordersState.inDate),
                                                ),
                                                GestureDetector(
                                                  child: Icon(
                                                    Icons.date_range,
                                                    color: adminColor,
                                                  ),
                                                  onTap: () => selectDate(
                                                      ordersState.inDate),
                                                )
                                              ],
                                            ),
                                          ],
                                        )
                                      : SizedBox(),
                                  order.documents.isEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: RaisedButton(
                                            onPressed: () async {
                                              if (!emiting) {
                                                emiting = true;
                                                ordersState.inStateLoading("2");
                                                bool deleted =
                                                    originalSize == tmp.length
                                                        ? false
                                                        : true;

                                                Series serie =
                                                    _getSerie(order.document);

                                                if (serie.documentTypeId !=
                                                    "80") {
                                                  Map _tmp =
                                                      documentService.documentE(
                                                    date: ordersState.dateValue,
                                                    order: order,
                                                    items: tmp,
                                                    serie: serie,
                                                    type: serie.documentTypeId,
                                                  );

                                                  if (await documentService
                                                      .emitir(_tmp,
                                                          items: tmp,
                                                          id: order.id,
                                                          deletedI: deleted,
                                                          order: order)) {
                                                    ordersState
                                                        .inStateLoading("1");
                                                    emiting = false;
                                                    Navigator.pop(
                                                        context, false);
                                                  } else {
                                                    ordersState
                                                        .inStateLoading("1");
                                                    emiting = false;
                                                    Navigator.pop(context);
                                                  }
                                                } else {
                                                  Map _tmp =
                                                      documentService.saleNote(
                                                          order,
                                                          ordersState
                                                              .dateValue);

                                                  if (await documentService
                                                      .emitedNoteSale(
                                                          _tmp, order)) {
                                                    ordersState
                                                        .inStateLoading("1");
                                                    emiting = false;
                                                    Navigator.pop(
                                                        context, false);
                                                  } else {
                                                    ordersState
                                                        .inStateLoading("1");
                                                    emiting = false;
                                                    Navigator.pop(context);
                                                  }
                                                }
                                              }
                                            },
                                            child: StreamBuilder(
                                              stream: ordersState.stateLoading,
                                              initialData: "1",
                                              builder: (BuildContext context,
                                                  AsyncSnapshot snapshot) {
                                                if (snapshot.data == "1") {
                                                  return Text("Emitir");
                                                } else {
                                                  return Container(
                                                      child:
                                                          CircularProgressIndicator(
                                                    strokeWidth: 2.0,
                                                    backgroundColor:
                                                        Colors.white,
                                                  ));
                                                }
                                              },
                                            ),
                                            textColor: Colors.white,
                                            color: adminColor,
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: RaisedButton(
                                            onPressed: () async {
                                              Navigator.pop(context, true);
                                            },
                                            child: Text(
                                              "Ver Documento",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
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
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) => null);
  }

  void requestOrders() async {
    orders = await ordersService.getAllOrders();
    orders.removeWhere((o) => o.documents.isNotEmpty);

    ordersState.inPending(List.from(orders));
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

  @override
  void dispose() {
    preferencesUser.newNotification = false;
    streamSubscription.cancel();
    // preferencesUser.receive.
    ordersState.dispose();
    super.dispose();
  }
}
