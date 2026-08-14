---
name: flutter-provider
description: >
  Generates or modifies Flutter Provider (ChangeNotifier) files following the project's conventions,
  and helps migrate existing BLoC code to Provider. Use this skill whenever the user wants to:
  create a new Notifier for a page, migrate page logic into a Notifier, modify an existing Notifier,
  add methods/state fields, refactor Provider-related code, or convert a BLoC to Provider.
  Triggers on: "建立provider", "新增notifier", "幫我建立notifier", "搬移到provider",
  "修改notifier", "bloc轉provider", "改用provider", "create notifier", "add notifier method",
  "refactor to provider", "convert bloc to provider", or any mention of provider/ChangeNotifier
  in a Flutter page context.
---

# Flutter Provider Generator

Generates Flutter Provider files following the project's conventions. This skill is the Provider
counterpart to `flutter-bloc`, and deliberately keeps the same state design philosophy so migrating
between the two is low-cost:

- Single flat state class (no sealed variants, no StateData wrapper)
- Hand-written `copyWith` directly on the state
- Async/API-driven fields use `AsyncResult<T, E>` instead of separate `isLoading` bool / `toast` string fields
- Models stored in a `model/` folder at the same level as the notifier
- **不同於 BLoC：state class 不繼承 Equatable**（ChangeNotifier 靠 `notifyListeners()` 主動通知，不靠相等性比較）

---

## BLoC → Provider 概念對應

| BLoC | Provider |
|------|----------|
| `Bloc<Event, State>` | `ChangeNotifier` |
| `emit(state.copyWith(...))` | `_state = _state.copyWith(...); notifyListeners();` |
| `on<Event>()` handler | 一般 method（不需事件類別） |
| `context.read<Bloc>().add(Event())` | `context.read<Notifier>().method()` |
| `BlocProvider` | `ChangeNotifierProvider` |
| `BlocBuilder<B, S>` | `Consumer<T>` / `context.watch<T>()` |
| `BlocListener<B, S>` | `ValueChangeListener<T>` 共用元件（見下方） |
| 3 個檔案（bloc / event / state） | 2 個檔案（notifier / state） |

核心差異：BLoC 是「事件驅動」，Provider 是「直接呼叫方法」。狀態不再是 immutable 的 emit 版本，
而是 notifier 內部持有的 immutable state 物件，改完呼叫 `notifyListeners()` 通知畫面重建。

---

## AsyncResult 共用檔案

與 `flutter-bloc` 完全相同。State 中所有「來自非同步請求（API 呼叫）」的欄位，
一律使用 `AsyncResult<T, E>` 封裝，**不要**再額外寫 `isLoading` bool 或 `toast`/`errorMessage` string 欄位。

固定路徑：`lib/core/network/async_result.dart`

`AsyncResult<T, E>` 提供：
- `AsyncResult.idle()` / `.loading({T? data})` / `.success({required T data, String? message})` / `.failure({required E error, T? data})`
- Getter：`isLoading`、`isSuccess`、`isFailure`、`hasData`、`dataOrNull`、`error`、`successMessage`
- Extension 方法：`.loading({keepData})`、`.setSuccess({data, message})`、`.setError({error, keepData})`

**產生 notifier 前，先確認專案中是否已存在這個檔案：**
1. 檢查 `lib/core/network/async_result.dart` 是否存在
2. 若不存在，將 `assets/async_result.dart` 複製到該路徑
3. 若已存在，直接 `import` 使用即可，不要重複建立

---

## File Structure

For a page named `{name}` (e.g. `busOrderDetail`), generate **2 files** inside a `provider/` subfolder.
If models are needed, create a `model/` folder at the same level:

```
lib/page/pages/{name_snake_case}/
├── provider/
│   ├── {name_snake_case}_page_notifier.dart
│   └── {name_snake_case}_page_state.dart
└── model/                          ← 只在有需要時建立
    └── {model_name}.dart
```

State 用 `part of` 掛在 notifier 檔案上，與 BLoC 版本的 `part` 慣例一致。

---

## Rule 1 — Notifier File (`{name}_page_notifier.dart`)

```dart
import 'package:flutter/foundation.dart';
import 'package:{project}/core/network/async_result.dart';
// add any other imports required by the page logic

part '{name}_page_state.dart';

/// {Name} 頁面的狀態管理。
class {Name}PageNotifier extends ChangeNotifier {
  final SomeRepository _repository;

  {Name}PageNotifier(this._repository);

  /// 頁面狀態；沿用 flat state 慣例，只 expose getter，不 expose setter。
  {Name}PageState _state = const {Name}PageState();
  {Name}PageState get state => _state;

  Future<void> onStarted() async {
    _state = _state.copyWith(records: _state.records.loading());
    notifyListeners();
    try {
      final records = await _repository.fetchRecords();
      _state = _state.copyWith(records: _state.records.setSuccess(data: records));
    } catch (e) {
      _state = _state.copyWith(records: _state.records.setError(error: e.toString()));
    }
    notifyListeners();
  }

  /// refresh：載入中保留舊資料，畫面不閃爍。
  Future<void> onRefresh() async {
    _state = _state.copyWith(records: _state.records.loading(keepData: true));
    notifyListeners();
    try {
      final records = await _repository.fetchRecords();
      _state = _state.copyWith(records: _state.records.setSuccess(data: records));
    } catch (e) {
      _state = _state.copyWith(
        records: _state.records.setError(error: e.toString(), keepData: true),
      );
    }
    notifyListeners();
  }
}
```

