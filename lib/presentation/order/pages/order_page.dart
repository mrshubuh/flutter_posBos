import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

import 'package:flutter_pos/core/extensions/build_context_ext.dart';
import 'package:flutter_pos/core/components/menu_button.dart';
import 'package:flutter_pos/core/components/spaces.dart';
import 'package:flutter_pos/core/utils/snackbar_utils.dart';
import 'package:flutter_pos/core/utils/connectivity_utils.dart';
import 'package:flutter_pos/core/assets/assets.gen.dart';

import 'package:flutter_pos/data/models/order_item_model.dart';
import 'package:flutter_pos/data/models/request/order_request_model.dart';
import 'package:flutter_pos/data/models/request/delivery_request_model.dart';
import 'package:flutter_pos/data/models/response/discount_response_model.dart';
import 'package:flutter_pos/data/datasources/order_local_datasource.dart';
import 'package:flutter_pos/data/datasources/delivery_remote_datasource.dart';
import 'package:flutter_pos/data/datasources/auth_local_datasource.dart';

import 'package:flutter_pos/presentation/home/bloc/checkout/checkout_bloc.dart';
import 'package:flutter_pos/presentation/home/pages/dashboard_page.dart';
import 'package:flutter_pos/presentation/setting/bloc/discount/bloc/discount_bloc.dart';
import 'package:flutter_pos/presentation/order/pages/delivery/delivery_form_dialog.dart';
import 'package:flutter_pos/presentation/order/pages/delivery/delivery_map_page.dart';
import 'package:flutter_pos/presentation/order/bloc/order/order_bloc.dart';
import 'package:flutter_pos/presentation/order/widgets/order_card.dart';
import 'package:flutter_pos/presentation/order/widgets/payment_cash_dialog.dart';
import 'package:flutter_pos/presentation/order/widgets/payment_qris_dialog.dart';
import 'package:flutter_pos/presentation/order/widgets/process_button.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final ValueNotifier<int> indexValue = ValueNotifier(0);
  final TextEditingController orderNameController = TextEditingController();
  final TextEditingController tableNumberController = TextEditingController();
  bool _isDeliveryLoading = false;

  List<OrderItem> orders = [];
  bool isOnline = true;
  bool hasOfflineOrders = false;

  int totalPrice = 0;
  int calculateTotalPrice(List<OrderItem> orders) {
    return orders.fold(
        0,
        (previousValue, element) =>
            previousValue + element.product.price * element.quantity);
  }

  LatLng? deliveryPoint;
  String? deliveryAddress;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _checkOfflineOrders();
  }

  Future<void> _checkConnectivity() async {
    final connected = await ConnectivityUtils.isConnected();
    setState(() {
      isOnline = connected;
    });
  }

  Future<void> _checkOfflineOrders() async {
    final hasOffline = await OrderLocalDatasource.instance.hasOfflineOrders();
    setState(() {
      hasOfflineOrders = hasOffline;
    });
  }

  Future<void> _showOpenBillDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Open Bill'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Table Number',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  keyboardType: TextInputType.number,
                  controller: tableNumberController,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Order Name',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  controller: orderNameController,
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            BlocBuilder<CheckoutBloc, CheckoutState>(
              builder: (context, state) {
                return state.maybeWhen(
                  orElse: () => const SizedBox.shrink(),
                  success: (data, qty, total, draftName) {
                    return TextButton(
                      onPressed: () async {
                        if (tableNumberController.text.isEmpty ||
                            orderNameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in all fields'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        try {
                          await AuthLocalDatasource().getAuthData();
                          if (!mounted) return;

                          context.read<CheckoutBloc>().add(
                                CheckoutEvent.saveDraftOrder(
                                  int.tryParse(tableNumberController.text) ?? 0,
                                  orderNameController.text,
                                ),
                              );

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Order saved successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Error saving order: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Save'),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final paddingHorizontal = EdgeInsets.symmetric(
      horizontal: isSmallScreen ? 12.0 : 16.0,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.push(const DashboardPage()),
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: Text(
          'Order Detail',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 16 : 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 6 : 8,
              vertical: 2,
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isOnline ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOnline ? Icons.wifi : Icons.wifi_off,
                  color: Colors.white,
                  size: isSmallScreen ? 12 : 14,
                ),
                const SizedBox(width: 4),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 10 : 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (hasOfflineOrders)
            IconButton(
              iconSize: isSmallScreen ? 20 : 24,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                context.read<OrderBloc>().add(
                      const OrderEvent.syncOfflineOrders(),
                    );
              },
              icon: const Icon(Icons.sync),
              tooltip: 'Sinkronisasi Order Offline',
            ),
          IconButton(
            iconSize: isSmallScreen ? 20 : 24,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _showOpenBillDialog(context),
            icon: const Icon(Icons.save_as_outlined),
            tooltip: 'Open Bill',
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
        ],
      ),
      body: Column(
        children: [
          BlocBuilder<OrderBloc, OrderState>(
            builder: (context, state) {
              return state.maybeWhen(
                syncing: () => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.blue,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Sinkronisasi Order Offline...',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                error: (message) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.red,
                  child: Text(
                    'Error: $message',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
          Expanded(
            child: BlocBuilder<CheckoutBloc, CheckoutState>(
              builder: (context, state) {
                return state.maybeWhen(orElse: () {
                  return const Center(
                    child: Text('No Data'),
                  );
                }, success: (data, qty, total, draftName) {
                  if (data.isEmpty) {
                    return const Center(
                      child: Text('No Data'),
                    );
                  }

                  totalPrice = total;
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    itemCount: data.length,
                    separatorBuilder: (context, index) =>
                        const SpaceHeight(20.0),
                    itemBuilder: (context, index) => OrderCard(
                      padding: paddingHorizontal,
                      data: data[index],
                      onDeleteTap: () {
                        context.read<CheckoutBloc>().add(
                              CheckoutEvent.removeProduct(data[index].product),
                            );
                      },
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.only(top: 8.0),
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BlocBuilder<CheckoutBloc, CheckoutState>(
                  builder: (context, state) {
                    return state.maybeWhen(
                      orElse: () {
                        return const SizedBox.shrink();
                      },
                      success: (data, qty, total, draftName) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: MenuButton(
                                    iconPath: Assets.icons.cash.path,
                                    label: 'Discount',
                                    isActive: false,
                                    onPressed: () async {
                                      context.read<DiscountBloc>().add(
                                            const DiscountEvent
                                                .getTodayDiscounts(),
                                          );

                                      final result = await showDialog<
                                          DiscountResponseModel>(
                                        context: context,
                                        builder: (context) {
                                          return BlocBuilder<DiscountBloc,
                                              DiscountState>(
                                            builder: (context, state) {
                                              return state.maybeWhen(
                                                loading: () =>
                                                    const AlertDialog(
                                                  title: Text('Loading...'),
                                                  content: Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                                ),
                                                loaded: (discounts) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'Pilih Diskon'),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      if (discounts.isEmpty)
                                                        const Text(
                                                            'Tidak ada diskon tersedia hari ini'),
                                                      ...discounts.map(
                                                          (discount) =>
                                                              ListTile(
                                                                title: Text(
                                                                    discount
                                                                        .name),
                                                                subtitle: Text(
                                                                    '${discount.value}% - ${discount.description}'),
                                                                onTap: () =>
                                                                    Navigator.pop(
                                                                        context,
                                                                        discount),
                                                              )),
                                                      const Divider(),
                                                      ListTile(
                                                        title: const Text(
                                                            'Diskon Manual'),
                                                        subtitle: const Text(
                                                            'Masukkan persentase diskon'),
                                                        onTap: () async {
                                                          Navigator.pop(
                                                              context);
                                                          final manual =
                                                              await showDialog<
                                                                  double>(
                                                            context: context,
                                                            builder: (context) {
                                                              double value = 0;
                                                              return AlertDialog(
                                                                title: const Text(
                                                                    'Diskon Manual (%)'),
                                                                content:
                                                                    TextField(
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  onChanged:
                                                                      (val) {
                                                                    value =
                                                                        double.tryParse(val) ??
                                                                            0;
                                                                  },
                                                                  decoration:
                                                                      const InputDecoration(
                                                                          hintText:
                                                                              'Masukkan persentase'),
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            context,
                                                                            value),
                                                                    child:
                                                                        const Text(
                                                                            'OK'),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                          if (manual != null &&
                                                              manual > 0) {
                                                            context
                                                                .read<
                                                                    OrderBloc>()
                                                                .add(
                                                                  OrderEvent
                                                                      .applyManualDiscount(
                                                                          manual
                                                                              .toInt()),
                                                                );
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                error: (message) => AlertDialog(
                                                  title: const Text('Error'),
                                                  content: Text(message),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child: const Text('OK'),
                                                    ),
                                                  ],
                                                ),
                                                orElse: () => const AlertDialog(
                                                  title: Text('Loading...'),
                                                  content: Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );

                                      if (result != null) {
                                        context.read<OrderBloc>().add(
                                              OrderEvent.applyAutoDiscount(
                                                  result.validDays,
                                                  result.value.toInt()),
                                            );
                                      }
                                    },
                                  ),
                                ),
                                const SpaceWidth(16.0),
                                Flexible(
                                  child: MenuButton(
                                    iconPath: Assets.icons.cash.path,
                                    label: 'Tax',
                                    isActive: false,
                                    onPressed: () {},
                                  ),
                                ),
                                const SpaceWidth(16.0),
                                Flexible(
                                  child: MenuButton(
                                    iconPath: Assets.icons.cash.path,
                                    label: 'Service Charge',
                                    isActive: false,
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                            const SpaceHeight(20.0),
                            ValueListenableBuilder(
                              valueListenable: indexValue,
                              builder: (context, value, _) => Row(
                                children: [
                                  Flexible(
                                    child: MenuButton(
                                      iconPath: Assets.icons.cash.path,
                                      label: 'CASH',
                                      isActive: value == 1,
                                      onPressed: () {
                                        indexValue.value = 1;
                                        context.read<OrderBloc>().add(
                                            OrderEvent.addPaymentMethod(
                                                'Tunai', data, draftName));
                                      },
                                    ),
                                  ),
                                  const SpaceWidth(16.0),
                                  Flexible(
                                    child: MenuButton(
                                      iconPath: Assets.icons.qrCode.path,
                                      label: 'QR',
                                      isActive: value == 2,
                                      onPressed: () {
                                        indexValue.value = 2;
                                        context.read<OrderBloc>().add(
                                            OrderEvent.addPaymentMethod(
                                                'QRIS', data, draftName));
                                      },
                                    ),
                                  ),
                                  const SpaceWidth(16.0),
                                  Flexible(
                                    child: MenuButton(
                                      iconPath: Assets.icons.debit.path,
                                      label: 'TRANSFER',
                                      isActive: value == 3,
                                      onPressed: () {
                                        indexValue.value = 3;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SpaceWidth(16.0),
                            const SizedBox(height: 12.0),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: MenuButton(
                                      iconPath: Assets.icons.cash.path,
                                      label: 'Pilih Lokasi',
                                      isActive: false,
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const DeliveryMapPage(),
                                          ),
                                        );
                                        if (result != null &&
                                            result is LatLng) {
                                          setState(() {
                                            deliveryPoint = result;
                                            deliveryAddress = null;
                                          });
                                          // Ambil alamat dari koordinat
                                          try {
                                            List<Placemark> placemarks =
                                                await placemarkFromCoordinates(
                                                    result.latitude,
                                                    result.longitude);
                                            if (placemarks.isNotEmpty) {
                                              final placemark =
                                                  placemarks.first;
                                              String address = '';
                                              if (placemark.street != null &&
                                                  placemark
                                                      .street!.isNotEmpty) {
                                                address += placemark.street!;
                                              }
                                              if (placemark.subLocality !=
                                                      null &&
                                                  placemark.subLocality!
                                                      .isNotEmpty) {
                                                address +=
                                                    ', ${placemark.subLocality!}';
                                              }
                                              if (placemark.locality != null &&
                                                  placemark
                                                      .locality!.isNotEmpty) {
                                                address +=
                                                    ', ${placemark.locality!}';
                                              }
                                              if (placemark
                                                          .administrativeArea !=
                                                      null &&
                                                  placemark.administrativeArea!
                                                      .isNotEmpty) {
                                                address +=
                                                    ', ${placemark.administrativeArea!}';
                                              }
                                              if (placemark.postalCode !=
                                                      null &&
                                                  placemark
                                                      .postalCode!.isNotEmpty) {
                                                address +=
                                                    ', ${placemark.postalCode!}';
                                              }
                                              if (placemark.country != null &&
                                                  placemark
                                                      .country!.isNotEmpty) {
                                                address +=
                                                    ', ${placemark.country!}';
                                              }
                                              setState(() {
                                                deliveryAddress = address;
                                              });
                                            } else {
                                              setState(() {
                                                deliveryAddress =
                                                    '${result.latitude}, ${result.longitude}';
                                              });
                                            }
                                          } catch (e) {
                                            setState(() {
                                              deliveryAddress =
                                                  '${result.latitude}, ${result.longitude}';
                                            });
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                  const SpaceWidth(12.0),
                                  Flexible(
                                    child: _isDeliveryLoading
                                        ? const Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.blue),
                                              ),
                                            ),
                                          )
                                        : MenuButton(
                                            iconPath: Assets.icons.cash.path,
                                            label: 'Delivery',
                                            isActive: false,
                                            onPressed: () async {
                                              if (deliveryPoint == null) {
                                                // SnackbarUtils(
                                                //     text:
                                                //         'Pilih lokasi pengiriman terlebih dahulu',
                                                //     backgroundColor: Colors.orange);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Pilih lokasi pengiriman terlebih dahulu'),
                                                    backgroundColor:
                                                        Colors.orange,
                                                  ),
                                                );
                                                return;
                                              }

                                              if (_isDeliveryLoading) return;

                                              setState(() {
                                                _isDeliveryLoading = true;
                                              });

                                              try {
                                                final orderId = DateTime.now()
                                                    .millisecondsSinceEpoch;

                                                final deliveryRequest =
                                                    await showDialog<
                                                        DeliveryRequestModel>(
                                                  context: context,
                                                  builder: (context) =>
                                                      DeliveryFormDialog(
                                                    orderId: orderId,
                                                    selectedLocation:
                                                        deliveryPoint,
                                                  ),
                                                );

                                                if (deliveryRequest != null) {
                                                  final response =
                                                      await DeliveryRemoteDatasource()
                                                          .createDelivery(
                                                              deliveryRequest);

                                                  if (!mounted) return;

                                                  setState(() {
                                                    deliveryPoint = null;
                                                  });

                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Pengiriman berhasil dibuat: ${response['data']['tracking_number']}',
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      backgroundColor:
                                                          Colors.green,
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      duration: const Duration(
                                                          seconds: 3),
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                if (!mounted) return;
                                                SnackbarUtils(
                                                        text:
                                                            'Gagal membuat pengiriman',
                                                        backgroundColor:
                                                            Colors.red)
                                                    .showErrorSnackBar(context);
                                                // ScaffoldMessenger.of(context)
                                                //     .showSnackBar(
                                                //   SnackBar(
                                                //     content: Text(
                                                //       'Gagal membuat pengiriman: ${e.toString()}',
                                                //       style: const TextStyle(
                                                //           color: Colors.white),
                                                //     ),
                                                //     backgroundColor: Colors.red,
                                                //     behavior:
                                                //         SnackBarBehavior.floating,
                                                //     duration:
                                                //         const Duration(seconds: 4),
                                                //   ),
                                                // );
                                              } finally {
                                                if (mounted) {
                                                  setState(() {
                                                    _isDeliveryLoading = false;
                                                  });
                                                }
                                              }
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            // if (deliveryPoint != null)
                            //   Padding(
                            //     padding: const EdgeInsets.only(top: 8.0),
                            //     child: Text(
                            //       deliveryAddress != null
                            //           ? 'Lokasi Pengiriman: $deliveryAddress'
                            //           : 'Lokasi Pengiriman: ${deliveryPoint!.latitude}, ${deliveryPoint!.longitude}',
                            //       style: const TextStyle(
                            //           color: Colors.blue,
                            //           fontWeight: FontWeight.bold),
                            //     ),
                            //   ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SpaceHeight(20.0),
                ProcessButton(
                  price: 0,
                  onPressed: () async {
                    final isConnected = await ConnectivityUtils.isConnected();

                    if (!isConnected) {
                      final currentState = context.read<OrderBloc>().state;
                      final successData = currentState.maybeWhen(
                        orElse: () => null,
                      );
                      if (successData != null) {
                        final orderRequest = OrderRequestModel(
                          transactionTime: DateTime.now().toIso8601String(),
                          kasirId: successData['idKasir'] as int,
                          totalPrice:
                              (successData['totalPrice'] as int).toDouble(),
                          totalItem: successData['totalQuantity'] as int,
                          paymentMethod: successData['paymentMethod'] as String,
                          paymentAmount:
                              (successData['totalPrice'] as int).toDouble(),
                          subTotal:
                              (successData['totalPrice'] as int).toDouble(),
                          tax: 0.0,
                          discount: 0.0,
                          serviceCharge: 0.0,
                          orderItems:
                              (successData['products'] as List<OrderItem>)
                                  .map((item) => OrderItemModel(
                                        productId: item.product.id!,
                                        quantity: item.quantity,
                                        totalPrice:
                                            (item.product.price * item.quantity)
                                                .toDouble(),
                                      ))
                                  .toList(),
                        );

                        await OrderLocalDatasource.instance.saveOfflineOrder(
                          orderRequest,
                          successData['customerName'] as String,
                          0,
                        );

                        setState(() {
                          hasOfflineOrders = true;
                        });

                        SnackbarUtils(
                          text: 'Order disimpan offline',
                          backgroundColor: Colors.orange,
                        ).showSuccessSnackBar(context);
                      }
                      return;
                    }

                    if (indexValue.value == 0) {
                    } else if (indexValue.value == 1) {
                      showDialog(
                        context: context,
                        builder: (context) => PaymentCashDialog(
                          price: totalPrice,
                        ),
                      );
                    } else if (indexValue.value == 2) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => PaymentQrisDialog(
                          price: totalPrice,
                        ),
                      );
                    }
                  },
                ),
                BlocBuilder<OrderBloc, OrderState>(
                  builder: (context, state) {
                    return state.maybeWhen(
                      discountApplied: (discount, totalAfterDiscount) =>
                          Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Diskon: $discount% | Total setelah diskon: Rp$totalAfterDiscount',
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
