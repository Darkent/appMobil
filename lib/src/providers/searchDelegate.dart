import 'package:delivery_app/src/models/products.dart';
import 'package:flutter/material.dart';

class SearchDelegateProduct extends SearchDelegate {
  @override
  final String searchFieldLabel;

  final List<Products> products;

  SearchDelegateProduct(this.searchFieldLabel, this.products);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.clear), onPressed: () => this.query = '')
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () => this.close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().length == 0) {
      return Center(
          child: Text('INGRESE EL NOMBRE DE UN PRODUCTO PARA LA BUSQUEDA'));
    }
    return search(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Text("");
  }

  Widget search(String productName) {
    List<Products> temporal = products
        .where((element) => element.description
            .toUpperCase()
            .contains(productName.toUpperCase()))
        .toList();

    if (temporal.length == 0) {
      return Center(child: Text('NO SE ENCONTRÓ UN PRODUCTO CON EL NOMBRE'));
    } else {
      return ListView.builder(
        itemCount: temporal.length,
        itemBuilder: (context, i) {
          final product = temporal[i];

          return ListTile(
            leading: Image.network(
              product.image,
              fit: BoxFit.cover,
            ),
            title: Text(product.description),
            subtitle: Text(double.parse(product.price).toStringAsFixed(2)),
            onTap: () {
              this.close(context, product);
            },
          );
        },
      );
    }
  }
}