**Key rules:**
- 用「單一 state getter」，**不要**每個欄位各寫一個 getter；欄位再多，畫面一律用 `notifier.state.xxx` 讀取
- state 欄位放在 immutable `{Name}PageState` 內，天生防止外部亂改（拿到 state 也改不了）
- 每次狀態變更：`_state = _state.copyWith(...)` 之後**務必** `notifyListeners()`
- 非同步流程的收尾（成功/失敗）各呼叫一次 `notifyListeners()`
- 需要讓呼叫端依結果做 side effect（導航/提示）的 method，回傳 `Future<bool>` 或結果值（見 Rule 4）

---

## Rule 2 — State File (`{name}_page_state.dart`)

```dart
part of '{name}_page_notifier.dart';

/// {Name} 頁面狀態。
class {Name}PageState {
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
}
```

**Key rules:**
- **Single flat class**，所有欄位 `final`，所有欄位直接放在 `{Name}PageState`
- 每個非同步（API）欄位一律用 `AsyncResult<T, E>`，畫面用 `state.records.isLoading` /
  `.dataOrNull` / `.error` / `.successMessage` 讀取
- 非非同步的一般欄位（篩選條件、選取狀態）用一般型別直接宣告
- Hand-written `copyWith`
- **不繼承 Equatable、不需要 `props`**（與 BLoC 版本唯一的結構差異）

---

## Rule 3 — 畫面接線（Provider / Consumer）

```dart
// 建立 + 觸發初始載入
ChangeNotifierProvider(
  create: (_) => {Name}PageNotifier(repository)..onStarted(),
  child: Consumer<{Name}PageNotifier>(
    builder: (context, notifier, _) {
      final state = notifier.state;
      if (state.records.isLoading) return const CircularProgressIndicator();
      final list = state.records.dataOrNull ?? [];
      return ListView(children: /* ...list... */);
    },
  ),
)

// 觸發事件
onPressed: () => context.read<{Name}PageNotifier>().onRefresh(),
```

**Key rules:**
- 只在需要「重建 UI」的地方用 `Consumer` / `context.watch`
- 只需觸發 method、不需重建的地方用 `context.read`
- 一律透過 `notifier.state.xxx` 讀狀態

---

## Rule 4 — 一次性 side effect（取代 BlocListener）

BLoC 用 `BlocListener` 處理「不重建 UI、只做一次性動作」（SnackBar、導航、Dialog）。
Provider 沒有內建對應元件，依情境選一種：

### (a) 主動觸發：method 回傳結果，呼叫端直接處理（優先，涵蓋約 9 成情境）

```dart
// notifier
Future<bool> onDelete(String id) async {
  try {
    await _repository.delete(id);
    _state = _state.copyWith(records: _state.records.setSuccess(data: []));
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

// 呼叫端
onPressed: () async {
  final ok = await context.read<{Name}PageNotifier>().onDelete(id);
  if (ok && context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('已刪除紀錄')));
    Navigator.pop(context);
  }
},
```

### (b) 被動觸發：用 `ValueChangeListener` 元件（本 skill 提供）

當 side effect 是被動觸發的（背景更新了某欄位，非使用者主動點擊造成），
或是「撈完 API 後把值填入 `TextEditingController`」這種情境，用共用元件
`ValueChangeListener<T>`。它是 Provider 版的 `BlocListener`：`value` 對應監聽對象、
`listenWhen` 對應觸發條件、`onChanged` 對應 `listener`，`child` 不會被重建。

固定路徑：`lib/core/widgets/value_change_listener.dart`（若不存在，從 `assets/value_change_listener.dart` 複製過去）

```dart
Consumer<EditProfilePageNotifier>(
  builder: (context, notifier, _) {
    return ValueChangeListener<Profile?>(
      value: notifier.state.profile.dataOrNull,
      // 只在第一次拿到資料時設值，避免 refresh 覆蓋使用者輸入
      listenWhen: (previous, current) => previous == null && current != null,
      onChanged: (profile) {
        if (profile != null) {
          _nameController.text = profile.name;
          _phoneController.text = profile.phone; // 一次設多個 controller 也行
        }
      },
      child: const YourFormWidget(),
    );
  },
)
```

