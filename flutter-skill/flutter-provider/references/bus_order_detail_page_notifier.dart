import 'package:flutter/foundation.dart';
import 'package:flutter_project_base/core/network/async_result.dart';
import 'package:flutter_project_base/data/models/bus/bus_order_form.dart';
import 'package:flutter_project_base/data/repository/order/order_repository.dart';

part 'bus_order_detail_page_state.dart';

/// 公車訂單詳情頁面的狀態管理。
///
/// 對應原 BLoC 版本的 [BusOrderDetailPageBloc]，
/// 以 [ChangeNotifier] 取代 Bloc，事件改為直接呼叫 method。
class BusOrderDetailPageNotifier extends ChangeNotifier {
  final OrderRepository _repository;

  BusOrderDetailPageNotifier(this._repository);

  /// 頁面狀態；沿用 BLoC 的 flat state 慣例，所有欄位收在單一 immutable class。
  ///
  /// 只 expose getter，不 expose setter，外部無法直接賦值，
  /// 只能透過 method 觸發狀態變更並 [notifyListeners]。
  BusOrderDetailPageState _state = const BusOrderDetailPageState();
  BusOrderDetailPageState get state => _state;

  /// 頁面啟動，傳入訂單 ID 與日期開始載入資料。
  ///
  /// 對應原 BLoC 的 `_onStarted`。
  Future<void> onStarted({
    required String busOrderId,
    required String date,
    required String displayDate,
    required String unitName,
  }) async {
    _state = _state.copyWith(
      busOrderId: busOrderId,
      date: date,
      displayDate: displayDate,
      unitName: unitName,
      records: _state.records.loading(),
    );
    notifyListeners();

    try {
      final records = await _repository.fetchBusOrderRecords(
        busOrderId: busOrderId,
        date: date,
      );
      _state = _state.copyWith(records: _state.records.setSuccess(data: records));
    } catch (e) {
      _state = _state.copyWith(
        records: _state.records.setError(error: e.toString()),
      );
    }
    notifyListeners();
  }

  /// 刷新資料。
  ///
  /// 對應原 BLoC 的 `_onRefresh`。keepData: true，refresh 期間畫面仍可顯示舊資料。
  Future<void> onRefresh() async {
    _state = _state.copyWith(records: _state.records.loading(keepData: true));
    notifyListeners();

    try {
      // 重新拉取最新訂單紀錄
      final records = await _repository.fetchBusOrderRecords(
        busOrderId: _state.busOrderId,
        date: _state.date,
      );
      _state = _state.copyWith(records: _state.records.setSuccess(data: records));
    } catch (e) {
      _state = _state.copyWith(
        records: _state.records.setError(error: e.toString(), keepData: true),
      );
    }
    notifyListeners();
  }

  /// 刪除指定的訂單紀錄。
  ///
  /// 對應原 BLoC 的 `_onDelete`。回傳是否成功，
  /// 讓呼叫端可直接依結果做導航或提示（取代 BlocListener 的一次性 side effect）。
  Future<bool> onDelete(String recordId) async {
    try {
      await _repository.deleteBusOrderRecord(recordId);

      // 刪除後重新拉取最新紀錄
      final records = await _repository.fetchBusOrderRecords(
        busOrderId: _state.busOrderId,
        date: _state.date,
      );
      _state = _state.copyWith(
        records: _state.records.setSuccess(data: records, message: '已刪除紀錄'),
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        records: _state.records.setError(error: e.toString(), keepData: true),
      );
      notifyListeners();
      return false;
    }
  }
}
