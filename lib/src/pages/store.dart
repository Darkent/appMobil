import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:delivery_app/main.dart';
import 'package:delivery_app/src/models/categories.dart';
import 'package:delivery_app/src/models/products.dart';
import 'package:delivery_app/src/models/user.dart';

import 'package:delivery_app/src/pages/detailProduct.dart';
import 'package:delivery_app/src/pages/shop_car.dart';
import 'package:delivery_app/src/providers/preferences.dart';
import 'package:delivery_app/src/providers/searchDelegate.dart';
import 'package:delivery_app/src/services/productsService.dart';
import 'package:delivery_app/src/states/globalState.dart';
import 'package:delivery_app/src/states/storeState.dart';
import 'package:delivery_app/src/utils/colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:provider/provider.dart';

class StorePage extends StatefulWidget {
  final double width;
  final double height;
  StorePage({this.width, this.height, Key key}) : super(key: key);

  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ProductsServices _productsServices;
  List<Products> _products;
  List<Category> _categories;
  List<List<Products>> _productsByCategory;

  StoreState storeState;
  double width;
  double height;
  int page;
  int productsInCar;
  PreferencesUser preferencesUser;
  Color colorPrimary;
  User user;
  @override
  void initState() {
    super.initState();

    colorPrimary = visitColor;

    preferencesUser = PreferencesUser();
    if (preferencesUser.userData.length != 1) {
      user = User.fromjson(json.decode(preferencesUser.userData));
      print("tipo de usuario ${user.type} ");
      if (user.type == "admin") {
        colorPrimary = adminColor;
      } else if (user.type == "seller") {
        colorPrimary = sellerColor;
      }
    }
    storeState = StoreState();

    page = 0;
    width = widget.width;
    height = widget.height;
    _productsServices = ProductsServices();
    restoreProductInCar();
    if (Provider.of<AppGlobalState>(context, listen: false).products.isEmpty) {
      getItems();
    } else {
      getFromProvider();
    }
  }