**注意：**
- `value` 的 `==` 要正確；自訂 model 建議繼承 `Equatable` 或覆寫 `==`，否則 `listenWhen` 預設的 `!=` 比較每次都成立而重複觸發
- 不傳 `listenWhen` 時預設為 `previous != current`（值有變就觸發）

---

## Rule 5 — TextEditingController 放哪裡

**Controller 放在 Widget（StatefulWidget）裡，不放進 Notifier。**
Notifier 只管業務邏輯與狀態，不持有 Flutter UI 生命週期物件。撈完 API 要設值時，
透過 Rule 4(b) 的 `ValueChangeListener` 把 `state` 的值同步進 controller。

```dart
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose(); // controller 生命週期由 Widget 管理
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditProfilePageNotifier>(
      builder: (context, notifier, _) {
        return ValueChangeListener<Profile?>(
          value: notifier.state.profile.dataOrNull,
          listenWhen: (prev, curr) => prev == null && curr != null,
          onChanged: (profile) {
            if (profile != null) _nameController.text = profile.name;
          },
          child: TextField(controller: _nameController),
        );
      },
    );
  }
}
```

---

## Rule 6 — Model 存放規範

與 `flutter-bloc` 相同。若 notifier 邏輯需要自訂資料模型（非 API Response），
建立 `model/` 資料夾與 notifier 同層：

```
lib/page/pages/bus_order_detail/
├── provider/
│   ├── bus_order_detail_page_notifier.dart
│   └── bus_order_detail_page_state.dart
└── model/
    └── bus_order_record.dart       ← 頁面專屬 model
```

- 只在頁面專屬的資料結構才放這裡；通用 model 仍放 `lib/data/models/`
- 每個 model 一個獨立檔案
- Model class 繼承 `Equatable`，手寫 `copyWith`（model 需要值比較，與 state 不同）

---

## Naming Convention

| 項目 | 格式 | 範例 |
|------|------|------|
| Notifier 類別 | `{Name}PageNotifier` | `BusOrderDetailPageNotifier` |
| State 類別 | `{Name}PageState` | `BusOrderDetailPageState` |
| 事件對應 method | `on{Action}` | `onStarted`、`onRefresh`、`onDelete` |
| Model 類別 | 依業務命名 | `BusOrderRecord` |

事件 method 命名沿用原 BLoC event 的語意（`{Name}StartedEvent` → `onStarted`），方便對照遷移。

---

## Reference Files

See working examples in（由 `flutter-bloc` 的同名範例逐一改寫，可直接對照差異）：
- `references/bus_order_detail_page_notifier.dart`
- `references/bus_order_detail_page_state.dart`

共用範本：
- `assets/async_result.dart` — 當專案中尚無 `lib/core/network/async_result.dart` 時複製過去（與 flutter-bloc 相同檔案）
- `assets/value_change_listener.dart` — 當專案中尚無 `lib/core/widgets/value_change_listener.dart` 時複製過去

---

## Workflow

1. Ask the user for the **page name** and **what data/events** the page needs (if not already provided)
2. Ask for any **repository dependencies** and **models** needed
3. Check whether `lib/core/network/async_result.dart` exists；若不存在先複製 `assets/async_result.dart`
4. 若頁面需要「撈完 API 設 controller」或被動 side effect，檢查 `lib/core/widgets/value_change_listener.dart` 是否存在；若不存在複製 `assets/value_change_listener.dart`
5. Generate `provider/` files following the rules above — async/API fields use `AsyncResult<T, E>`, state 不繼承 Equatable
6. If models are needed, generate them in `model/` at the same level
7. No build_runner needed

### 若為 BLoC → Provider 遷移

依「BLoC → Provider 概念對應」表逐項轉換：
1. `{Name}PageState` 保留欄位與 `copyWith`，**移除** `extends Equatable` 與 `props`
2. `{Name}PageBloc` → `{Name}PageNotifier extends ChangeNotifier`
3. 每個 `on<XxxEvent>` handler → 對應 `onXxx` method，把 `emit(state.copyWith(...))` 換成 `_state = _state.copyWith(...); notifyListeners();`
4. event 類別的欄位 → 改成 method 參數
5. `{name}_page_event.dart` 檔案刪除（Provider 不需要事件類別）
6. `BlocListener` → 依 Rule 4 改成回傳值或 `ValueChangeListener`
7. 畫面 `BlocProvider`/`BlocBuilder` → `ChangeNotifierProvider`/`Consumer`，讀取改為 `notifier.state.xxx`

---

## 註解規範

產生所有 Dart 程式碼時，請同時參照 `dart-comment` Skill 的中文註解規範：

- `///` Dart Doc：加在每個 class、方法、語意不明的欄位
- `//` inline：加在邏輯判斷、狀態轉換、非同步步驟、不直覺的業務邏輯上
- 語言：**中文**
- 避免廢話註解（不要逐行翻譯程式碼）

詳細規則請見 `dart-comment/SKILL.md`。
