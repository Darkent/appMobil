import 'package:delivery_app/src/models/documents.dart';
import 'package:delivery_app/src/models/order.dart';

import 'package:delivery_app/src/pages/viewPdf.dart';
import 'package:delivery_app/src/providers/preferences.dart';

import 'package:delivery_app/src/services/documentService.dart';
import 'package:delivery_app/src/services/ordersService.dart';
import 'package:delivery_app/src/states/ordersState.dart';
import 'package:delivery_app/src/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

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

  List<Order> orders;
  List<Document> documents;
  TextEditingController queryController;
  OrdersService ordersService;
  PreferencesUser preferencesUser;
  OrdersState ordersState;
  Color colorPrimary;
  @override
  void initState() {
    super.initState();
    ordersState = OrdersState();
    queryController = TextEditingController();
    colorPrimary = adminColor;
    preferencesUser = PreferencesUser();

    width = widget.width;
    height = widget.height; // TODO: implement initState
    preferencesUser.newNotification = true;
    documentService = DocumentService();
    orders = [];
    ordersService = OrdersService();

    requestDocuments();
  }

  @override
  void dispose() {
    preferencesUser.newNotification = false;

    ordersState.dispose();
    super.dispose();
  }

  void requestDocuments() async {
    documents = await documentService.getDocuments();
    documents.sort(
        (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
    ordersState.inDocuments(documents);
  }

  _search() {
    List<Document> _document = List.from(documents);
    if (queryController.text.isNotEmpty) {
      String _query = queryController.text;
      var _number = int.tryParse(_query) ?? null;

      if (_number != null) {
        _document = _document.where((o) {
          if (o.customerDocument.number.contains(_query)) {
            return true;
          } else {
            return false;
          }
        }).toList();
      } else {
        _document = _document.where((o) {
          if (o.customerDocument.name
              .toUpperCase()
              .contains(_query.toUpperCase())) {
            return true;
          } else {
            return false;
          }
        }).toList();
      }
    }
    if (!ordersState.selectFValue) {
      _document.removeWhere((o) => o.number[0] == "F");
    }
    if (!ordersState.selectBValue) {
      _document.removeWhere((o) => o.number[0] == "B");
    }
    if (!ordersState.selectNValue) {
      _document.removeWhere((o) => o.number[0] == "N");
    }

    ordersState.inDocuments(_document);
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
                stream: ordersState.documents,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_late_rounded,
                              size: width * .08,
                              color: colorSecondary,
                            ),
                            Text("No se encontraron documentos.")
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

  Container orderShow(List<Document> list) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(list.length, (int idx) {
            Document e = list[idx];
            return Padding(
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
                                    e.customerDocument.name.toUpperCase(),
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
                                        e.customerDocument.number.length > 8
                                            ? "RUC: "
                                            : "DNI: ",
                                        style: TextStyle(
                                            fontSize: width * .04,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        e.customerDocument.number,
                                        style: TextStyle(fontSize: width * .04),
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Tipo de documento: ",
                                        style: TextStyle(
                                            fontSize: width * .035,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        e.number[0] == "F"
                                            ? "Factura"
                                            : e.number[0] == "B"
                                                ? "Boleta de venta"
                                                : "Nota de venta",
                                        style:
                                            TextStyle(fontSize: width * .035),
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Número de documento: ",
                                        style: TextStyle(
                                            fontSize: width * .035,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        e.number,
                                        style:
                                            TextStyle(fontSize: width * .035),
                                      ),
                                    ],
                                  )),
                              Padding(
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
                                        style:
                                            TextStyle(fontSize: width * .035),
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
                                      Row(
                                        children: [
                                          IconButton(
                                              icon: Icon(
                                                Icons.search,
                                                color: colorSecondary,
                                              ),
                                              onPressed: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PdfViewer(
                                                      documentD: e,
                                                      url: e.pdfUrl,
                                                    ),
                                                  ))),
                                          IconButton(
                                            icon: Icon(
                                              Icons.share,
                                              color: colorSecondary,
                                            ),
                                            onPressed: () {
                                              String typeName = e
                                                          .customerDocument
                                                          .number
                                                          .length ==
                                                      8
                                                  ? "NOMBRE: "
                                                  : "RAZON SOCIAL";

                                              Share.share(
                                                  "$typeName: ${e.customerDocument.name} \ FECHA: ${e.date} \ DOCUMENTO: ${e.number} \Abre el enlace: ${e.pdfUrl}");
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  )),
                            ],
                          ),
                        ),
                      ],
                    )),
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
