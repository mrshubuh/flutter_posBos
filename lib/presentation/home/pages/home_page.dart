import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos/core/extensions/build_context_ext.dart';
import 'package:flutter_pos/presentation/draft_order/pages/draft_order_page.dart';
import 'package:flutter_pos/presentation/home/bloc/product/product_bloc.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/assets/assets.gen.dart';
import '../../../core/components/menu_button.dart';
import '../../../core/components/search_input.dart';
import '../../../core/components/spaces.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../bloc/category/category_bloc.dart';
import '../widgets/product_card.dart';
import '../widgets/product_empty.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final searchController = TextEditingController();
  final indexValue = ValueNotifier(0);
  int currentIndex = 0;

  @override
  void initState() {
    context.read<ProductBloc>().add(const ProductEvent.fetchLocal());
    context.read<CategoryBloc>().add(const CategoryEvent.getCategoriesLocal());
    AuthLocalDatasource().getPrinter().then((value) async {
      if (value.isNotEmpty) {
        await PrintBluetoothThermal.connect(macPrinterAddress: value);
      }
    });
    super.initState();
  }

  void onCategoryTap(int index, {String? categoryName}) {
    searchController.clear();
    currentIndex = index;
    if (index == 0) {
      context.read<ProductBloc>().add(const ProductEvent.fetchLocal());
    } else if (categoryName != null) {
      context.read<ProductBloc>().add(ProductEvent.fetchByCategory(categoryName));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Menu Cafe',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.push(const DraftOrderPage());
            },
            icon: const Icon(Icons.note_alt_rounded),
          ),
          const SpaceWidth(8)
        ],
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SearchInput(
            controller: searchController,
            onChanged: (value) {
              if (value.length > 3) {
                context
                    .read<ProductBloc>()
                    .add(ProductEvent.searchProduct(value));
              }
              if (value.isEmpty) {
                context
                    .read<ProductBloc>()
                    .add(const ProductEvent.fetchAllFromState());
              }
            },
          ),
          const SpaceHeight(16.0),
          BlocBuilder<CategoryBloc, CategoryState>(builder: (context, state) {
            return state.maybeWhen(
              orElse: () {
                return const SizedBox();
              },
              loading: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              error: (message) {
                return Center(
                  child: Text(message),
                );
              },
              loadedLocal: (categories) {
                return SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // All Categories Button
                      SizedBox(
                        height: 80,
                        width: 90,
                        child: MenuButton(
                          iconPath: Assets.icons.allCategories.path,
                          label: 'All',
                          isActive: currentIndex == 0,
                          onPressed: () => onCategoryTap(0),
                        ),
                      ),
                      const SpaceWidth(10.0),
                      // Dynamic Category Buttons
                      ...categories.map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: SizedBox(
                            height: 80,
                            width: 90,
                            child: MenuButton(
                              iconPath: Assets.icons.allCategories.path,
                              label: category.name,
                              isActive: currentIndex == category.id,
                              onPressed: () => onCategoryTap(category.id, categoryName: category.name),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
          // ValueListenableBuilder(
          //   valueListenable: indexValue,
          //   builder: (context, value, _) => Row(
          //     children: [
          //       MenuButton(
          //         iconPath: Assets.icons.allCategories.path,
          //         label: 'All',
          //         isActive: value == 0,
          //         onPressed: () => onCategoryTap(0),
          //       ),
          //       const SpaceWidth(10.0),
          //       MenuButton(
          //         iconPath: Assets.icons.drink.path,
          //         label: 'Drink',
          //         isActive: value == 1,
          //         onPressed: () => onCategoryTap(1),
          //       ),
          //       const SpaceWidth(10.0),
          //       MenuButton(
          //         iconPath: Assets.icons.food.path,
          //         label: 'Food',
          //         isActive: value == 2,
          //         onPressed: () => onCategoryTap(2),
          //       ),
          //       const SpaceWidth(10.0),
          //       MenuButton(
          //         iconPath: Assets.icons.snack.path,
          //         label: 'Snack',
          //         isActive: value == 3,
          //         onPressed: () => onCategoryTap(3),
          //       ),
          //     ],
          //   ),
          // ),
          const SpaceHeight(16.0),
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              return state.maybeWhen(orElse: () {
                return const SizedBox();
              }, loading: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }, error: (message) {
                return Center(
                  child: Text(message),
                );
              }, success: (products) {
                if (products.isEmpty) return const ProductEmpty();
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 0.75,
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemBuilder: (context, index) => ProductCard(
                    data: products[index],
                  ),
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
