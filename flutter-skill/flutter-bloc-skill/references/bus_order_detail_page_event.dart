part of 'bus_order_detail_page_bloc.dart';

/// 公車訂單詳情頁面事件基底類別。
sealed class BusOrderDetailPageEvent {
  const BusOrderDetailPageEvent();

}

/// 頁面啟動，傳入訂單 ID 與日期開始載入資料。
class BusOrderDetailStartedEvent extends BusOrderDetailPageEvent {
  final String busOrderId;
  final String date;
  final String displayDate;
  final String unitName;

  const BusOrderDetailStartedEvent({
    required this.busOrderId,
    required this.date,
    required this.displayDate,
    required this.unitName,
  });

  @override
  List<Object?> get props => [busOrderId, date, displayDate, unitName];
}

/// 重新整理訂單紀錄。
class BusOrderDetailRefreshEvent extends BusOrderDetailPageEvent {
  const BusOrderDetailRefreshEvent();
}

/// 刪除指定的訂單紀錄。
class BusOrderDetailDeleteEvent extends BusOrderDetailPageEvent {
  final String recordId;

  const BusOrderDetailDeleteEvent({required this.recordId});

  @override
  List<Object?> get props => [recordId];
}
