import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_project_base/core/network/async_result.dart';
import 'package:flutter_project_base/data/models/bus/bus_order_form.dart';
import 'package:flutter_project_base/data/repository/order/order_repository.dart';

part 'bus_order_detail_page_event.dart';
part 'bus_order_detail_page_state.dart';

class BusOrderDetailPageBloc
    extends Bloc<BusOrderDetailPageEvent, BusOrderDetailPageState> {
  final OrderRepository _repository;

  BusOrderDetailPageBloc(this._repository)
      : super(const BusOrderDetailPageState()) {
    on<BusOrderDetailStartedEvent>(_onStarted);
    on<BusOrderDetailRefreshEvent>(_onRefresh);
    on<BusOrderDetailDeleteEvent>(_onDelete);
  }

  FutureOr<void> _onStarted(
    BusOrderDetailStartedEvent event,
    Emitter<BusOrderDetailPageState> emit,
  ) async {
    emit(state.copyWith(
      busOrderId: event.busOrderId,
      date: event.date,
      displayDate: event.displayDate,
      unitName: event.unitName,
      records: state.records.loading(),
    ));

    try {
      final records = await _repository.fetchBusOrderRecords(
        busOrderId: event.busOrderId,
        date: event.date,
      );
      emit(state.copyWith(records: state.records.setSuccess(data: records)));
    } catch (e) {
      emit(state.copyWith(
        records: state.records.setError(error: e.toString()),
      ));
    }
  }

  /// 刷新資料
  FutureOr<void> _onRefresh(
    BusOrderDetailRefreshEvent event,
    Emitter<BusOrderDetailPageState> emit,
  ) async {
    // keepData: true，refresh 期間畫面仍可顯示舊資料
    emit(state.copyWith(records: state.records.loading(keepData: true)));

    try {
      // 重新拉取最新訂單紀錄
      final records = await _repository.fetchBusOrderRecords(
        busOrderId: state.busOrderId,
        date: state.date,
      );
      emit(state.copyWith(records: state.records.setSuccess(data: records)));
    } catch (e) {
      emit(state.copyWith(
        records: state.records.setError(error: e.toString(), keepData: true),
      ));
    }
  }

  FutureOr<void> _onDelete(
    BusOrderDetailDeleteEvent event,
    Emitter<BusOrderDetailPageState> emit,
  ) async {
    try {
      await _repository.deleteBusOrderRecord(event.recordId);

      // 刪除後重新拉取最新紀錄
      final records = await _repository.fetchBusOrderRecords(
        busOrderId: state.busOrderId,
        date: state.date,
      );
      emit(state.copyWith(
        records: state.records.setSuccess(data: records, message: '已刪除紀錄'),
      ));
    } catch (e) {
      emit(state.copyWith(
        records: state.records.setError(error: e.toString(), keepData: true),
      ));
    }
  }
}
