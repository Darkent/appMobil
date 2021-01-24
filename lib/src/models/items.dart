import 'dart:convert';

Sale saleFromJson(String str) => Sale.fromJson(json.decode(str));

String saleToJson(Sale data) => json.encode(data.toJson());

class Sale {
  Sale(
      {this.id,
      this.userId,
      this.prefix,
      this.establishmentId,
      this.dateOfIssue,
      this.timeOfIssue,
      this.customerId,
      this.currencyTypeId,
      this.purchaseOrder,
      this.exchangeRateSale,
      this.totalPrepayment,
      this.totalCharge,
      this.totalDiscount,
      this.totalExportation,
      this.totalFree,
      this.totalTaxed,
      this.totalUnaffected,
      this.totalExonerated,
      this.totalIgv,
      this.totalBaseIsc,
      this.totalIsc,
      this.totalBaseOtherTaxes,
      this.totalOtherTaxes,
      this.totalTaxes,
      this.totalValue,
      this.total,
      this.paymentMethodTypeId,
      this.operationTypeId,
      this.dateOfDue,
      this.deliveryDate,
      this.charges,
      this.discounts,
      this.attributes,
      this.guides,
      this.additionalInformation,
      this.actions,
      this.items});
  List<Product> items;
  int id;
  int userId;
  String prefix;
  int establishmentId;
  DateTime dateOfIssue;
  String timeOfIssue;
  int customerId;
  String currencyTypeId;
  dynamic purchaseOrder;
  double exchangeRateSale;
  int totalPrepayment;
  int totalCharge;
  int totalDiscount;
  int totalExportation;
  int totalFree;
  double totalTaxed;
  int totalUnaffected;
  int totalExonerated;
  double totalIgv;
  int totalBaseIsc;
  int totalIsc;
  int totalBaseOtherTaxes;
  int totalOtherTaxes;
  double totalTaxes;
  double totalValue;
  double total;
  String paymentMethodTypeId;
  dynamic operationTypeId;
  DateTime dateOfDue;
  DateTime deliveryDate;
  List<dynamic> charges;
  List<dynamic> discounts;
  List<dynamic> attributes;
  List<dynamic> guides;
  dynamic additionalInformation;
  Actions actions;

