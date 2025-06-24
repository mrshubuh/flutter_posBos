import 'dart:convert';

class OrderRequestModel {
  final String transactionTime;
  final int kasirId;
  final double totalPrice;
  final int totalItem;
  final String paymentMethod;
  final double paymentAmount;
  final double subTotal;
  final double tax;
  final double discount;
  final double serviceCharge;
  final List<OrderItemModel> orderItems;

  OrderRequestModel({
    required this.transactionTime,
    required this.kasirId,
    required this.totalPrice,
    required this.totalItem,
    required this.paymentMethod,
    required this.paymentAmount,
    required this.subTotal,
    required this.tax,
    required this.discount,
    required this.serviceCharge,
    required this.orderItems,
  });

  factory OrderRequestModel.fromJson(String str) =>
      OrderRequestModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OrderRequestModel.fromMap(Map<String, dynamic> json) =>
      OrderRequestModel(
        transactionTime: json["transaction_time"],
        kasirId: json["kasir_id"],
        totalPrice: json["total_price"]?.toDouble() ?? 0.0,
        totalItem: json["total_item"],
        paymentMethod: json["payment_method"],
        paymentAmount: json["payment_amount"]?.toDouble() ?? 0.0,
        subTotal: json["sub_total"]?.toDouble() ?? 0.0,
        tax: json["tax"]?.toDouble() ?? 0.0,
        discount: json["discount"]?.toDouble() ?? 0.0,
        serviceCharge: json["service_charge"]?.toDouble() ?? 0.0,
        orderItems: List<OrderItemModel>.from(
            json["order_items"].map((x) => OrderItemModel.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "transaction_time": transactionTime,
        "kasir_id": kasirId,
        "total_price": totalPrice,
        "total_item": totalItem,
        "payment_method": paymentMethod,
        "payment_amount": paymentAmount,
        "sub_total": subTotal,
        "tax": tax,
        "discount": discount,
        "service_charge": serviceCharge,
        "order_items": List<dynamic>.from(orderItems.map((x) => x.toMap())),
      };
}

class OrderItemModel {
  final int productId;
  final int quantity;
  final double totalPrice;

  OrderItemModel({
    required this.productId,
    required this.quantity,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(String str) =>
      OrderItemModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OrderItemModel.fromMap(Map<String, dynamic> json) => OrderItemModel(
        productId: json["product_id"],
        quantity: json["quantity"],
        totalPrice: json["total_price"]?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toMap() => {
        "product_id": productId,
        "quantity": quantity,
        "total_price": totalPrice,
      };
}
