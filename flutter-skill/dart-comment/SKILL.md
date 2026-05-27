---
name: dart-comment
description: Claude Code Skill — Dart/Flutter 中文註解規範，所有產生 Dart 程式碼的 Skill 都應參照此規範
---

# dart-comment

> Claude Code Skill — Dart/Flutter 中文註解規範，所有產生 Dart 程式碼的 Skill 都應參照此規範

---

## 這個 Skill 做什麼？

統一定義專案內 Dart 程式碼的註解風格，包含 Dart Doc（`///`）與 inline 註解（`//`）的使用時機與撰寫原則，語言為**中文**。

---

## 兩種註解格式

| 格式 | 用途 |
|------|------|
| `///` Dart Doc | 類別、方法、欄位的說明，出現在 IDE hover 提示 |
| `//` inline | 解釋邏輯、條件判斷、特殊處理 |

---

## Dart Doc（`///`）

### 何時加

- 每個 `class`
- 每個公開方法
- 語意不明顯的欄位（縮寫、業務術語）

### 何時不加

- 欄位名稱已完全自我說明（如 `final String name`）

### 格式

```dart
/// 一句話說明這個類別 / 方法 / 欄位的用途。
///
/// 補充說明（可選）。
```

---

## Inline 註解（`//`）

### 何時加

- 條件判斷的意圖
- 非同步操作的步驟說明
- 狀態轉換的原因
- 不直覺的業務邏輯
- TODO 事項

### 何時不加

- 程式碼本身已清楚表達意圖
- 不逐行翻譯程式碼

---

## BLoC 範例

### Event

```dart
/// 公車訂單詳情頁面事件基底類別。
sealed class BusOrderDetailPageEvent {
  const BusOrderDetailPageEvent();
}

/// 頁面啟動，傳入訂單 ID 與日期開始載入資料。
class BusOrderDetailStartedEvent extends BusOrderDetailPageEvent {
  final String busOrderId;
  final String date;
  const BusOrderDetailStartedEvent({required this.busOrderId, required this.date});
}

/// 刪除指定的訂單紀錄。
class BusOrderDetailDeleteEvent extends BusOrderDetailPageEvent {
  final String recordId;
  const BusOrderDetailDeleteEvent({required this.recordId});
}

/// 清除畫面上的 toast 提示。
class BusOrderDetailClearToastEvent extends BusOrderDetailPageEvent {
  const BusOrderDetailClearToastEvent();
}
```

### State

```dart
/// 公車訂單詳情頁面狀態。
class BusOrderDetailPageState extends Equatable {
  final bool isLoading;
  final String busOrderId;
  /// 格式化後顯示用的日期，例如「2026/05/18」。
  final String displayDate;
  /// 操作完成後顯示的一次性提示訊息，顯示後應清除為 null。
  final String? toast;
  // ...
}
```

### Bloc handler

```dart
FutureOr<void> _onDelete(
  BusOrderDetailDeleteEvent event,
  Emitter<BusOrderDetailPageState> emit,
) async {
  await _repository.deleteBusOrderRecord(event.recordId);

  // 刪除後重新拉取最新紀錄
  final records = await _repository.fetchBusOrderRecords(
    busOrderId: state.busOrderId,
    date: state.date,
  );

  emit(state.copyWith(records: records, toast: '已刪除紀錄'));
}

void _onClearToast(
  BusOrderDetailClearToastEvent event,
  Emitter<BusOrderDetailPageState> emit,
) {
  // 清除 toast 避免重複顯示
  emit(state.copyWith(clearToast: true));
}
```

---

## 避免的寫法

```dart
// ❌ 廢話註解
// 呼叫 emit
emit(...);

// ❌ 英文註解
// fetch records from repository

// ❌ 資訊量不足
/// 刪除
class BusOrderDetailDeleteEvent { ... }
```

---

## 參照此規範的 Skill

| Skill | 說明 |
|-------|------|
| `flutter-bloc` | 產生 BLoC 三檔案時套用 |
| `flutter-response-model` | 產生 Response model 時套用 |
