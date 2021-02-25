import 'dart:convert';

import 'package:delivery_app/src/models/products.dart';
import 'package:delivery_app/src/models/user.dart';
import 'package:delivery_app/src/pages/login.dart';

import 'package:delivery_app/src/pages/payment.dart';
import 'package:delivery_app/src/providers/preferences.dart';
import 'package:delivery_app/src/services/shopCarService.dart';
import 'package:delivery_app/src/states/shop_carState.dart';
import 'package:delivery_app/src/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class ShopCarPage extends StatefulWidget {
  final double width;
  final double height;
  final bool fromMenuBar;
  ShopCarPage({this.width, this.height, this.fromMenuBar, Key key})
      : super(key: key);

  @override
  _ShopCarPageState createState() => _ShopCarPageState();
}

class _ShopCarPageState extends State<ShopCarPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PreferencesUser preferencesUser;
  List<Products> restoreProducts;
  ShopCarState shopCarState;
  Color colorPrimary;
  Color colorSecondary;
  User user;
  double width;
  double height;
  bool clear;
  ShopCarService shopCarService;
  @override
  void initState() {
    super.initState();
    shopCarService = ShopCarService();
    clear = false;
    shopCarState = ShopCarState();
    width = widget.width;
    height = widget.height;
    preferencesUser = PreferencesUser();
    restoreProducts = json
        .decode(preferencesUser.productsCar)
        .map<Products>((e) => Products.fromJsonQuantity(e))
        .toList();
    shopCarState.sendProducts(restoreProducts);
    colorPrimary = visitColor;
    colorSecondary = adminColor;
    preferencesUser = PreferencesUser();
    if (preferencesUser.userData.length != 1) {
      user = User.fromjson(json.decode(preferencesUser.userData));
      if (user.type == "admin") {
        colorPrimary = adminColor;
        colorSecondary = visitColor;
      } else if (user.type == "seller") {
        colorPrimary = sellerColor;
        colorSecondary = visitColor;
      }
    }
  }

  void message(String _message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 2),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        content: Text(
          _message,
          textAlign: TextAlign.justify,
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: width * .06),
        )));
  }

  void deleteCar() {
    shopCarState.sendProducts(new List<Products>());
  }

