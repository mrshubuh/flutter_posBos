import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos/core/components/spaces.dart';
import 'package:flutter_pos/core/extensions/build_context_ext.dart';
import 'package:flutter_pos/presentation/home/bloc/product/product_bloc.dart';
import 'package:flutter_pos/presentation/setting/bloc/sync_order/sync_order_bloc.dart';

import '../../../core/constants/colors.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/datasources/product_local_datasource.dart';
import '../../home/bloc/category/category_bloc.dart';

class SyncDataPage extends StatefulWidget {
  const SyncDataPage({super.key});

  @override
  State<SyncDataPage> createState() => _SyncDataPageState();
}

class _SyncDataPageState extends State<SyncDataPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Data'),
        centerTitle: true,
      ),
      //textfield untuk input server key
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          //button sync data product
          BlocConsumer<ProductBloc, ProductState>(
            listener: (context, state) {
              state.maybeMap(
                orElse: () {},
                success: (_) async {
                  await ProductLocalDatasource.instance.removeAllProduct();
                  await ProductLocalDatasource.instance
                      .insertAllProduct(_.products.toList());
                  SnackbarUtils(
                    text: 'Sync data product success',
                    backgroundColor: AppColors.primary,
                  ).showSuccessSnackBar(context);
                },
              );
            },
            builder: (context, state) {
              return state.maybeWhen(
                orElse: () {
                  return ElevatedButton(
                      onPressed: () {
                        context
                            .read<ProductBloc>()
                            .add(const ProductEvent.fetch());
                      },
                      child: const Text('Sync Data Product'));
                },
                loading: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );
            },
          ),
          const SpaceHeight(20),
          //button sync categories
          BlocConsumer<CategoryBloc, CategoryState>(
            listener: (context, state) {
              state.maybeMap(
                orElse: () {},
                loaded: (data) async {
                  await ProductLocalDatasource.instance.removeAllCategories();
                  await ProductLocalDatasource.instance
                      .insertAllCategories(data.categories);
                  context
                      .read<CategoryBloc>()
                      .add(const CategoryEvent.getCategoriesLocal());
                  context.pop();
                  SnackbarUtils(
                    text: 'Sync data categories success',
                    backgroundColor: AppColors.primary,
                  ).showSuccessSnackBar(context);
                },
              );
            },
            builder: (context, state) {
              return state.maybeWhen(
                orElse: () {
                  return ElevatedButton(
                      onPressed: () {
                        context
                            .read<CategoryBloc>()
                            .add(const CategoryEvent.getCategories());
                      },
                      child: const Text('Sync Data Categories'));
                },
                loading: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );
            },
          ),
          const SpaceHeight(20),
          //button sync data order
          BlocConsumer<SyncOrderBloc, SyncOrderState>(
            listener: (context, state) {
              state.maybeMap(
                orElse: () {},
                success: (_) async {
                  // await ProductLocalDatasource.instance.removeAllProduct();
                  // await ProductLocalDatasource.instance
                  //     .insertAllProduct(_.products.toList());
                  SnackbarUtils(
                    text: 'Sync data orders success',
                    backgroundColor: AppColors.primary,
                  ).showSuccessSnackBar(context);
                },
              );
            },
            builder: (context, state) {
              return state.maybeWhen(
                orElse: () {
                  return ElevatedButton(
                      onPressed: () {
                        context
                            .read<SyncOrderBloc>()
                            .add(const SyncOrderEvent.sendOrder());
                      },
                      child: const Text('Sync Data Orders'));
                },
                loading: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
