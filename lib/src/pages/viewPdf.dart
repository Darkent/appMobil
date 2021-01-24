import 'dart:convert';

import 'package:delivery_app/src/models/client.dart';
import 'package:delivery_app/src/models/order.dart';
import 'package:delivery_app/src/models/purchase.dart';
import 'package:delivery_app/src/models/user.dart';
import 'package:delivery_app/src/providers/preferences.dart';
import 'package:delivery_app/src/services/documentPdf.dart';
import 'package:delivery_app/src/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:share/share.dart';

class PdfViewer extends StatefulWidget {
  final String externalId;
  final String date;
  final Order order;
  final Purchase purchase;
  final User user;
  final Client client;
  final String document;
  const PdfViewer(
      {this.user,
      this.order,
      this.purchase,
      this.externalId,
      Key key,
      this.client,
      this.date,
      this.document})
      : super(key: key);

  @override
  _PdfViewerState createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  // final urlPdf = "http://venta.grupopcsystems.online/downloads/document/pdf/";
  // final urlPdfNote = "http://venta.grupopcsystems.online/api/sale-note/print/";

  //http://venta.grupopcsystems.online/api/sale-note/print/5d99dd98-7f95-4714-8c84-b5ad96a080de/a4",

  //f2eb2749-2733-4475-8ca4-5b71b5dc2fa1/a4

  User user;
  PreferencesUser preferencesUser;
  Color colorPrimary;
  bool isSaleNote;
  String tmpUrl;
  String saleNoteUrl;
  String documentUrl;
  String typeDocuments;
  @override
  void initState() {
    super.initState();
    isSaleNote = false;
    typeDocuments = "documents";

    preferencesUser = PreferencesUser();
    colorPrimary = Colors.blue;
    tmpUrl = preferencesUser.tmpPdf;
    saleNoteUrl =
        "http://venta.grupopcsystems.online/api/sale-note/print/$tmpUrl/a4";
    documentUrl =
        "http://venta.grupopcsystems.online/downloads/document/pdf/$tmpUrl/a4";
    if (preferencesUser.userData.length != 1) {
      user = User.fromjson(json.decode(preferencesUser.userData));
      if (user.type == "admin") {
        colorPrimary = adminColor;
      } else if (user.type == "seller") {
        colorPrimary = sellerColor;
      }
    }

    if (widget.order != null) {
      if (widget.order.identifier == "N") {
        isSaleNote = true;
      }
    } else if (widget.purchase != null) {
      if (widget.purchase.numberDocument[0] == "N") {
        isSaleNote = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: colorPrimary,
          title: Text("VISOR"),
        ),
        body: widget.order != null
            ? FutureBuilder(
                future: urlPdf(widget.order.documents.first['document_id']),
                builder: (context, snapshot) {
                  print("entrando aca");
                  if (snapshot.hasData) {
                    if (snapshot.data.isNotEmpty) {
                      return Stack(
                        children: [
                          const PDF().cachedFromUrl(
                            "http://venta.grupopcsystems.online/downloads/document/pdf/${snapshot.data}/a4",
                            placeholder: (double progress) =>
                                Center(child: Text('$progress %')),
                            errorWidget: (dynamic error) =>
                                Center(child: Text(error.toString())),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: FloatingActionButton(
                                  backgroundColor: colorPrimary,
                                  child: Icon(
                                    Icons.share,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (widget.order != null) {
                                      String typeName =
                                          widget.order.number.length == 8
                                              ? "NOMBRE: "
                                              : "RAZON SOCIAL";

                                      String typeBillVoucher = _typeDocument(
                                          widget.order.documents
                                              .first['number_full']);
                                      Share.share(
                                          "$typeName: ${widget.order.customer.name} \ FECHA: ${formatDate(widget.order.date)} \ $typeBillVoucher: ${widget.order.documents.first['number_full']} \ Abre el enlace: ${snapshot.data}");
                                    } else {
                                      String typeName =
                                          widget.user.number.length == 8
                                              ? "NOMBRE: "
                                              : "RAZON SOCIAL";

                                      String typeBillVoucher = _typeDocument(
                                          widget.purchase.numberDocument);
                                      Share.share(
                                          "$typeName: ${widget.user.name} \ FECHA: ${formatDate(widget.purchase.date)} \ $typeBillVoucher: ${widget.purchase.numberDocument} \ Link de descarga: ${snapshot.data}");
                                    }
                                  }),
                            ),
                          )
                        ],
                      );
                    } else {
                      return Center(
                        child: Text("Ocurrió un Error"),
                      );
                    }
                  } else {
                    print(snapshot);
                    return Center(child: CircularProgressIndicator());
                  }
                },
              )
            : Stack(
                children: [
                  const PDF().cachedFromUrl(
                    widget.document != "01" && widget.document != "03"
                        ? saleNoteUrl
                        : documentUrl,
                    placeholder: (double progress) =>
                        Center(child: Text('$progress %')),
                    errorWidget: (dynamic error) =>
                        Center(child: Text(error.toString())),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                          backgroundColor: colorPrimary,
                          child: Icon(
                            Icons.share,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            String typeName = widget.client.number.length == 8
                                ? "NOMBRE: "
                                : "RAZON SOCIAL";

                            Share.share(
                                "$typeName: ${widget.client.name} \ FECHA: ${widget.date} \ Abre el enlace: http://venta.grupopcsystems.online/downloads/document/pdf/$tmpUrl/a4");
                          }),
                    ),
                  )
                ],
              ));
  }

  String formatDate(String date) {
    DateTime _date = DateTime.parse(date);

    return "${_format(_date.day)}/${_format(_date.month)}/${_format(_date.year)}";
  }

  String _format(int b) {
    String z = b.toString();

    return z.length == 1 ? "0" + z : z;
  }

  String _typeDocument(String document) {
    String initCharacter = document[0];
    switch (initCharacter) {
      case "F":
        return "FACTURA";
        break;
      case "B":
        return "BOLETA DE VENTA";
        break;
      default:
        return "NOTA DE VENTA";
        break;
    }
  }
}
