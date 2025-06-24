import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos/core/constants/colors.dart';
import 'package:flutter_pos/core/utils/snackbar_utils.dart';
import 'package:flutter_pos/presentation/home/bloc/category/category_bloc.dart';
import 'package:flutter_pos/presentation/home/bloc/product/product_bloc.dart';
import 'package:flutter_pos/presentation/setting/bloc/sync_order/sync_order_bloc.dart';

import '../../../core/utils/connectivity_utils.dart';

class SyncDataPage extends StatefulWidget {
  const SyncDataPage({super.key});

  @override
  State<SyncDataPage> createState() => _SyncDataPageState();
}

class _SyncDataPageState extends State<SyncDataPage> {
  bool isOnline = true;
  @override
  void initState() {
    _checkConnectivity();
    super.initState();
  }

  Future<void> _checkConnectivity() async {
    final connected = await ConnectivityUtils.isConnected();
    setState(() {
      isOnline = connected;
    });
  }

  Future<void> _syncAllData() async {
    if (!mounted) return;

    final productBloc = context.read<ProductBloc>();
    final categoryBloc = context.read<CategoryBloc>();

    // Fetch products
    productBloc.add(const ProductEvent.fetch());

    // Fetch categories
    categoryBloc.add(const CategoryEvent.getCategories());

    if (mounted) {
      SnackbarUtils(
        text: 'Sync started. Please wait...',
        backgroundColor: AppColors.primary,
      ).showSuccessSnackBar(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Data'),
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
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // GET ALL Button
            BlocConsumer<ProductBloc, ProductState>(
              listener: (context, state) {
                state.maybeMap(
                  success: (_) {
                    if (mounted) {
                      SnackbarUtils(
                        text: 'All data synced successfully',
                        backgroundColor: Colors.green,
                      ).showSuccessSnackBar(context);
                    }
                  },
                  error: (error) {
                    if (mounted) {
                      SnackbarUtils(
                        text: 'Failed to sync products',
                        backgroundColor: Colors.red,
                      ).showErrorSnackBar(context);
                    }
                  },
                  orElse: () {},
                );
              },
              builder: (context, state) {
                return state.maybeWhen(
                  loading: () => const CircularProgressIndicator(),
                  orElse: () => ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('GET ALL DATA'),
                    onPressed: _syncAllData,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // POST Orders Button
            BlocConsumer<SyncOrderBloc, SyncOrderState>(
              listener: (context, state) {
                state.maybeMap(
                  success: (_) {
                    if (mounted) {
                      SnackbarUtils(
                        text: 'Orders synced successfully',
                        backgroundColor: Colors.green,
                      ).showSuccessSnackBar(context);
                    }
                  },
                  error: (error) {
                    if (mounted) {
                      SnackbarUtils(
                        text: 'Failed to sync orders',
                        backgroundColor: Colors.red,
                      ).showErrorSnackBar(context);
                    }
                  },
                  orElse: () {},
                );
              },
              builder: (context, state) {
                return state.maybeWhen(
                  loading: () => const CircularProgressIndicator(),
                  orElse: () => ElevatedButton.icon(
                    icon: const Icon(Icons.upload),
                    label: const Text('SYNC ORDERS'),
                    onPressed: () {
                      context
                          .read<SyncOrderBloc>()
                          .add(const SyncOrderEvent.sendOrder());
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
