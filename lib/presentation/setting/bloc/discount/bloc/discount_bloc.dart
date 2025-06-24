import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_pos/data/datasources/discount_remote_datasource.dart';
import 'package:flutter_pos/data/models/response/discount_response_model.dart';

part 'discount_event.dart';
part 'discount_state.dart';
part 'discount_bloc.freezed.dart';

class DiscountBloc extends Bloc<DiscountEvent, DiscountState> {
  final DiscountRemoteDatasource discountRemoteDatasource;

  DiscountBloc(this.discountRemoteDatasource) : super(const _Initial()) {
    on<_GetDiscounts>((event, emit) async {
      emit(const _Loading());
      try {
        final discounts = await discountRemoteDatasource.getDiscounts();
        emit(_Loaded(discounts));
      } catch (e) {
        emit(_Error(e.toString()));
      }
    });

    on<_GetTodayDiscounts>((event, emit) async {
      emit(const _Loading());
      try {
        final discounts = await discountRemoteDatasource.getTodayDiscounts();
        emit(_Loaded(discounts));
      } catch (e) {
        emit(_Error(e.toString()));
      }
    });

    on<_GetDiscountById>((event, emit) async {
      emit(const _Loading());
      try {
        final discount =
            await discountRemoteDatasource.getDiscountById(event.id);
        emit(_LoadedDetail(discount));
      } catch (e) {
        emit(_Error(e.toString()));
      }
    });
  }
}
