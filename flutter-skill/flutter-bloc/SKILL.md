---
name: flutter-bloc
description: Claude Code Skill — 自動產生 Flutter BLoC 相關檔案，遵循專案統一規範
---

# flutter-bloc

> Claude Code Skill — 自動產生 Flutter BLoC 相關檔案，遵循專案統一規範

---

## 這個 Skill 做什麼？

當你要建立新頁面的 BLoC、將頁面邏輯搬移至 BLoC，或修改現有 BLoC 時，自動產生符合規範的三個檔案：`bloc`、`event`、`state`。

---

## 安裝

```bash
claude skill install flutter-bloc.skill
```

---

## 使用方式

直接告訴 Claude Code：

```
幫我建立 WaterStation 的 bloc
```

```
將這個頁面的邏輯搬移到 bloc
```

```
幫我在 BusOrder 的 bloc 新增一個 delete event
```

---

## 檔案結構

以頁面名稱 `{name}` 為例（如 `busOrderDetail`），會在 `bloc/` 資料夾內產生 3 個檔案：

```
lib/page/pages/{name_snake_case}/
└── bloc/
    ├── {name_snake_case}_page_bloc.dart
    ├── {name_snake_case}_page_event.dart
    └── {name_snake_case}_page_state.dart
```

範例（`BusOrderDetail`）：

```
lib/page/pages/bus_order_detail/
└── bloc/
    ├── bus_order_detail_page_bloc.dart
    ├── bus_order_detail_page_event.dart
    └── bus_order_detail_page_state.dart
```

---

## 規範說明

### Rule 1 — Bloc

- 繼承 `Bloc<{Name}PageEvent, {Name}PageState>`
- `super()` 固定傳入 `{Name}PageState.initial()`
- 為每一個 Event 預先註冊 `on<>()` handler
- 使用 `FutureOr<void>` 作為 handler 回傳型別

```dart
class BusOrderDetailPageBloc
    extends Bloc<BusOrderDetailPageEvent, BusOrderDetailPageState> {
  final OrderRepository _repository;

  BusOrderDetailPageBloc(this._repository)
      : super(const BusOrderDetailPageState.initial()) {
    on<_Started>(_onStarted);
    on<_Refresh>(_onRefresh);
    on<_Delete>(_onDelete);
    on<_ClearToast>(_onClearToast);
  }
  // ...
}
```

---

### Rule 2 — Event

- 使用 `@freezed` + `sealed class`
- 預設事件為 `started`、`refresh`
- 依業務需求新增其他 event

```dart
@freezed
sealed class BusOrderDetailPageEvent with _$BusOrderDetailPageEvent {
  const factory BusOrderDetailPageEvent.started({
    required String busOrderId,
    required String date,
    required String displayDate,
    required String unitName,
  }) = _Started;

  const factory BusOrderDetailPageEvent.refresh() = _Refresh;

  const factory BusOrderDetailPageEvent.delete({
    required String recordId,
  }) = _Delete;

  const factory BusOrderDetailPageEvent.clearToast() = _ClearToast;
}
```

> ⚠️ **注意**：Event 內不可定義 `initial` 或 `loaded`，這兩個名稱由 State 的 sealed class 保留使用（`_Initial`、`_Loaded`），重複定義會導致 Dart 編譯錯誤。

---

### Rule 3 — State

- 使用 `@freezed` + `sealed class`
- 固定三個 state variant：`initial`、`loading`、`loaded`
- **所有** state 參數放入獨立的 `{Name}StateData` 類別內

```dart
@freezed
sealed class BusOrderDetailPageState with _$BusOrderDetailPageState {
  const factory BusOrderDetailPageState.initial() = _Initial;
  const factory BusOrderDetailPageState.loading() = _Loading;
  const factory BusOrderDetailPageState.loaded({
    required BusOrderDetailStateData data,
  }) = _Loaded;
}

@freezed
sealed class BusOrderDetailStateData with _$BusOrderDetailStateData {
  const factory BusOrderDetailStateData({
    required String busOrderId,
    required String date,
    required String displayDate,
    required String unitName,
    @Default(<BusOrderFormData>[]) List<BusOrderFormData> records,
    String? toast,
  }) = _BusOrderDetailStateData;
}
```

---

### Rule 4 — 不使用巢狀 copyWith

emit 時禁止巢狀 copyWith，改用 Freezed 的深層 copyWith 語法：

```dart
// ❌ 禁止
emit(
  current.copyWith(
    data: current.data.copyWith(records: records, toast: '已刪除紀錄'),
  ),
);

// ✅ 正確
emit(
  current.copyWith.data.call(records: records, toast: '已刪除紀錄'),
);
```

---

## Private Class 命名對照

State 和 Event 的私有類別名稱**不可重複**，請遵照以下分配：

| 類別 | 保留的私有名稱 |
|------|--------------|
| `{Name}PageState` | `_Initial`、`_Loading`、`_Loaded` |
| `{Name}PageEvent` | `_Started`、`_Refresh`、`_Delete`、`_ClearToast` 等業務命名 |

---

## build_runner

所有檔案產生完畢後，執行：

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 需要的套件

```yaml
dependencies:
  bloc: ^8.x.x
  flutter_bloc: ^8.x.x
  freezed_annotation: ^2.x.x

dev_dependencies:
  build_runner: ^2.x.x
  freezed: ^2.x.x
```
