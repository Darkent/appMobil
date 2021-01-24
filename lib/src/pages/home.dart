import 'dart:convert';

import 'package:audioplayers/audio_cache.dart';
import 'package:delivery_app/main.dart';
import 'package:delivery_app/src/models/series.dart';
import 'package:delivery_app/src/models/user.dart';
import 'package:delivery_app/src/pages/documents.dart';
import 'package:delivery_app/src/pages/orders.dart';
import 'package:delivery_app/src/pages/profile.dart';
import 'package:delivery_app/src/pages/purchases.dart';
import 'package:delivery_app/src/pages/shop_car.dart';
import 'package:delivery_app/src/pages/store.dart';
import 'package:delivery_app/src/providers/preferences.dart';
import 'package:delivery_app/src/services/documentService.dart';
import 'package:delivery_app/src/services/registerService.dart';
import 'package:delivery_app/src/states/homeState.dart';
import 'package:delivery_app/src/utils/colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:badges/badges.dart';

class HomePage extends StatefulWidget {
  final double width;
  final double height;
  final String pwd;
  HomePage({this.pwd, this.width, this.height, Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PreferencesUser preferencesUser;
  FirebaseMessaging _firebaseMessaging;
  List<Widget> _pages;
  RegisterService registerService;
  User user;
  HomeState _homeState;
  Color colorPrimary;
  bool onPage;
  double width;
  double height;
  DocumentService _documentService;
  AudioCache audioCache;
  @override
  void initState() {
    super.initState();
    _documentService = DocumentService();
    audioCache = AudioCache();
    onPage = false;
    width = widget.width;
    height = widget.height;
    registerService = RegisterService();
    colorPrimary = Colors.blue;

    preferencesUser = PreferencesUser();
    if (preferencesUser.userData.length != 1) {
      series();
      if (preferencesUser.notification != 0) {
        _homeState.addNotification(preferencesUser.notification);
      }

      _firebaseMessaging = FirebaseMessaging();

      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          if (!onPage) {
            int tmp = _homeState.notificationValue;
            _homeState.addNotification(++tmp);
          }
          if (!preferencesUser.newNotification) {
            errorMessage();
            preferencesUser.newNotification = true;
          } else {
            preferencesUser.receive.add(0);
          }

          await audioCache.play("sounds/notification.mp3");
        },
        onLaunch: (Map<String, dynamic> message) async {
          _homeState.enterPage(2);
          _homeState.addNotification(0);
        },
        onResume: (Map<String, dynamic> message) async {
          _homeState.enterPage(2);
          _homeState.addNotification(0);
        },
      );

      user = User.fromjson(json.decode(preferencesUser.userData));

      if (user.type != "admin") {
        _firebaseMessaging.subscribeToTopic(user.number);
      } else {
        _firebaseMessaging.subscribeToTopic("newOrder");
      }
    }

    _homeState = HomeState();
    _pages = [
      StorePage(
        height: widget.height,
        width: widget.width,
      ),
      ShopCarPage(
        height: widget.height,
        width: widget.width,
      ),
      PurchasesPage(
        height: widget.height,
        width: widget.width,
      ),
      OrdersPage(
        height: widget.height,
        width: widget.width,
      ),
      DocumentsPage(
        height: widget.height,
        width: widget.width,
      ),
      ProfilePage(
        height: widget.height,
        width: widget.width,
      )
    ];
    if (user != null) {
      if (user.type != "admin" && user.type != "client") {
        colorPrimary = sellerColor;
        _pages.removeWhere((element) => element is OrdersPage);
        _pages.removeWhere((element) => element is PurchasesPage);
        _pages.removeWhere((element) => element is DocumentsPage);
      } else if (user.type == "admin") {
        colorPrimary = adminColor;
        colorSecondary = visitColor;
        _pages.removeWhere((element) => element is PurchasesPage);
      } else {
        colorPrimary = visitColor;
        colorSecondary = adminColor;
        _pages.removeWhere((element) => element is OrdersPage);
        _pages.removeWhere((element) => element is DocumentsPage);
      }
    } else {
      colorPrimary = visitColor;
      colorSecondary = adminColor;
      _pages.removeWhere((element) => element is OrdersPage);
      _pages.removeWhere((element) => element is PurchasesPage);
      _pages.removeWhere((element) => element is DocumentsPage);
    }
  }

