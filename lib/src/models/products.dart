class Products {
  int id;
  int itemId;
  String itemCode;
  int orderId;
  String unid;
  String unitValue;
  String totalBaseIgv;
  String totalIgv;
  String totalTaxes;
  String unitPrice;
  String totalValue;
  String total;
  String description;
  String internCode;
  String stock;
  String image;
  String currency;
  String includesIgv;
  String price;
  int categoryId;
  int quantity;
  dynamic subtotal;

  Products(
      {this.itemId,
      this.unitPrice,
      this.unitValue,
      this.total,
      this.totalBaseIgv,
      this.totalIgv,
      this.totalTaxes,
      this.totalValue,
      this.id,
      this.itemCode,
      this.orderId,
      this.unid,
      this.description,
      this.internCode,
      this.stock,
      this.image,
      this.currency,
      this.includesIgv,
      this.price,
      this.categoryId,
      this.quantity,
      this.subtotal});

  factory Products.fromJson(Map<String, dynamic> json) => Products(
      id: json['id'],
      unid: json['unit_type_id'],
      description: json['description'],
      internCode: json['id'].toString(),
      stock: json['stock'] ?? "0",
      image: json['image_url'],
      currency: json['currency_type_symbol'],
      includesIgv: json['has_igv_description'],
      price: json['amount_sale_unit_price'],
      categoryId: json['category_id'],
      itemCode: json['item_code'] ?? "-");
  factory Products.fromJsonQuantity(Map<String, dynamic> json) {
    return Products(
        id: json['id'],
        itemId: json['item_id'],
        unid: json['unit_type_id'],
        description: json['description'],
        internCode: json['id'].toString(),
        stock: json['stock'] ?? "0",
        image: json['image_url'],
        currency: json['currency_type_symbol'],
        includesIgv: json['has_igv_description'],
        price: json['price'],
        categoryId: json['category_id'],
        itemCode: json['item_code'] ?? "-",
        quantity: json['quantity']);
  }

  factory Products.fromJsonPurchase(Map<String, dynamic> json) => Products(
        id: json['id'],
        itemId: json['item_id'],
        quantity: double.tryParse(json['quantity']).toInt() ?? 0,
        unitValue: json['unit_value'],
        orderId: json['order_note_id'],
        totalBaseIgv: json['total_base_igv'],
        totalIgv: json['total_igv'],
        totalTaxes: json['total_taxes'],
        unitPrice: json['unit_price'],
        totalValue: json['total_value'],
        total: json['total'],
        subtotal: json['total_value'],
        description: json['item']['description'],
        stock: json['item']['warehouses'][0]['stock'],
        price: json['item']['sale_unit_price'],
        itemCode: json['item_code'] ?? "-",
      );
}
//es por el estado pera..
