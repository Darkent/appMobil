import 'dart:convert';

import 'package:delivery_app/src/models/products.dart';
import 'package:delivery_app/src/models/user.dart';
import 'package:delivery_app/src/providers/preferences.dart';
import 'package:delivery_app/src/states/detailState.dart';
import 'package:delivery_app/src/utils/colors.dart';
import 'package:flutter/material.dart';

class DetailProduct extends StatefulWidget {
  final Products products;
  final double width;
  final double height;
  DetailProduct(this.products, {Key key, this.width, this.height})
      : super(key: key);

  @override
  _DetailProductState createState() => _DetailProductState();
}

class _DetailProductState extends State<DetailProduct> {
  List<Products> products;
  Products product;
  double width;
  double height;
  DetailState detailState;
  PreferencesUser preferencesUser;
  bool isSaved = false;
  User user;
  Color colorPrimary;
  Color colorSecondary;
  @override
  void initState() {
    super.initState();
    colorPrimary = visitColor;
    colorSecondary = adminColor;
    preferencesUser = PreferencesUser();
    product = widget.products;
    products = json
        .decode(preferencesUser.productsCar)
        .map<Products>((e) => Products.fromJsonQuantity(e))
        .toList();

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
    detailState = DetailState();
    if (products.length != 0) {
      Products temporal = products.firstWhere(
        (element) => element.id == product.id,
        orElse: () => null,
      );
      if (temporal != null) {
        isSaved = true;
        detailState.sendQuantityProduct(temporal.quantity);
      }
    }
    width = widget.width;
    height = widget.height;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(227, 233, 237, 1),
      appBar: AppBar(
        backgroundColor: colorPrimary,
      ),
      body: SafeArea(
        child: Container(
          width: width,
          height: height * .9,
          child: Stack(
            children: [
              Positioned(
                top: height * .2,
                left: width * .05,
                child: Container(
                  width: width * .9,
                  height: height * .63,
                  child: Card(),
                ),
              ),
              Positioned(
                top: height * .035,
                left: width * .2,
                child: Container(
                  width: width * .6,
                  height: width * .6,
                  child: Card(
                    elevation: 4,
                    borderOnForeground: true,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Hero(
                        tag: '${product.description}',
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              image: DecorationImage(
                                  image: NetworkImage(
                                    product.image,
                                  ),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                      Colors.green.withOpacity(0.2),
                                      BlendMode.luminosity))),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                  top: height * .40,
                  left: width * .2,
                  child: Container(
                    width: width * .6,
                    height: width * .75,
                    child: Column(
                      children: [
                        Text(
                          "${product.description}",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${product.currency}${double.parse(product.price).toStringAsFixed(2)} ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: width * .05),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Stock: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(product.stock)
                            ],
                          ),
                        ),
                        SizedBox(
                          height: height * .02,
                        ),
                        Text(
                          "Cantidad",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: width * .035),
                        ),
                        Container(
                          width: width * .7,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                child: GestureDetector(
                                    child: Icon(
                                      Icons.remove,
                                      size: width * .08,
                                    ),
                                    onTap: () => detailState.decrement),
                              ),
                              StreamBuilder(
                                  initialData: 1,
                                  stream: detailState.quantityProduct,
                                  builder: (context, snapshot) {
                                    int qty = snapshot.data;
                                    return Container(
                                      padding: EdgeInsets.all(width * .02),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              width * .01),
                                          color: colorSecondary),
                                      child: Text(
                                        qty == 0
                                            ? "-"
                                            : (qty > 9 ? "$qty" : "0$qty"),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: width * .05,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  }),
                              Container(
                                child: GestureDetector(
                                    child: Icon(
                                      Icons.add,
                                      size: width * .08,
                                    ),
                                    onTap: () => detailState.increment),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Container(
                                width: width * .65,
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(color: colorPrimary),
                                      borderRadius: new BorderRadius.circular(
                                          width * .015)),
                                  elevation: 0,
                                  color: colorPrimary,
                                  textColor: Colors.white,
                                  onPressed: () {
                                    if (detailState.valueQuantityProduct == 0) {
                                      if (isSaved) {
                                        if (products.length == 1) {
                                          preferencesUser.reset();
                                        } else {
                                          products.removeWhere((element) =>
                                              element.id == product.id);
                                          List<Map> forSave = products
                                              .map<Map>((e) => productToMap(e))
                                              .toList();
                                          preferencesUser.productsCar = forSave;
                                        }
                                      }
                                    } else {
                                      if (isSaved) {
                                        Products temporal = products.firstWhere(
                                            (element) =>
                                                element.id == product.id);
                                        temporal.quantity =
                                            detailState.valueQuantityProduct;
                                        List<Map> forSave = products
                                            .map<Map>((e) => productToMap(e))
                                            .toList();
                                        preferencesUser.productsCar = forSave;
                                      } else {
                                        product.quantity =
                                            detailState.valueQuantityProduct;
                                        products.add(product);
                                        List<Map> forSave = products
                                            .map<Map>((e) => productToMap(e))
                                            .toList();
                                        preferencesUser.productsCar = forSave;
                                      }
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: Text("Agregar al carro"),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ))
            ],
          ),
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

  @override
  void dispose() {
    detailState.dispose();
    super.dispose();
  }
}
