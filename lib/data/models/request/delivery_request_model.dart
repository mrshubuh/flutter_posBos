import 'dart:convert';

class DeliveryRequestModel {
  final int orderId;
  final int driverId;
  final String recipientName;
  final String recipientPhone;
  final String recipientAddress;
  final String recipientCity;
  final String recipientState;
  final String recipientPostalCode;
  final String scheduledDeliveryDatetime;
  final double totalWeight;
  final bool requiresSpecialHandling;
  final String? deliveryNotesInternal;
  final String? deliveryNotesCustomer;

  DeliveryRequestModel({
    required this.orderId,
    required this.driverId,
    required this.recipientName,
    required this.recipientPhone,
    required this.recipientAddress,
    required this.recipientCity,
    required this.recipientState,
    required this.recipientPostalCode,
    required this.scheduledDeliveryDatetime,
    required this.totalWeight,
    required this.requiresSpecialHandling,
    this.deliveryNotesInternal,
    this.deliveryNotesCustomer,
  });

  factory DeliveryRequestModel.fromJson(String str) =>
      DeliveryRequestModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DeliveryRequestModel.fromMap(Map<String, dynamic> json) =>
      DeliveryRequestModel(
        orderId: json["order_id"],
        driverId: json["driver_id"],
        recipientName: json["recipient_name"],
        recipientPhone: json["recipient_phone"],
        recipientAddress: json["recipient_address"],
        recipientCity: json["recipient_city"],
        recipientState: json["recipient_state"],
        recipientPostalCode: json["recipient_postal_code"],
        scheduledDeliveryDatetime: json["scheduled_delivery_datetime"],
        totalWeight: json["total_weight"]?.toDouble() ?? 0.0,
        requiresSpecialHandling: json["requires_special_handling"] ?? false,
        deliveryNotesInternal: json["delivery_notes_internal"],
        deliveryNotesCustomer: json["delivery_notes_customer"],
      );

  Map<String, dynamic> toMap() => {
        "order_id": orderId,
        "driver_id": driverId,
        "recipient_name": recipientName,
        "recipient_phone": recipientPhone,
        "recipient_address": recipientAddress,
        "recipient_city": recipientCity,
        "recipient_state": recipientState,
        "recipient_postal_code": recipientPostalCode,
        "scheduled_delivery_datetime": scheduledDeliveryDatetime,
        "total_weight": totalWeight,
        "requires_special_handling": requiresSpecialHandling,
        "delivery_notes_internal": deliveryNotesInternal,
        "delivery_notes_customer": deliveryNotesCustomer,
      };
}
