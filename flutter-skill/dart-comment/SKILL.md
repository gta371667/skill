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
| `///` Dart Doc | 類別、方法、欄位、建構子的說明，會出現在 IDE hover 提示 |
| `//` inline | 解釋邏輯、條件判斷、特殊處理，寫在程式碼旁或上方 |

---

## Dart Doc（`///`）

### 何時加

- 每個 `class`、`sealed class`
- 每個 `factory constructor`（Freezed event / state variant）
- 每個公開方法
- 語意不明顯的欄位（縮寫、業務術語）

### 何時不加

- 私有 handler（`_onXxx`）已有 inline 說明時不重複
- 欄位名稱已完全自我說明（如 `required String name`）

### 格式

```dart
/// 一句話說明這個類別 / 方法 / 欄位的用途。
///
/// 補充說明（可選），例如使用情境、注意事項。
```

### 範例

```dart
/// 公車訂單詳情頁面的 BLoC。
///
/// 負責管理訂單紀錄的載入、刷新與刪除邏輯。
class BusOrderDetailPageBloc
    extends Bloc<BusOrderDetailPageEvent, BusOrderDetailPageState> { ... }

/// 頁面初始化，傳入訂單 ID 與日期開始載入資料。
const factory BusOrderDetailPageEvent.started({
  required String busOrderId,
  required String date,
}) = _Started;

/// 顯示給使用者的日期字串，格式為 yyyy/MM/dd。
required String displayDate,
```

---

## Inline 註解（`//`）

### 何時加

- 條件判斷的意圖（`if`、`switch`）
- 非同步操作的步驟說明
- 狀態轉換的原因
- 不直覺的業務邏輯
- TODO 事項

### 何時不加

- 程式碼本身已清楚表達意圖
- 不逐行翻譯程式碼（避免廢話註解）

### 格式

```dart
// 說明文字，首字不需大寫，結尾不加句號
```

### 範例

```dart
FutureOr<void> _onStarted(...) async {
  emit(const BusOrderDetailPageState.loading());

  // 從 repository 取得指定日期的訂單紀錄
  final records = await _repository.fetchBusOrderRecords(
    busOrderId: event.busOrderId,
    date: event.date,
  );

  emit(BusOrderDetailPageState.loaded(...));
}

FutureOr<void> _onDelete(...) async {
  final current = state;
  if (current is! _Loaded) return; // 非 loaded 狀態不處理

  await _repository.deleteBusOrderRecord(event.recordId);

  // 刪除後重新拉取最新紀錄
  final records = await _repository.fetchBusOrderRecords(...);

  emit(current.copyWith.data.call(records: records, toast: '已刪除紀錄'));
}

void _onClearToast(...) {
  final current = state;
  if (current is! _Loaded) return; // 非 loaded 狀態不處理

  // 清除 toast 避免重複顯示
  emit(current.copyWith.data.call(toast: null));
}
```

---

## Freezed 類別專屬規範

### State variants — 每個 factory 都加 `///`

```dart
@freezed
sealed class BusOrderDetailPageState with _$BusOrderDetailPageState {
  /// 初始狀態，頁面尚未開始載入。
  const factory BusOrderDetailPageState.initial() = _Initial;

  /// 載入中，顯示 loading 指示器。
  const factory BusOrderDetailPageState.loading() = _Loading;

  /// 載入完成，攜帶頁面所需資料。
  const factory BusOrderDetailPageState.loaded({
    required BusOrderDetailStateData data,
  }) = _Loaded;
}
```

### StateData 欄位 — 只在語意不明的欄位加 `///`

```dart
@freezed
sealed class BusOrderDetailStateData with _$BusOrderDetailStateData {
  const factory BusOrderDetailStateData({
    required String busOrderId,
    required String date,
    /// 格式化後顯示用的日期，例如「2026/05/18」。
    required String displayDate,
    required String unitName,
    @Default(<BusOrderFormData>[]) List<BusOrderFormData> records,
    /// 操作完成後顯示的一次性提示訊息，顯示後應清除為 null。
    String? toast,
  }) = _BusOrderDetailStateData;
}
```

### Event variants — 每個 factory 都加 `///`

```dart
@freezed
sealed class BusOrderDetailPageEvent with _$BusOrderDetailPageEvent {
  /// 頁面啟動，開始載入訂單資料。
  const factory BusOrderDetailPageEvent.started({
    required String busOrderId,
    required String date,
    required String displayDate,
    required String unitName,
  }) = _Started;

  /// 重新整理訂單紀錄。
  const factory BusOrderDetailPageEvent.refresh() = _Refresh;

  /// 刪除指定的訂單紀錄。
  const factory BusOrderDetailPageEvent.delete({
    required String recordId,
  }) = _Delete;

  /// 清除畫面上的 toast 提示。
  const factory BusOrderDetailPageEvent.clearToast() = _ClearToast;
}
```

---

## 避免的寫法

```dart
// ❌ 廢話註解（重複程式碼內容）
// 呼叫 emit
emit(...);

// ❌ 英文註解
// fetch records from repository

// ❌ 過於簡短沒有資訊量
/// 刪除
const factory BusOrderDetailPageEvent.delete({...}) = _Delete;
```

---

## 參照此規範的 Skill

| Skill | 說明 |
|-------|------|
| `flutter-bloc` | 產生 BLoC 三檔案時套用此規範 |
| `flutter-freezed-response` | 產生 Response model 時套用此規範 |