  void series() async {
    List<Series> _series = await _documentService.getSeries();

    List _aString = _series.map((serie) => serie.seriesToString()).toList();

    preferencesUser.series = _aString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(227, 233, 237, .5),
      bottomNavigationBar: StreamBuilder(
        initialData: 0,
        stream: _homeState.page,
        builder: (context, snapshot) {
          return BottomNavigationBar(
              onTap: (v) {
                if (user != null) {
                  if ((user.type == "admin" || user.type == "client") &&
                      v == 2) {
                    onPage = true;
                    _homeState.addNotification(0);
                    _homeState.enterPage(v);
                  } else {
                    onPage = false;
                    _homeState.enterPage(v);
                  }
                } else {
                  _homeState.enterPage(v);
                }
              },
              type: BottomNavigationBarType.shifting,
              currentIndex: snapshot.data,
              items: user == null
                  ? [
                      BottomNavigationBarItem(
                        backgroundColor: colorPrimary,
                        icon: Icon(
                          MaterialCommunityIcons.store,
                        ),
                        label: "Tienda",
                      ),
                      BottomNavigationBarItem(
                          backgroundColor: colorPrimary,
                          icon: Icon(
                            Feather.shopping_cart,
                          ),
                          label: "Mi carrito"),
                      BottomNavigationBarItem(
                          backgroundColor: colorPrimary,
                          icon: Icon(Icons.person_pin),
                          label: "Perfil"),
                    ]
                  : user.type == "admin"
                      ? [
                          BottomNavigationBarItem(
                            backgroundColor: colorPrimary,
                            icon: Icon(
                              MaterialCommunityIcons.store,
                            ),
                            label: "Tienda",
                          ),
                          BottomNavigationBarItem(
                              backgroundColor: colorPrimary,
                              icon: Icon(
                                Feather.shopping_cart,
                              ),
                              label: "Mi carrito"),
                          BottomNavigationBarItem(
                              backgroundColor: colorPrimary,
                              icon: StreamBuilder(
                                initialData: 0,
                                stream: _homeState.notification,
                                builder: (_, snapshot) {
                                  if (snapshot.data != 0 && !onPage) {
                                    return Badge(
                                      position: BadgePosition.topRight(
                                          top: 7, right: -8),
                                      animationDuration:
                                          Duration(milliseconds: 300),
                                      animationType: BadgeAnimationType.slide,
                                      badgeContent: Text(
                                        snapshot.data.toString(),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      child: Icon(Icons.list),
                                    );
                                  } else {
                                    return Icon(Icons.list);
                                  }
                                },
                              ),
                              label: "Ver pedidos"),
                          BottomNavigationBarItem(
                            label: "Documentos",
                            backgroundColor: colorPrimary,
                            icon: Icon(Icons.description),
                          ),
                          BottomNavigationBarItem(
                              backgroundColor: colorPrimary,
                              icon: Icon(Icons.person_pin),
                              label: "Perfil"),
                        ]
                      : user.type == "client"
                          ? [
                              BottomNavigationBarItem(
                                backgroundColor: colorPrimary,
                                icon: Icon(
                                  MaterialCommunityIcons.store,
                                ),
                                label: "Tienda",
                              ),
                              BottomNavigationBarItem(
                                  backgroundColor: colorPrimary,
                                  icon: Icon(
                                    Feather.shopping_cart,
                                  ),
                                  label: "Mi carrito"),
                              BottomNavigationBarItem(
                                  backgroundColor: colorPrimary,
                                  icon: StreamBuilder(
                                    initialData: 0,
                                    stream: _homeState.notification,
                                    builder: (_, snapshot) {
                                      if (snapshot.data != 0 && !onPage) {
                                        return Badge(
                                          position: BadgePosition.topRight(
                                              top: 7, right: -8),
                                          animationDuration:
                                              Duration(milliseconds: 300),
                                          animationType:
                                              BadgeAnimationType.slide,
                                          badgeContent: Text(
                                            snapshot.data.toString(),
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          child: Icon(
                                              MaterialCommunityIcons.shopping),
                                        );
                                      } else {
                                        return Icon(
                                            MaterialCommunityIcons.shopping);
                                      }
                                    },
                                  ),
                                  label: "Mis pedidos"),
                              BottomNavigationBarItem(
                                  backgroundColor: colorPrimary,
                                  icon: Icon(Icons.person_pin),
                                  label: "Perfil"),
                            ]
                          : [
                              BottomNavigationBarItem(
                                backgroundColor: colorPrimary,
                                icon: Icon(
                                  MaterialCommunityIcons.store,
                                ),
                                label: "Tienda",
                              ),
                              BottomNavigationBarItem(
                                  backgroundColor: colorPrimary,
                                  icon: Icon(
                                    Feather.shopping_cart,
                                  ),
                                  label: "Mi carrito"),
                              BottomNavigationBarItem(
                                  backgroundColor: colorPrimary,
                                  icon: Icon(Icons.person_pin),
                                  label: "Perfil"),
                            ]);
        },
      ),
      body: StreamBuilder(
          stream: _homeState.page,
          initialData: 0,
          builder: (context, snapshot) => _pages[snapshot.data]),
    );
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
                    Icons.new_releases,
                    color: Colors.yellow,
                    size: width * .15,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "¡TIENE UN NUEVO PEDIDO!".toUpperCase(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {
                      preferencesUser.newNotification = false;
                      Navigator.pop(context);
                    },
                    child: Text("CERRAR"),
                    color: colorPrimary,
                    textColor: Colors.white,
                  )
                ],
              ),
            ));
  }

  @override
  void dispose() {
    if (user != null) {
      if (user.type != "admin") {
        _firebaseMessaging?.unsubscribeFromTopic(user.number);
      } else {
        _firebaseMessaging?.unsubscribeFromTopic("newOrder");
      }
    }

    _homeState.dispose();
    super.dispose();
  }
}
