import 'package:bloc/bloc.dart';
import 'package:flutter_pos/data/datasources/product_local_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_pos/data/datasources/product_remote_datasource.dart';

import '../../../../data/models/response/category_response_model.dart';

part 'category_bloc.freezed.dart';
part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final ProductRemoteDatasource productRemoteDatasource;
  List<Category> categories = [];
  CategoryBloc(
    this.productRemoteDatasource,
  ) : super(const _Initial()) {
    on<_GetCategories>((event, emit) async {
      emit(const _Loading());
      try {
        final result = await productRemoteDatasource.getCategories();
        await result.fold(
          (l) async {
            if (!emit.isDone) emit(_Error(l));
          },
          (r) async {
            if (r.data != null && r.data!.isNotEmpty) {
              // Save categories to local database
              await ProductLocalDatasource.instance.insertAllCategories(r.data!);
              categories = r.data!;
              if (!emit.isDone) emit(_Loaded(categories));
            } else {
              // If no categories from API, try to load from local
              final localCategories = await ProductLocalDatasource.instance.getAllCategories();
              categories = localCategories;
              if (!emit.isDone) emit(_LoadedLocal(categories));
            }
          },
        );
      } catch (e) {
        if (!emit.isDone) emit(_Error(e.toString()));
      }
    });

    on<_GetCategoriesLocal>((event, emit) async {
      emit(const _Loading());
      try {
        final localCategories = await ProductLocalDatasource.instance.getAllCategories();
        if (localCategories.isNotEmpty) {
          categories = localCategories;
          if (!emit.isDone) emit(_LoadedLocal(categories));
        } else {
          // If no local categories, fetch from remote
          add(const CategoryEvent.getCategories());
        }
      } catch (e) {
        // If any error occurs, try to fetch from remote
        add(const CategoryEvent.getCategories());
      }
    });
  }


}