//qye hicisrte poa qye salgfa  el error
// yo nada perro
//ahora hay otro cambio

  ///apura perro
  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: widget.fromMenuBar == null
            ? SizedBox()
            : IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context)),
        backgroundColor: colorPrimary,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: width * .05),
              child: Icon(Feather.shopping_cart),
            ),
            Text("Carrito de compra")
          ],
        ),
      ),
      body: Container(
        child: Column(
          children: [
            restoreProducts.isEmpty
                ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory,
                            size: width * .1,
                            color: colorSecondary,
                          ),
                          Text(
                            "Carrito vacio. \n Agregue un producto de la tienda",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: StreamBuilder(
                        initialData: [],
                        stream: shopCarState.products,
                        builder: (context, snapshot) {
                          if (snapshot.data.isEmpty) {
                            return Center(
                              child: Text("Carrito vacio."),
                            );
                          } else {
                            return ListView.separated(
                              separatorBuilder: (context, index) => Divider(),
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) =>
                                  product(snapshot.data[index]),
                            );
                          }
                        }),
                  ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: width,
                  child: Card(
                    color: Colors.transparent,
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(width * .05),
                          topRight: Radius.circular(width * .05)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            preferencesUser.userData.length == 1
                                ? SizedBox()
                                : Row(
                                    children: [
                                      StreamBuilder(
                                        initialData: [],
                                        stream: shopCarState.products,
                                        builder: (context, snapshot) => Text(
                                          "TOTAL :",
                                          style: TextStyle(
                                            fontSize: width * .05,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * .01,
                                      ),
                                      StreamBuilder(
                                        stream: shopCarState.subtotal,
                                        initialData: 0.00,
                                        builder: (context,
                                            AsyncSnapshot<double> snapshot) {
                                          return Text(
                                            "S/. ${(snapshot.data).toStringAsFixed(2)}",
                                            style: TextStyle(
                                                fontSize: width * .05,
                                                fontWeight: FontWeight.bold),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    preferencesUser.userData.length == 1
                                        ? MainAxisAlignment.center
                                        : MainAxisAlignment.end,
                                children: [
                                  preferencesUser.userData.length == 1
                                      ? Container(
                                          child: RaisedButton.icon(
                                            label: Text(
                                                "Iniciar sesión para enviar el pedido"),
                                            icon: Icon(Icons.lightbulb_outline),
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: colorPrimary),
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        width * .015)),
                                            elevation: 0,
                                            color: Colors.white,
                                            textColor: colorPrimary,
                                            onPressed: () async {
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        LoginPage(
                                                      width: width,
                                                      height: height,
                                                    ),
                                                  ));
                                            },
                                          ),
                                        )
                                      : Container(
                                          child: RaisedButton(
                                            child: Text(
                                              "Enviar pedido",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        width * .015)),
                                            elevation: 0,
                                            color: colorPrimary,
                                            textColor: Colors.white,
                                            onPressed: () async {
                                              if (shopCarState
                                                  .allProducts.isNotEmpty) {
                                                addProductInCar();
                                                widget.fromMenuBar == null
                                                    ? await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    PaymentPage(
                                                                      height:
                                                                          height,
                                                                      width:
                                                                          width,
                                                                      subtotal:
                                                                          shopCarState
                                                                              .getSubtotal,
                                                                    ))).then(
                                                        (value) {
                                                        if (value != null) {
                                                          deleteCar();
                                                        }
                                                        //como se genera el error
                                                      })
                                                    : await Navigator
                                                        .pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        PaymentPage(
                                                                          height:
                                                                              height,
                                                                          width:
                                                                              width,
                                                                          subtotal:
                                                                              shopCarState.getSubtotal,
                                                                        ))).then(
                                                        (value) {
                                                        if (value != null) {
                                                          deleteCar();
                                                        }
                                                      });
                                              }
                                            },
                                          ),
                                        )
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Card product(Products product) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: width * .27,
              height: height * .15,
              child: Stack(
                children: [
                  Card(
                    child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Container(
                          height: height * .15,
                          decoration: new BoxDecoration(
                              image: new DecorationImage(
                            image: NetworkImage(product.image),
                          )),
                        )),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.red),
                      child: GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          onTap: () {
                            shopCarState.allProducts.removeWhere(
                                (element) => element.id == product.id);
                            shopCarState.sendProducts(shopCarState.allProducts);
                            if (shopCarState.allProducts.length == 0) {
                              preferencesUser.reset();
                            }
                          }),
                    ),
                  )
                ],
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 400 > width ? width * .5 : width * .55,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${product.description}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: width * .04),
                        ),
                        Text(
                          " S/.${double.parse(product.price).toStringAsFixed(2)}  Und ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: colorPrimary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(width * .015)),
                        child: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              Products temporal = shopCarState.allProducts
                                  .firstWhere(
                                      (element) => element.id == product.id);
                              ++temporal.quantity;
                              shopCarState
                                  .sendProducts(shopCarState.allProducts);
                            }),
                      ),
                      Container(
                        padding: EdgeInsets.all(width * .02),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(width * .01),
                            color: colorSecondary),
                        child: Text(
                          product.quantity == 0
                              ? "-"
                              : (product.quantity > 9
                                  ? "${product.quantity}"
                                  : "0${product.quantity}"),
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(width * .015)),
                        child: IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              Products temporal = shopCarState.allProducts
                                  .firstWhere(
                                      (element) => element.id == product.id);
                              if (temporal.quantity != 0) {
                                --temporal.quantity;
                                shopCarState
                                    .sendProducts(shopCarState.allProducts);
                              }
                            }),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Map productToMap(Products product) {
    Map mapTemporal = {
      "id": product.id,
      "item_id": product.id,
      "unit_type_id": product.unid,
      "description": product.description,
      "internal_id": product.internCode,
      "stock": product.stock,
      "image_url": product.image,
      "currency_type_symbol": product.currency,
      "has_igv_description": product.includesIgv,
      "price": product.price,
      "category_id": product.categoryId,
      "quantity": product.quantity,
    };

    return mapTemporal;
  }

  addProductInCar() {
    List<Products> temporal = shopCarState.allProducts
        .where((element) => element.quantity != 0)
        .toList();
    List<Map> saveProducts = temporal.map<Map>((e) => productToMap(e)).toList();
    preferencesUser.productsCar = saveProducts;
  }

//a ver prueba..
  @override
  void dispose() async {
    addProductInCar();
    shopCarState.dispose();
    super.dispose();
  }
}
