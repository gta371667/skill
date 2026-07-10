---
name: flutter-bloc
description: >
  Generates or modifies Flutter BLoC files (bloc, event, state) following project conventions.
  Use this skill whenever the user wants to: create a new BLoC for a page, migrate page logic
  into a BLoC, modify an existing BLoC, add events or states, or refactor BLoC-related code.
  Triggers on: "建立bloc", "新增bloc", "幫我建立bloc", "搬移到bloc", "修改bloc",
  "新增event", "新增state", "create bloc", "add event", "refactor to bloc",
  or any mention of bloc/event/state in a Flutter page context.
---

# Flutter BLoC Generator

Generates Flutter BLoC files following the project's conventions:
- Equatable for event/state equality
- Single flat state class (no sealed variants, no StateData wrapper)
- Hand-written copyWith directly on the state
- Async/API-driven fields use `AsyncResult<T, E>` instead of separate `isLoading` bool / `toast` string fields
- Models stored in a `model/` folder at the same level as `bloc/`

---

## AsyncResult 共用檔案

State 中所有「來自非同步請求（API 呼叫）」的欄位，一律使用 `AsyncResult<T, E>` 封裝，
**不要**再額外寫 `isLoading` bool 或 `toast`/`errorMessage` string 欄位。

固定路徑：`lib/core/network/async_result.dart`

`AsyncResult<T, E>` 提供：
- `AsyncResult.idle()` / `.loading({T? data})` / `.success({required T data, String? message})` / `.failure({required E error, T? data})`
- Getter：`isLoading`、`isSuccess`、`isFailure`、`hasData`、`dataOrNull`、`error`、`successMessage`
- Extension 方法（在既有值上轉換狀態）：`.loading({keepData})`、`.setSuccess({data, message})`、`.setError({error, keepData})`

**產生 bloc 前，先確認專案中是否已存在這個檔案：**
1. 檢查 `lib/core/network/async_result.dart` 是否存在
2. 若不存在，將 `assets/async_result.dart` 複製到該路徑，再開始產生 bloc 相關檔案
3. 若已存在，直接在 state/bloc 檔案中 `import 'package:{project}/core/network/async_result.dart';` 使用即可，不要重複建立

---

## File Structure

For a page named `{name}` (e.g. `busOrderDetail`), generate **3 files** inside a `bloc/` subfolder.
If models are needed, create a `model/` folder at the same level:

```
lib/page/pages/{name_snake_case}/
├── bloc/
│   ├── {name_snake_case}_page_bloc.dart
│   ├── {name_snake_case}_page_event.dart
│   └── {name_snake_case}_page_state.dart
└── model/                          ← 只在有需要時建立
    └── {model_name}.dart
```

---

## Rule 1 — Bloc File (`{name}_page_bloc.dart`)

```dart
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:{project}/core/network/async_result.dart';
// add any other imports required by the page logic

part '{name}_page_event.dart';
part '{name}_page_state.dart';

class {Name}PageBloc extends Bloc<{Name}PageEvent, {Name}PageState> {
  final SomeRepository _repository;

  {Name}PageBloc(this._repository)
      : super(const {Name}PageState()) {
    on<{Name}StartedEvent>(_onStarted);
    on<{Name}RefreshEvent>(_onRefresh);
    // register additional handlers based on events defined in event file
  }

  FutureOr<void> _onStarted(
    {Name}StartedEvent event,
    Emitter<{Name}PageState> emit,
  ) async {
    emit(state.copyWith(records: state.records.loading()));
    try {
      final records = await _repository.fetchRecords();
      emit(state.copyWith(records: state.records.setSuccess(data: records)));
    } catch (e) {
      emit(state.copyWith(records: state.records.setError(error: e.toString())));
    }
  }

  FutureOr<void> _onRefresh(
    {Name}RefreshEvent event,
    Emitter<{Name}PageState> emit,
  ) async {
    // keepData: true，refresh 期間畫面仍可顯示舊資料
    emit(state.copyWith(records: state.records.loading(keepData: true)));
    try {
      final records = await _repository.fetchRecords();
      emit(state.copyWith(records: state.records.setSuccess(data: records)));
    } catch (e) {
      emit(state.copyWith(
        records: state.records.setError(error: e.toString(), keepData: true),
      ));
    }
  }
}
```

**Key rules:**
- `super()` receives `const {Name}PageState()` — the single initial state
- `state` is always a `{Name}PageState`, no type-checking needed
- Event class names follow pattern: `{Name}{Action}Event` (e.g. `BusOrderStartedEvent`)

---

## Rule 2 — Event File (`{name}_page_event.dart`)

```dart
part of '{name}_page_bloc.dart';

/// {Name} 頁面事件基底類別。
sealed class {Name}PageEvent {
  const {Name}PageEvent();
}

/// 頁面啟動，開始載入資料。
class {Name}StartedEvent extends {Name}PageEvent {
  // add required fields
  const {Name}StartedEvent();
}

/// 重新整理資料。
class {Name}RefreshEvent extends {Name}PageEvent {
  const {Name}RefreshEvent();
}

// Add more events as needed, e.g.:
// class {Name}DeleteEvent extends {Name}PageEvent {
//   final String id;
//   const {Name}DeleteEvent({required this.id});
// }
```

