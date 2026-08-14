part of 'bus_order_detail_page_notifier.dart';

/// 公車訂單詳情頁面狀態。
///
/// 沿用 BLoC 的 flat state 慣例：單一 immutable class，所有欄位 final。
/// 因為 Notifier 靠 [ChangeNotifier.notifyListeners] 主動通知，
/// 不靠物件相等性判斷是否重建，故不需繼承 Equatable。
class BusOrderDetailPageState {
  final String busOrderId;
  final String date;

  /// 格式化後顯示用的日期，例如「2026/05/18」。
  final String displayDate;
  final String unitName;

  /// 訂單紀錄列表的非同步狀態（idle / loading / success / failure）。
  final AsyncResult<List<BusOrderFormData>, String> records;

  const BusOrderDetailPageState({
    this.busOrderId = '',
    this.date = '',
    this.displayDate = '',
    this.unitName = '',
    this.records = const AsyncResult.idle(),
  });

  BusOrderDetailPageState copyWith({
    String? busOrderId,
    String? date,
    String? displayDate,
    String? unitName,
    AsyncResult<List<BusOrderFormData>, String>? records,
  }) {
    return BusOrderDetailPageState(
      busOrderId: busOrderId ?? this.busOrderId,
      date: date ?? this.date,
      displayDate: displayDate ?? this.displayDate,
      unitName: unitName ?? this.unitName,
      records: records ?? this.records,
    );
  }
}