  void message(String _message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        content: Text(
          _message,
          textAlign: TextAlign.justify,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        )));
  }

  void restoreProductInCar() async {
    Future.delayed(Duration(milliseconds: 200), () {
      int productsLength = preferencesUser.productsCar == null
          ? 0
          : json.decode(preferencesUser.productsCar).length;

      storeState.sendProductsInCar(productsLength);
    });
  }

  void getFromProvider() {
    _products = Provider.of<AppGlobalState>(context, listen: false).products;
    _categories =
        Provider.of<AppGlobalState>(context, listen: false).categories;

    _productsByCategory =
        Provider.of<AppGlobalState>(context, listen: false).productsByCategory;
    setState(() {});
  }

  void getItems() async {
    List x = await _productsServices.allProductsAndCategories();
    // List x = await _productsServices.noInternet();
    _categories = x[0];
    Provider.of<AppGlobalState>(context, listen: false).categories = x[0];
    _products = x[1];
    Provider.of<AppGlobalState>(context, listen: false).products = x[1];
    _productsByCategory = _productsByCategories();
    Provider.of<AppGlobalState>(context, listen: false).productsByCategory =
        _productsByCategories();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: colorPrimary,
        centerTitle: true,
        title: Text(
          "Pedido",
        ),
        elevation: 0,
        actions: [
          IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () async {
                await showSearch(
                        context: context,
                        delegate: SearchDelegateProduct("Buscar", _products))
                    .then((value) {
                  if (value is Products) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailProduct(
                            value,
                            height: widget.height,
                            width: widget.width,
                          ),
                        )).then((value) => restoreProductInCar());
                  }
                });
              }),
          StreamBuilder(
              stream: storeState.productsInCar,
              initialData: 0,
              builder: (context, snapshot) {
                if (snapshot.data != 0) {
                  return Badge(
                    position: BadgePosition.topRight(top: 0, right: 3),
                    animationDuration: Duration(milliseconds: 300),
                    animationType: BadgeAnimationType.slide,
                    badgeContent: Text(
                      snapshot.data.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                    child: IconButton(
                        icon: Icon(MaterialCommunityIcons.bag_personal),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShopCarPage(
                                fromMenuBar: true,
                                width: width,
                                height: height,
                              ),
                            ))),
                  );
                } else {
                  return IconButton(
                      icon: Icon(MaterialCommunityIcons.bag_personal),
                      onPressed: null);
                }
              }),
        ],
      ),
      body: _products == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  height: height * (600 > height ? .2 : .17),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          StreamBuilder(
                            initialData: 0,
                            stream: storeState.page,
                            builder: (context, snapshot) => GestureDetector(
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: snapshot.data == index + 1
                                          ? colorPrimary
                                          : Colors.transparent),
                                  borderRadius:
                                      BorderRadius.circular(width * .15),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(width * .05),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 350),
                                    curve: Curves.easeInOutCubic,
                                    width: snapshot.data == index + 1
                                        ? width * .07
                                        : width * .06,
                                    height: snapshot.data == index + 1
                                        ? width * .07
                                        : width * .06,
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              _categories[index].icono),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () {
                                storeState.enterPage(index + 1);
                              },
                            ),
                          ),
                          Text(
                            "${_categories[index].name}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: width * .035),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                StreamBuilder(
                    stream: storeState.page,
                    initialData: 0,
                    builder: (context, snapshot) {
                      if (snapshot.data == 0) {
                        return Expanded(
                            child: ListView(
                          shrinkWrap: true,
                          children: _productsByCategory.map<Widget>((e) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        nameCategory(e[0].categoryId),
                                        style: TextStyle(
                                            fontSize: width * .045,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      GestureDetector(
                                        child: Text(
                                          "Ver todo..",
                                          style: TextStyle(
                                              color: colorPrimary,
                                              fontSize: width * .03,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onTap: () {
                                          int idx = _productsByCategory.length -
                                              e[0].categoryId +
                                              1;
                                          storeState.enterPage(idx);
                                        },
                                      )
                                    ],
                                  ),
                                  Center(
                                    child: productsId(e),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ));
                      } else {
                        return Expanded(
                            child: allProductsCategory(snapshot.data));
                      }
                    })
              ],
            ),
    );
  }

  Widget allProductsCategory(int i) {
    List<Products> products = _productsByCategory[i - 1];
    return GridView.count(
      childAspectRatio: (width / (height / 1.5)),
      crossAxisCount: 2,
      shrinkWrap: true,
      children: products
          .map<Widget>((e) => Stack(
                children: [
                  Container(
                    width: width * .5,
                    child: Column(
                      children: [
                        Container(
                          width: width * .4,
                          height: width * .4,
                          child: GestureDetector(
                            child: Stack(
                              children: [
                                Hero(
                                  tag: '${e.description}',
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                  e.image,
                                                ),
                                                fit: BoxFit.cover,
                                                colorFilter: ColorFilter.mode(
                                                    Colors.green
                                                        .withOpacity(0.2),
                                                    BlendMode.luminosity))),
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: GestureDetector(
                                      child: CircleAvatar(
                                        backgroundColor: colorSecondary,
                                        child: Icon(
                                          Icons.add_shopping_cart,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onTap: () => addProductInCar(e)),
                                )
                              ],
                            ),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailProduct(
                                    e,
                                    height: widget.height,
                                    width: widget.width,
                                  ),
                                )).then((value) => restoreProductInCar()),
                          ),
                        ),
                        Text(
                          e.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "S/.${double.parse(e.price).toStringAsFixed(2)}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ))
          .toList(),
    );
  }

  String nameCategory(int id) {
    return _categories.firstWhere((element) => element.id == id).name;
  }

  SizedBox productsId(List<Products> products) {
    print(height);

    products = products.sublist(0, 3);
    return SizedBox(
      height: height * (600 > height ? .36 : .33),
      child: ListView.builder(
        itemCount: products.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => Stack(
          children: [
            Container(
              width: width * .5,
              height: height * (600 > height ? .36 : .33),
              child: Column(
                children: [
                  Container(
                    width: width * .4,
                    height: width * .39,
                    child: GestureDetector(
                      child: Stack(
                        children: [
                          Hero(
                            tag: '${products[index].description}',
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: width,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(
                                            products[index].image,
                                          ),
                                          fit: BoxFit.cover,
                                          colorFilter: ColorFilter.mode(
                                              Colors.green.withOpacity(0.2),
                                              BlendMode.luminosity))),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: GestureDetector(
                                child: CircleAvatar(
                                  backgroundColor: colorSecondary,
                                  child: Icon(Icons.add_shopping_cart,
                                      color: Colors.white),
                                ),
                                onTap: () => addProductInCar(products[index])),
                          )
                        ],
                      ),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailProduct(
                              products[index],
                              height: widget.height,
                              width: widget.width,
                            ),
                          )).then((value) => restoreProductInCar()),
                    ),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(
                      "Stock: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(products[index].stock)
                  ]),
                  Text(
                    products[index].description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "S/.${double.parse(products[index].price).toStringAsFixed(2)}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
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
      "quantity": 1,
    };

    return mapTemporal;
  }

  void addProductInCar(Products product) {
    if (preferencesUser.productsCar == null) {
      List<Map> temporal = [];
      temporal.add(productToMap(product));
      preferencesUser.productsCar = temporal;
      storeState.sendProductsInCar(temporal.length);
    } else {
      List<dynamic> productsTemporal =
          json.decode(preferencesUser.productsCar) as List<dynamic>;
      Map productFiltered = productsTemporal.firstWhere(
          (element) => element['id'] == product.id,
          orElse: () => null);
      if (productFiltered == null) {
        productsTemporal.add(productToMap(product));
        preferencesUser.productsCar = productsTemporal;
        storeState.sendProductsInCar(productsTemporal.length);
      } else {
        ++productFiltered['quantity'];
        preferencesUser.productsCar = productsTemporal;
        message(
            "Ya tiene ${productFiltered['quantity']} items de este producto");
      }
    }
  }

  List<List<Products>> _productsByCategories() {
    List<int> _idCategories = _categories.map<int>((c) => c.id).toList();
    List<List<Products>> _productsPreview = [];
    for (int i = 0; i < _idCategories.length; i++) {
      List<Products> temporal = _products
          .where((element) => element.categoryId == _idCategories[i])
          .toList();
      _productsPreview.add(temporal);
    }

    return _productsPreview;
  }

  @override
  void dispose() {
    storeState.dispose();
    super.dispose();
  }
}
