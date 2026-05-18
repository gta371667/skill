# flutter-project-knowledge

> Claude Code Skill — Flutter 專案通用架構知識庫，適用於所有採用相同技術棧的專案

---

## 這個 Skill 做什麼？

將 Flutter 專案的架構規範、資料夾結構、開發流程內建給 Claude Code，讓它在你問「這個檔案要放哪？」、「新增頁面要改哪些地方？」時，直接給出符合規範的答案。

與 `project-architecture-README.md` 不同：那份是給人看的，這份是給 Claude Code 用的。

---

## 安裝

```bash
claude skill install flutter-project-knowledge.skill
```

---

## 適用專案

採用以下技術棧的 Flutter 專案皆適用：

| 類別 | 套件 |
|------|------|
| 狀態管理 | `flutter_bloc` + `freezed` |
| 網路請求 | `dio` |
| 路由 | `go_router` |
| UI 縮放 | `flutter_screenutil` |
| 多語系 | `flutter_localizations` |
| 程式碼生成 | `build_runner` + `freezed` + `json_serializable` |

---

## 觸發時機

Claude Code 在以下情況會自動參照此 Skill：

- 新增頁面、BLoC、Repository
- 詢問資料夾位置或命名規範
- 設定路由
- 使用網路層（DioClient、AsyncResult）
- 任何與「專案怎麼運作」相關的問題

---

## 標準資料夾結構

```
lib/
├── main.dart                  # App 入口，注入 Repository 與全域 BLoC
├── bean/                      # API Response 模型
│   ├── bean.dart              # 統一 export 所有 response
│   └── response/
│       └── {name}/
├── core/                      # 核心基礎設施
│   ├── constants/
│   ├── network/
│   │   ├── dio_client.dart
│   │   ├── async_result.dart
│   │   ├── interceptors/
│   │   └── verify/
│   └── theme/
├── data/                      # 資料層
│   ├── extension/
│   ├── models/
│   ├── repository/
│   │   ├── repository.dart    # 統一 export
│   │   └── {name}/
│   │       ├── {name}_repository.dart
│   │       └── impl/
│   ├── request/
│   └── service/
├── l10n/
├── page/                      # UI 層
│   ├── blocs/                 # 全域 BLoC
│   ├── pages/
│   │   └── {page_name}/
│   │       ├── {page_name}_page.dart
│   │       ├── bloc/
│   │       └── widget/
│   ├── router/
│   └── widgets/
└── res/
```

---

## 架構分層

```
┌──────────────────────────────────────┐
│              UI 層 (page/)           │
│   Page Widget  ←→  BLoC              │
│   只負責顯示，邏輯全在 BLoC           │
└─────────────────┬────────────────────┘
                  │ 呼叫
┌─────────────────▼────────────────────┐
│           資料層 (data/)             │
│   Repository Interface               │
│   Repository Impl ← Request         │
│   BLoC 只依賴 Interface              │
└─────────────────┬────────────────────┘
                  │ HTTP
┌─────────────────▼────────────────────┐
│          核心層 (core/)              │
│   DioClient → Interceptors           │
│   AsyncResult（狀態封裝）             │
└──────────────────────────────────────┘
```

---

## 新增頁面標準流程

1. `lib/page/pages/` 建立 `{name}/` 資料夾
2. 建立 `{name}_page.dart`
3. 用 `flutter-bloc` Skill 在 `bloc/` 生成三個 BLoC 檔案
4. 頁面專屬小元件放 `widget/`
5. `app_router.dart` 新增路徑常數與 `GoRoute`，在 `builder` 注入 `BlocProvider`
6. 如需新 Repository，依照下方規範新增

---

## 新增 Repository 流程

```
lib/data/repository/{name}/
├── {name}_repository.dart          # abstract class
└── impl/
    └── {name}_repository_impl.dart # 實作
```

新增後需同步更新：

```dart
// 1. lib/data/repository/repository.dart
export '{name}/{name}_repository.dart';

// 2. lib/main.dart — MultiRepositoryProvider
RepositoryProvider<{Name}Repository>(
  create: (_) => {Name}RepositoryImpl(),
),
```

---

## BLoC 規範重點

詳細請參照 `flutter-bloc` Skill，重點如下：

- State 固定三個 variant：`initial`、`loading`、`loaded`
- 所有 State 參數放在 `{Name}StateData` 內
- emit 使用深層 copyWith：`current.copyWith.data.call(...)`
- Event 不可定義 `initial` 或 `loaded`

---

## 路由規範

```dart
// 路徑常數集中在 AppRoutes
class AppRoutes {
  static const String home = '/home';
}

// GoRoute 標準寫法
GoRoute(
  path: AppRoutes.someRoute,
  builder: (context, state) => BlocProvider(
    create: (_) => SomePageBloc(context.read())
      ..add(const SomePageEvent.started()),
    child: const SomePage(),
  ),
),
```

Extra 參數用 `state.extra` 傳遞，自訂 Model 需在 `codec.dart` 新增序列化規則。

---

## 網路層

### AsyncResult 四種狀態

```dart
AsyncResult.none      // 初始
.loading()            // 呼叫中
.setSuccess(data: …)  // 成功
.setError(error: …)   // 失敗
```

### DioClient

```dart
DioClient.instance.setAuthToken(token)  // 登入後
DioClient.instance.clearAuthToken()     // 登出後
```

---

## UI 撰寫規範

### flutter_screenutil 尺寸規範

所有尺寸**必須**使用 extension，禁止裸數字：

| 用途 | 寫法 |
|------|------|
| 寬度 | `.w` |
| 高度 | `.h` |
| 圓角 | `.r` |
| 字體大小 | `.sp` |

```dart
// ❌ 禁止
Container(width: 100, height: 48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)))

// ✅ 正確
Container(width: 100.w, height: 48.h, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)))
```

---

### 顏色使用規範

**禁止**在 UI 直接使用 `Color(0xff...)`，所有顏色必須定義在 `lib/res/my_colors.dart` 並依相近顏色歸類。

```dart
// my_colors.dart 結構範例
class MyColors {
  // ── 主色系 ──────────────────────────────
  static const primary = Color(0xff1A73E8);

  // ── 中性色 / 灰階 ────────────────────────
  static const grey100 = Color(0xffF5F5F5);

  // ── 文字色 ──────────────────────────────
  static const textPrimary = Color(0xff212121);

  // ── 狀態色 ──────────────────────────────
  static const success = Color(0xff4CAF50);
  static const error = Color(0xffF44336);

  // ── 背景色 ──────────────────────────────
  static const background = Color(0xffFAFAFA);
}
```

```dart
// ❌ 禁止
TextStyle(color: Color(0xff212121))

// ✅ 正確
TextStyle(color: MyColors.textPrimary)
```

---

## 常用指令

```bash
# 重新生成 Freezed / JSON 程式碼
dart run build_runner build --delete-conflicting-outputs

# 重新生成多語系
flutter gen-l10n
```

---

## 相關 Skill

| Skill | 用途 |
|-------|------|
| `flutter-bloc` | 產生 BLoC 三個檔案 |
| `flutter-freezed-response` | 產生 API Response 模型 |
| `dart-comment` | 中文註解規範 |
| `flutter-project-knowledge` | 本 Skill，通用架構知識庫 |
