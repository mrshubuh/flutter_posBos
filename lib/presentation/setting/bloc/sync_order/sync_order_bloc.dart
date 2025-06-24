import 'package:bloc/bloc.dart';
import 'package:flutter_pos/data/datasources/product_local_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_pos/data/datasources/order_remote_datasource.dart';
import 'package:flutter_pos/data/models/request/order_request_model.dart';

part 'sync_order_bloc.freezed.dart';
part 'sync_order_event.dart';
part 'sync_order_state.dart';

class SyncOrderBloc extends Bloc<SyncOrderEvent, SyncOrderState> {
  final OrderRemoteDatasource orderRemoteDatasource;
  SyncOrderBloc(
    this.orderRemoteDatasource,
  ) : super(const _Initial()) {
    on<_SendOrder>((event, emit) async {
      emit(const SyncOrderState.loading());

      final ordersIsSyncZero =
          await ProductLocalDatasource.instance.getOrderByIsSync();

      for (final order in ordersIsSyncZero) {
        final orderItems = await ProductLocalDatasource.instance
            .getOrderItemByOrderIdLocal(order.id!);
        final orderItemModels1 = orderItems
            .map((item) => OrderItemModel(
                  productId: item.product.id!,
                  quantity: item.quantity,
                  totalPrice: (item.product.price * item.quantity).toDouble(),
                ))
            .toList();
        final orderRequest = OrderRequestModel(
            transactionTime: order.transactionTime,
            totalItem: order.totalQuantity,
            totalPrice: order.totalPrice.toDouble(),
            kasirId: order.idKasir,
            paymentMethod: order.paymentMethod,
            orderItems: orderItemModels1,
            paymentAmount: 0.0, // Changed from null to 0.0
            subTotal: order.totalPrice.toDouble(), // Added subtotal
            tax: 0.0, // Changed from null to 0.0
            discount: 0.0, // Changed from null to 0.0
            serviceCharge: 0.0 // Changed from null to 0.0
            );
        final response = await orderRemoteDatasource.createOrder(orderRequest);
        if (response['success'] as bool) {
          await ProductLocalDatasource.instance
              .updateIsSyncOrderById(order.id!);
        }
      }

      emit(const SyncOrderState.success());
    });

    on<_SendOrderForCloseChasier>((event, emit) async {
      emit(const SyncOrderState.loading());

      final ordersIsSyncZero =
          await ProductLocalDatasource.instance.getOrderByIsSync();

      for (final order in ordersIsSyncZero) {
        final orderItems = await ProductLocalDatasource.instance
            .getOrderItemByOrderIdLocal(order.id!);
        final orderItemModels2 = orderItems
            .map((item) => OrderItemModel(
                  productId: item.product.id!,
                  quantity: item.quantity,
                  totalPrice: (item.product.price * item.quantity).toDouble(),
                ))
            .toList();

        final orderRequest = OrderRequestModel(
            transactionTime: order.transactionTime,
            totalItem: order.totalQuantity,
            totalPrice: order.totalPrice.toDouble(),
            kasirId: order.idKasir,
            paymentMethod: order.paymentMethod,
            orderItems: orderItemModels2,
            paymentAmount: 0.0, // Changed from null to 0.0
            subTotal: order.totalPrice.toDouble(), // Added subtotal
            tax: 0.0, // Changed from null to 0.0
            discount: 0.0, // Changed from null to 0.0
            serviceCharge: 0.0 // Changed from null to 0.0
            );

        final response = await orderRemoteDatasource.createOrder(orderRequest);
        if (response['success'] as bool) {
          await ProductLocalDatasource.instance
              .updateIsSyncOrderById(order.id!);
        }
      }

      emit(const SyncOrderState.successCloseChasier());
    });
  }
}
