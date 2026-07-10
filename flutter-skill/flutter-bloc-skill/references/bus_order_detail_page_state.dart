part of 'bus_order_detail_page_bloc.dart';

/// 公車訂單詳情頁面狀態。
class BusOrderDetailPageState extends Equatable {
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

  @override
  List<Object?> get props => [
        busOrderId,
        date,
        displayDate,
        unitName,
        records,
      ];
}
