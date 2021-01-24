import 'dart:async';
import 'dart:convert';

import 'package:delivery_app/main.dart';
import 'package:delivery_app/src/models/client.dart';
import 'package:delivery_app/src/models/user.dart';
import 'package:delivery_app/src/pages/profile.dart';

import 'package:delivery_app/src/providers/preferences.dart';
import 'package:delivery_app/src/services/clientService.dart';
import 'package:delivery_app/src/services/registerService.dart';
import 'package:delivery_app/src/states/searchClientState.dart';
import 'package:delivery_app/src/utils/colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class SearchClient extends StatefulWidget {
  final double width;
  final double height;
  SearchClient({this.width, this.height, Key key}) : super(key: key);

  @override
  _SearchClientState createState() => _SearchClientState();
}

class _SearchClientState extends State<SearchClient> {
  double width;
  double height;
  TextEditingController queryController;
  SearchClientState searchClientState;
  ClientService clientService;
  PreferencesUser preferencesUser;
  RegisterService registerService;
  User user;
  Color colorPrimary;
  @override
  void initState() {
    super.initState();
    registerService = RegisterService();
    preferencesUser = PreferencesUser();
    queryController = TextEditingController();
    searchClientState = SearchClientState();
    clientService = ClientService();
    width = widget.width;
    height = widget.height;
    colorPrimary = visitColor;
    preferencesUser = PreferencesUser();
    if (preferencesUser.userData.length != 1) {
      user = User.fromjson(json.decode(preferencesUser.userData));
      if (user.type == "admin") {
        colorPrimary = adminColor;
      } else if (user.type == "seller") {
        colorPrimary = sellerColor;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrimary,
        elevation: 0,
        title: Text("BUSQUEDA DE CLIENTE"),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.clear), onPressed: () => Navigator.pop(context)),
      ),
      body: Container(
        child: Column(
          children: [
            StreamBuilder(
              stream: searchClientState.typeFieldSearch,
              initialData: "DOCUMENT",
              builder: (context, snapshot) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Text("DNI/RUC"),
                      Radio(
                          activeColor: colorPrimary,
                          value: "DOCUMENT",
                          groupValue: snapshot.data,
                          onChanged: (v) {
                            searchClientState.inTypeFieldSearch(v);
                          })
                    ],
                  ),
                  Row(
                    children: [
                      Text("Nombre/R. social"),
                      Radio(
                          activeColor: colorPrimary,
                          value: "NAME",
                          groupValue: snapshot.data,
                          onChanged: (v) {
                            searchClientState.inTypeFieldSearch(v);
                          })
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: width * .7,
                  child: TextField(
                    controller: queryController,
                    decoration: InputDecoration(
                      hintText: "Buscar..",
                      isDense: true,
                      contentPadding: EdgeInsets.fromLTRB(
                          width * .02, width * .03, width * .02, width * .03),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: colorPrimary)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorPrimary)),
                    ),
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () async {
                      if (queryController.text.isNotEmpty) {
                        searchClientState.inSearchType("2");
                        List<Client> results = await clientService.search(
                            searchClientState.typeFieldSearchValue,
                            queryController.text);
                        searchClientState.inListResults(results);
                      }
                    })
              ],
            ),
            Expanded(
                child: StreamBuilder(
                    stream: searchClientState.listResults,
                    builder: (context, AsyncSnapshot<List> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.isEmpty) {
                          searchOut(
                              queryController.text.length == 8 ? true : false,
                              queryController.text);
                          return Center(
                            child: StreamBuilder(
                              stream: searchClientState.newClient,
                              builder:
                                  (context, AsyncSnapshot<Client> cliente) {
                                if (cliente.hasData) {
                                  if (cliente.data?.name == null) {
                                    return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle),
                                            child: Icon(
                                              Icons.report_problem,
                                              size: width * .1,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                child: Text(
                                                  "ERROR NUMERO DE DOCUMENTO INVALIDO",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ))
                                        ]);
                                  } else {
                                    Map body = data(false,
                                        name: cliente.data.name,
                                        number: cliente.data.number,
                                        address: cliente.data.address);
                                    registerService.register(body).then((v) {
                                      Client _tmp = cliente.data;
                                      _tmp.id = v['id'];
                                      Future.delayed(
                                          Duration(milliseconds: 150), () {
                                        Navigator.pop(context, _tmp);
                                      });
                                    });

                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                        Text(
                                          "GUARDANDO AL CLIENTE NUEVO",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    );
                                  }
                                } else {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                      Text(
                                        "CLIENTE NUEVO - BUSCANDO",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  );
                                }
                              },
                            ),
                          );
                        } else {
                          return ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                List<Client> temporal = snapshot.data;
                                return ExpansionTile(
                                  title:
                                      Text(temporal[index].name.toUpperCase()),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15.0, 2, 8, 2),
                                      child: Table(
                                        columnWidths: {
                                          0: FractionColumnWidth(.3),
                                          1: FractionColumnWidth(.7)
                                        },
                                        children: [
                                          TableRow(children: [
                                            Text(
                                              temporal[index]
                                                          .identityDocumentTypeId ==
                                                      "1"
                                                  ? "DNI"
                                                  : "RUC",
                                              style: TextStyle(
                                                  color: colorPrimary),
                                            ),
                                            Text(
                                              temporal[index].number,
                                              style: TextStyle(
                                                  color: colorPrimary),
                                            )
                                          ]),
                                          TableRow(children: [
                                            Text(
                                              "DIRECCION",
                                              style: TextStyle(
                                                  color: colorPrimary),
                                            ),
                                            Text(
                                              temporal[index].address ?? "-",
                                              style: TextStyle(
                                                  color: colorPrimary),
                                            )
                                          ]),
                                          TableRow(children: [
                                            Text(
                                              "TELEFONO",
                                              style: TextStyle(
                                                  color: colorPrimary),
                                            ),
                                            Text(
                                              temporal[index].telephone ?? "-",
                                              style: TextStyle(
                                                  color: colorPrimary),
                                            )
                                          ]),
                                          TableRow(children: [
                                            Text(
                                              "CORREO",
                                              style: TextStyle(
                                                  color: colorPrimary),
                                            ),
                                            Text(
                                              temporal[index].email ?? "-",
                                              style: TextStyle(
                                                  color: colorPrimary),
                                            )
                                          ]),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          FloatingActionButton(
                                            backgroundColor: colorPrimary,
                                            elevation: 0,
                                            mini: true,
                                            child: Icon(
                                              Icons.group_add,
                                              color: Colors.white,
                                            ),
                                            onPressed: () => Navigator.pop(
                                                context, temporal[index]),
                                            heroTag:
                                                "${temporal[index].number}_",
                                          ),
                                          FloatingActionButton(
                                            backgroundColor: colorPrimary,
                                            elevation: 0,
                                            mini: true,
                                            child: Icon(
                                              Feather.edit_3,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfilePage(
                                                      client: temporal[index],
                                                      height: height,
                                                      width: width,
                                                    ),
                                                  )).then((value) {
                                                if (value is Client) {
                                                  searchClientState
                                                      .inListResults([value]);
                                                }
                                              });
                                            },
                                            heroTag: temporal[index].number,
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                );
                              });
                        }
                      } else {
                        StreamBuilder(
                          initialData: "1",
                          stream: searchClientState.searchType,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data == "1") {
                                return Center(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: colorSecondary,
                                          shape: BoxShape.circle),
                                      child: Icon(
                                        Icons.person_search,
                                        size: width * .1,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "BUSQUE Y AGREGUE UN CLIENTE",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ));
                              } else {
                                return Column(
                                  children: [
                                    Center(child: CircularProgressIndicator())
                                  ],
                                );
                              }
                            } else {
                              return Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: colorSecondary,
                                        shape: BoxShape.circle),
                                    child: Icon(
                                      Icons.person_search,
                                      size: width * .1,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "BUSQUE Y AGREGUE UN CLIENTE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ));
                            }
                          },
                        );
                        return Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: colorSecondary,
                                  shape: BoxShape.circle),
                              child: Icon(
                                Icons.person_search,
                                size: width * .1,
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "BUSQUE Y AGREGUE UN CLIENTE",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ));
                      }
                    }))
          ],
        ),
      ),
    );
  }

  Map data(bool ruc,
      {String address = "-",
      String email = "",
      String name,
      String telephone = "-",
      String number,
      int id}) {
    Map _data = {
      "customer_id": id,
      "country_id": "PE",
      "type": "customers",
      "enableb": 1,
      "status": 1
    };
    _data.putIfAbsent("address", () => address);
    _data.putIfAbsent("email", () => email);
    _data.putIfAbsent("name", () => name);
    _data.putIfAbsent("telephone", () => telephone);
    _data.putIfAbsent("identity_document_type_id", () => ruc ? "6" : "1");
    _data.putIfAbsent("number", () => ruc ? number : number);

    return _data;
  }

  void searchOut(bool typeDocument, String document) async {
    Client _newClient = await clientService.getData(typeDocument, document);

    searchClientState.inNewClient(_newClient);
  }

  @override
  void dispose() {
    searchClientState.dispose();
    super.dispose();
  }
}