**Key rules:**
- Base class is `sealed class {Name}PageEvent` — **不繼承 Equatable**
- Each event is a separate `class` extending the base
- Event naming: `{Name}{Action}Event` — e.g. `BusOrderStartedEvent`
- 若特定 event 有需要比較（如在 `transformEvents` 或 `distinct` 中使用），再自行加 `extends Equatable` 與 `props`

---

## Rule 3 — State File (`{name}_page_state.dart`)

```dart
part of '{name}_page_bloc.dart';

/// {Name} 頁面狀態。
class {Name}PageState extends Equatable {
  /// 列表資料的非同步狀態（idle / loading / success / failure）。
  final AsyncResult<List<Record>, String> records;
  // add other page state fields here directly

  const {Name}PageState({
    this.records = const AsyncResult.idle(),
  });

  {Name}PageState copyWith({
    AsyncResult<List<Record>, String>? records,
  }) {
    return {Name}PageState(
      records: records ?? this.records,
    );
  }

  @override
  List<Object?> get props => [records];
}
```

**Key rules:**
- **Single flat class** — no sealed variants, no subclasses, no StateData wrapper
- All page state fields go **directly** on `{Name}PageState`
- **每個非同步（API）欄位一律用 `AsyncResult<T, E>`**，不要另外寫 `isLoading` bool 或 `toast`/`errorMessage` string
  - 畫面用 `state.records.isLoading`、`state.records.dataOrNull`、`state.records.error`、`state.records.successMessage` 讀取狀態
- 非非同步的一般欄位（如篩選條件、選取狀態）才用一般型別直接宣告
- Hand-written `copyWith` with all fields
- Extends `Equatable`, override `props` with all fields

---

## Rule 4 — copyWith Pattern

Emit state updates by transforming the relevant `AsyncResult` field, then passing it into `state.copyWith(...)`:

```dart
// 開始載入（不保留舊資料）
emit(state.copyWith(records: state.records.loading()));

// Refresh：載入中但保留舊資料，畫面不會閃爍
emit(state.copyWith(records: state.records.loading(keepData: true)));

// 請求成功
emit(state.copyWith(records: state.records.setSuccess(data: records)));

// 請求成功並附帶提示訊息
emit(state.copyWith(
  records: state.records.setSuccess(data: records, message: '已刪除紀錄'),
));

// 請求失敗（保留舊資料以便畫面仍可顯示）
emit(state.copyWith(
  records: state.records.setError(error: e.toString(), keepData: true),
));

// 同時更新多個欄位
emit(state.copyWith(
  records: state.records.setSuccess(data: records),
  selectedFilter: newFilter,
));
```

畫面讀取狀態時使用 `AsyncResult` 的 getter，而不是額外的 bool/string 欄位：

```dart
if (state.records.isLoading) { ... }
final list = state.records.dataOrNull ?? [];
final errorText = state.records.error;
final toastText = state.records.successMessage;
```

---

## Rule 5 — Model 存放規範

若 BLoC 邏輯需要自訂資料模型（非 API Response），建立 `model/` 資料夾與 `bloc/` 同層：

```
lib/page/pages/bus_order_detail/
├── bloc/
│   ├── bus_order_detail_page_bloc.dart
│   ├── bus_order_detail_page_event.dart
│   └── bus_order_detail_page_state.dart
└── model/
    └── bus_order_record.dart       ← 頁面專屬 model
```

**Model 規範：**
- 只在頁面專屬的資料結構才放這裡；通用 model 仍放 `lib/data/models/`
- 每個 model 一個獨立檔案
- Model class 同樣繼承 `Equatable`，手寫 `copyWith`

---

## Naming Convention

| 項目 | 格式 | 範例 |
|------|------|------|
| Event 基底類別 | `{Name}PageEvent` | `BusOrderDetailPageEvent` |
| 各 Event 類別 | `{Name}{Action}Event` | `BusOrderDetailStartedEvent` |
| State 類別 | `{Name}PageState` | `BusOrderDetailPageState` |
| Model 類別 | 依業務命名 | `BusOrderRecord` |

---

## Reference Files

See working examples in:
- `references/bus_order_detail_page_bloc.dart`
- `references/bus_order_detail_page_event.dart`
- `references/bus_order_detail_page_state.dart`

共用範本：
- `assets/async_result.dart` — `AsyncResult<T, E>` 完整實作，當專案中尚無 `lib/core/network/async_result.dart` 時複製此檔案過去

---

## Workflow

1. Ask the user for the **page name** and **what data/events** the page needs (if not already provided)
2. Ask for any **repository dependencies** and **models** needed
3. Check whether `lib/core/network/async_result.dart` exists in the project; if not, copy `assets/async_result.dart` there first
4. Generate `bloc/` files following the rules above — async/API fields use `AsyncResult<T, E>`
5. If models are needed, generate them in `model/` at the same level
6. No build_runner needed — Equatable does not require code generation

---

## 註解規範

產生所有 Dart 程式碼時，請同時參照 `dart-comment` Skill 的中文註解規範：

- `///` Dart Doc：加在每個 class、方法、語意不明的欄位
- `//` inline：加在邏輯判斷、狀態轉換、非同步步驟、不直覺的業務邏輯上
- 語言：**中文**
- 避免廢話註解（不要逐行翻譯程式碼）

詳細規則請見 `dart-comment/SKILL.md`。