  factory Sale.fromJson(Map<String, dynamic> json) => Sale(
        id: json["id"],
        userId: json["user_id"],
        prefix: json["prefix"],
        establishmentId: json["establishment_id"],
        dateOfIssue: DateTime.parse(json["date_of_issue"]),
        timeOfIssue: json["time_of_issue"],
        customerId: json["customer_id"],
        currencyTypeId: json["currency_type_id"],
        purchaseOrder: json["purchase_order"],
        exchangeRateSale: json["exchange_rate_sale"].toDouble(),
        totalPrepayment: json["total_prepayment"],
        totalCharge: json["total_charge"],
        totalDiscount: json["total_discount"],
        totalExportation: json["total_exportation"],
        totalFree: json["total_free"],
        totalTaxed: json["total_taxed"].toDouble(),
        totalUnaffected: json["total_unaffected"],
        totalExonerated: json["total_exonerated"],
        totalIgv: json["total_igv"].toDouble(),
        totalBaseIsc: json["total_base_isc"],
        totalIsc: json["total_isc"],
        totalBaseOtherTaxes: json["total_base_other_taxes"],
        totalOtherTaxes: json["total_other_taxes"],
        totalTaxes: json["total_taxes"].toDouble(),
        totalValue: json["total_value"].toDouble(),
        total: json["total"].toDouble(),
        items: json['items']
            .map<Product>((item) => Product.fromJson(item))
            .toList(),
        paymentMethodTypeId: json["payment_method_type_id"],
        operationTypeId: json["operation_type_id"],
        dateOfDue: DateTime.parse(json["date_of_due"]),
        deliveryDate: DateTime.parse(json["delivery_date"]),
        charges: List<dynamic>.from(json["charges"].map((x) => x)),
        discounts: List<dynamic>.from(json["discounts"].map((x) => x)),
        attributes: List<dynamic>.from(json["attributes"].map((x) => x)),
        guides: List<dynamic>.from(json["guides"].map((x) => x)),
        additionalInformation: json["additional_information"],
        actions: Actions.fromJson(json["actions"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "prefix": prefix,
        "establishment_id": establishmentId,
        "date_of_issue": dateOfIssue.toIso8601String(),
        "time_of_issue": timeOfIssue,
        "customer_id": customerId,
        "currency_type_id": currencyTypeId,
        "purchase_order": purchaseOrder,
        "exchange_rate_sale": exchangeRateSale,
        "total_prepayment": totalPrepayment,
        "total_charge": totalCharge,
        "total_discount": totalDiscount,
        "total_exportation": totalExportation,
        "total_free": totalFree,
        "total_taxed": totalTaxed,
        "total_unaffected": totalUnaffected,
        "total_exonerated": totalExonerated,
        "total_igv": totalIgv,
        "total_base_isc": totalBaseIsc,
        "total_isc": totalIsc,
        "total_base_other_taxes": totalBaseOtherTaxes,
        "total_other_taxes": totalOtherTaxes,
        "total_taxes": totalTaxes,
        "total_value": totalValue,
        "total": total,
        "payment_method_type_id": paymentMethodTypeId,
        "operation_type_id": operationTypeId,
        "date_of_due": dateOfDue.toIso8601String(),
        "delivery_date": deliveryDate.toIso8601String(),
        "charges": List<dynamic>.from(charges.map((x) => x)),
        "discounts": List<dynamic>.from(discounts.map((x) => x)),
        "attributes": List<dynamic>.from(attributes.map((x) => x)),
        "guides": List<dynamic>.from(guides.map((x) => x)),
        "additional_information": additionalInformation,
        "actions": actions.toJson(),
      };
}

class Actions {
  Actions({
    this.formatPdf,
  });

  String formatPdf;

  factory Actions.fromJson(Map<String, dynamic> json) => Actions(
        formatPdf: json["format_pdf"],
      );

  Map<String, dynamic> toJson() => {
        "format_pdf": formatPdf,
      };
}

Product productFromJson(String str) => Product.fromJson(json.decode(str));

String productToJson(Product data) => json.encode(data.toJson());

class Product {
  Product({
    this.id,
    this.orderNoteId,
    this.itemId,
    this.item,
    this.quantity,
    this.unitValue,
    this.affectationIgvTypeId,
    this.totalBaseIgv,
    this.percentageIgv,
    this.totalIgv,
    this.systemIscTypeId,
    this.totalBaseIsc,
    this.percentageIsc,
    this.totalIsc,
    this.totalBaseOtherTaxes,
    this.percentageOtherTaxes,
    this.totalOtherTaxes,
    this.totalTaxes,
    this.priceTypeId,
    this.unitPrice,
    this.totalValue,
    this.totalCharge,
    this.totalDiscount,
    this.total,
    this.attributes,
    this.discounts,
    this.charges,
    this.affectationIgvType,
    this.systemIscType,
    this.priceType,
  });

  int id;
  int orderNoteId;
  int itemId;
  Item item;
  String quantity;
  String unitValue;
  String affectationIgvTypeId;
  String totalBaseIgv;
  String percentageIgv;
  String totalIgv;
  dynamic systemIscTypeId;
  String totalBaseIsc;
  String percentageIsc;
  String totalIsc;
  String totalBaseOtherTaxes;
  String percentageOtherTaxes;
  String totalOtherTaxes;
  String totalTaxes;
  String priceTypeId;
  String unitPrice;
  String totalValue;
  String totalCharge;
  String totalDiscount;
  String total;
  Attributes attributes;
  Attributes discounts;
  Attributes charges;
  AffectationIgvType affectationIgvType;
  dynamic systemIscType;
  PriceType priceType;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        orderNoteId: json["order_note_id"],
        itemId: json["item_id"],
        item: Item.fromJson(json["item"]),
        quantity: json["quantity"],
        unitValue: json["unit_value"],
        affectationIgvTypeId: json["affectation_igv_type_id"],
        totalBaseIgv: json["total_base_igv"],
        percentageIgv: json["percentage_igv"],
        totalIgv: json["total_igv"],
        systemIscTypeId: json["system_isc_type_id"],
        totalBaseIsc: json["total_base_isc"],
        percentageIsc: json["percentage_isc"],
        totalIsc: json["total_isc"],
        totalBaseOtherTaxes: json["total_base_other_taxes"],
        percentageOtherTaxes: json["percentage_other_taxes"],
        totalOtherTaxes: json["total_other_taxes"],
        totalTaxes: json["total_taxes"],
        priceTypeId: json["price_type_id"],
        unitPrice: json["unit_price"],
        totalValue: json["total_value"],
        totalCharge: json["total_charge"],
        totalDiscount: json["total_discount"],
        total: json["total"],
        attributes: Attributes.fromJson(json["attributes"]),
        discounts: Attributes.fromJson(json["discounts"]),
        charges: Attributes.fromJson(json["charges"]),
        affectationIgvType:
            AffectationIgvType.fromJson(json["affectation_igv_type"]),
        systemIscType: json["system_isc_type"],
        priceType: PriceType.fromJson(json["price_type"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_note_id": orderNoteId,
        "item_id": itemId,
        "item": item.toJson(),
        "quantity": quantity,
        "unit_value": unitValue,
        "affectation_igv_type_id": affectationIgvTypeId,
        "total_base_igv": totalBaseIgv,
        "percentage_igv": percentageIgv,
        "total_igv": totalIgv,
        "system_isc_type_id": systemIscTypeId,
        "total_base_isc": totalBaseIsc,
        "percentage_isc": percentageIsc,
        "total_isc": totalIsc,
        "total_base_other_taxes": totalBaseOtherTaxes,
        "percentage_other_taxes": percentageOtherTaxes,
        "total_other_taxes": totalOtherTaxes,
        "total_taxes": totalTaxes,
        "price_type_id": priceTypeId,
        "unit_price": unitPrice,
        "total_value": totalValue,
        "total_charge": totalCharge,
        "total_discount": totalDiscount,
        "total": total,
        "attributes": attributes.toJson(),
        "discounts": discounts.toJson(),
        "charges": charges.toJson(),
        "affectation_igv_type": affectationIgvType.toJson(),
        "system_isc_type": systemIscType,
        "price_type": priceType.toJson(),
      };
}

class AffectationIgvType {
  AffectationIgvType({
    this.id,
    this.active,
    this.exportation,
    this.free,
    this.description,
  });

  String id;
  int active;
  int exportation;
  int free;
  String description;

  factory AffectationIgvType.fromJson(Map<String, dynamic> json) =>
      AffectationIgvType(
        id: json["id"],
        active: json["active"],
        exportation: json["exportation"],
        free: json["free"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "active": active,
        "exportation": exportation,
        "free": free,
        "description": description,
      };
}

class Attributes {
  Attributes();

  factory Attributes.fromJson(Map<String, dynamic> json) => Attributes();

  Map<String, dynamic> toJson() => {};
}

class Item {
  Item({
    this.id,
    this.isSet,
    this.hasIgv,
    this.unitPrice,
    this.warehouses,
    this.description,
    this.presentation,
    this.unitTypeId,
    this.itemUnitTypes,
    this.saleUnitPrice,
    this.currencyTypeId,
    this.fullDescription,
    this.calculateQuantity,
    this.purchaseUnitPrice,
    this.currencyTypeSymbol,
    this.saleAffectationIgvTypeId,
    this.purchaseAffectationIgvTypeId,
  });

  int id;
  bool isSet;
  bool hasIgv;
  String unitPrice;
  List<Warehouse> warehouses;
  String description;
  List<dynamic> presentation;
  String unitTypeId;
  List<dynamic> itemUnitTypes;
  String saleUnitPrice;
  String currencyTypeId;
  String fullDescription;
  bool calculateQuantity;
  String purchaseUnitPrice;
  String currencyTypeSymbol;
  String saleAffectationIgvTypeId;
  String purchaseAffectationIgvTypeId;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        isSet: json["is_set"],
        hasIgv: json["has_igv"],
        unitPrice: json["unit_price"],
        warehouses: List<Warehouse>.from(
            json["warehouses"].map((x) => Warehouse.fromJson(x))),
        description: json["description"],
        presentation: List<dynamic>.from(json["presentation"].map((x) => x)),
        unitTypeId: json["unit_type_id"],
        itemUnitTypes:
            List<dynamic>.from(json["item_unit_types"].map((x) => x)),
        saleUnitPrice: json["sale_unit_price"],
        currencyTypeId: json["currency_type_id"],
        fullDescription: json["full_description"],
        calculateQuantity: json["calculate_quantity"],
        purchaseUnitPrice: json["purchase_unit_price"],
        currencyTypeSymbol: json["currency_type_symbol"],
        saleAffectationIgvTypeId: json["sale_affectation_igv_type_id"],
        purchaseAffectationIgvTypeId: json["purchase_affectation_igv_type_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "is_set": isSet,
        "has_igv": hasIgv,
        "unit_price": unitPrice,
        "warehouses": List<dynamic>.from(warehouses.map((x) => x.toJson())),
        "description": description,
        "presentation": List<dynamic>.from(presentation.map((x) => x)),
        "unit_type_id": unitTypeId,
        "item_unit_types": List<dynamic>.from(itemUnitTypes.map((x) => x)),
        "sale_unit_price": saleUnitPrice,
        "currency_type_id": currencyTypeId,
        "full_description": fullDescription,
        "calculate_quantity": calculateQuantity,
        "purchase_unit_price": purchaseUnitPrice,
        "currency_type_symbol": currencyTypeSymbol,
        "sale_affectation_igv_type_id": saleAffectationIgvTypeId,
        "purchase_affectation_igv_type_id": purchaseAffectationIgvTypeId,
      };
}

class Warehouse {
  Warehouse({
    this.stock,
    this.warehouseId,
    this.warehouseDescription,
  });

  String stock;
  int warehouseId;
  String warehouseDescription;

  factory Warehouse.fromJson(Map<String, dynamic> json) => Warehouse(
        stock: json["stock"],
        warehouseId: json["warehouse_id"],
        warehouseDescription: json["warehouse_description"],
      );

  Map<String, dynamic> toJson() => {
        "stock": stock,
        "warehouse_id": warehouseId,
        "warehouse_description": warehouseDescription,
      };
}

class PriceType {
  PriceType({
    this.id,
    this.active,
    this.description,
  });

  String id;
  int active;
  String description;

  factory PriceType.fromJson(Map<String, dynamic> json) => PriceType(
        id: json["id"],
        active: json["active"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "active": active,
        "description": description,
      };
}
