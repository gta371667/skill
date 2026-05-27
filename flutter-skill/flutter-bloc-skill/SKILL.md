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
claude skill install flutter-bloc-skill.skill
```

---

## 使用方式

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

## 規範說明

### Rule 1 — Bloc

- 繼承 `Bloc<{Name}PageEvent, {Name}PageState>`
- `super()` 固定傳入 `const {Name}PageState()`
- 為每一個 Event 預先註冊 `on<>()` handler
- 直接透過 `state.copyWith(...)` emit，不需型別判斷

```dart
class BusOrderDetailPageBloc
    extends Bloc<BusOrderDetailPageEvent, BusOrderDetailPageState> {
  final OrderRepository _repository;

  BusOrderDetailPageBloc(this._repository)
      : super(const BusOrderDetailPageState()) {
    on<BusOrderDetailStartedEvent>(_onStarted);
    on<BusOrderDetailRefreshEvent>(_onRefresh);
    on<BusOrderDetailDeleteEvent>(_onDelete);
    on<BusOrderDetailClearToastEvent>(_onClearToast);
  }
}
```

---

### Rule 2 — Event

- Base class 為 `sealed class`，**不繼承 Equatable**
- 每個 event 獨立一個 class
- 命名格式：`{Name}{Action}Event`
- 若特定 event 需要比較，再自行加 `extends Equatable` 與 `props`

```dart
sealed class BusOrderDetailPageEvent {
  const BusOrderDetailPageEvent();
}

class BusOrderDetailStartedEvent extends BusOrderDetailPageEvent {
  final String busOrderId;
  final String date;
  const BusOrderDetailStartedEvent({
    required this.busOrderId,
    required this.date,
  });
}

class BusOrderDetailRefreshEvent extends BusOrderDetailPageEvent {
  const BusOrderDetailRefreshEvent();
}

class BusOrderDetailDeleteEvent extends BusOrderDetailPageEvent {
  final String recordId;
  const BusOrderDetailDeleteEvent({required this.recordId});
}

class BusOrderDetailClearToastEvent extends BusOrderDetailPageEvent {
  const BusOrderDetailClearToastEvent();
}
```

---

### Rule 3 — State

- **單一扁平 class**，不用 sealed variants，不用 StateData 包裝
- 所有欄位直接放在 `{Name}PageState`
- 用 `isLoading` 表示載入狀態
- 手寫 `copyWith`，nullable 欄位用 `clearXxx = false` flag
- 繼承 `Equatable`，override `props`

```dart
class BusOrderDetailPageState extends Equatable {
  final bool isLoading;
  final String busOrderId;
  final String date;
  final String displayDate;
  final String unitName;
  final List<BusOrderFormData> records;
  final String? toast;

  const BusOrderDetailPageState({
    this.isLoading = false,
    this.busOrderId = '',
    this.date = '',
    this.displayDate = '',
    this.unitName = '',
    this.records = const [],
    this.toast,
  });

  BusOrderDetailPageState copyWith({
    bool? isLoading,
    String? busOrderId,
    String? date,
    String? displayDate,
    String? unitName,
    List<BusOrderFormData>? records,
    String? toast,
    bool clearToast = false,
  }) {
    return BusOrderDetailPageState(
      isLoading: isLoading ?? this.isLoading,
      busOrderId: busOrderId ?? this.busOrderId,
      date: date ?? this.date,
      displayDate: displayDate ?? this.displayDate,
      unitName: unitName ?? this.unitName,
      records: records ?? this.records,
      toast: clearToast ? null : toast ?? this.toast,
    );
  }

  @override
  List<Object?> get props => [
        isLoading, busOrderId, date, displayDate,
        unitName, records, toast,
      ];
}
```

---

### Rule 4 — copyWith

直接用 `state.copyWith(...)` emit，不需先取出 current：

```dart
// 開始載入
emit(state.copyWith(isLoading: true));

// 更新欄位
emit(state.copyWith(isLoading: false, records: records));

// 清除 nullable 欄位
emit(state.copyWith(clearToast: true));
```

---

### Rule 5 — Model 資料夾

頁面專屬的資料模型放在與 `bloc/` 同層的 `model/` 資料夾：

```
bus_order_detail/
├── bloc/
└── model/
    └── bus_order_record.dart
```

- 只放頁面專屬 model；通用 model 放 `lib/data/models/`
- 每個 model 一個獨立檔案
- 同樣繼承 `Equatable`，手寫 `copyWith`

---

## Naming Convention

| 項目 | 格式 | 範例 |
|------|------|------|
| Event 基底類別 | `{Name}PageEvent` | `BusOrderDetailPageEvent` |
| 各 Event 類別 | `{Name}{Action}Event` | `BusOrderDetailStartedEvent` |
| State 類別 | `{Name}PageState` | `BusOrderDetailPageState` |
| Model 類別 | 依業務命名 | `BusOrderRecord` |

---

## 需要的套件

```yaml
dependencies:
  bloc: ^8.x.x
  flutter_bloc: ^8.x.x
  equatable: ^2.x.x
```

> build_runner 不需要，Equatable 不需要程式碼生成。
