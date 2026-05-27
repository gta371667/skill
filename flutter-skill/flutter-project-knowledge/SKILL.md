---
name: flutter-project-knowledge
description: Claude Code Skill — Flutter 專案通用架構知識庫，適用於所有採用相同技術棧的專案
---

# flutter-project-knowledge

> Claude Code Skill — Flutter 專案通用架構知識庫，適用於所有採用相同技術棧的專案

---

## 這個 Skill 做什麼？

將 Flutter 專案的架構規範、資料夾結構、開發流程內建給 Claude Code，讓它在開發時直接做出符合規範的決策。

---

## 安裝

```bash
claude skill install flutter-project-knowledge.skill
```

---

## 技術棧

| 類別 | 套件 |
|------|------|
| 狀態管理 | `flutter_bloc` + `equatable` |
| 網路請求 | `dio` |
| 路由 | `go_router` |
| UI 縮放 | `flutter_screenutil` |
| 多語系 | `flutter_localizations` |
| 程式碼生成 | 不需要（Equatable 不需 build_runner）|

---

## 標準資料夾結構

```
lib/
├── main.dart
├── bean/
│   ├── bean.dart
│   └── response/
│       └── {name}/
│           └── {name}_response.dart
├── core/
│   ├── constants/
│   ├── network/
│   │   ├── dio_client.dart
│   │   ├── async_result.dart
│   │   ├── interceptors/
│   │   └── verify/
│   └── theme/
├── data/
│   ├── extension/
│   ├── models/
│   ├── repository/
│   │   ├── repository.dart
│   │   └── {name}/
│   │       ├── {name}_repository.dart
│   │       └── impl/
│   ├── request/
│   └── service/
├── l10n/
├── page/
│   ├── blocs/
│   ├── pages/
│   │   └── {page_name}/
│   │       ├── {page_name}_page.dart
│   │       ├── bloc/
│   │       ├── model/          ← 頁面專屬 model（有需要才建立）
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
└─────────────────┬────────────────────┘
                  │
┌─────────────────▼────────────────────┐
│           資料層 (data/)             │
│   Repository Interface               │
│   Repository Impl ← Request         │
└─────────────────┬────────────────────┘
                  │
┌─────────────────▼────────────────────┐
│          核心層 (core/)              │
│   DioClient → Interceptors           │
└──────────────────────────────────────┘
```

---

## 新增頁面標準流程

1. `lib/page/pages/` 建立 `{name}/`
2. 建立 `{name}_page.dart`
3. 用 `flutter-bloc` Skill 在 `bloc/` 生成三個 BLoC 檔案
4. 頁面專屬小元件放 `widget/`
5. 頁面專屬 model 放 `model/`（有需要才建立）
6. `app_router.dart` 新增路徑常數與 `GoRoute`

---

## 新增 Repository 流程

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

- **單一扁平 State**，不用 sealed variants，不用 StateData
- 所有欄位直接放在 `{Name}PageState`，用 `isLoading` 表示載入狀態
- Event 為 `sealed class`，預設**不繼承 Equatable**（有需要再自行加）
- State 繼承 `Equatable`，手寫 `copyWith`
- emit 直接用 `state.copyWith(...)`，不需型別判斷
- 頁面專屬 model 放 `model/`，與 `bloc/` 同層

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
      ..add(const SomeStartedEvent()),
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

## Import 規範

```dart
// ❌ 禁止跨目錄相對路徑
import '../../../../bean/bean.dart';

// ✅ 正確（跨目錄）
import 'package:your_app/bean/bean.dart';

// ✅ 正確（同層級）
import 'bean.dart';
```

| 情況 | 寫法 |
|------|------|
| 跨任何目錄 | `package:your_app/...` |
| 同層級檔案 | `'filename.dart'` |
| `part of` 指令 | 不受限制 |

---

## UI 撰寫規範

### flutter_screenutil 尺寸規範

```dart
// ❌ 禁止裸數字
Container(width: 100, height: 48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)))

// ✅ 正確
Container(width: 100.w, height: 48.h, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)))
```

| 用途 | 寫法 |
|------|------|
| 寬度 | `.w` |
| 高度 | `.h` |
| 圓角 | `.r` |
| 字體大小 | `.sp` |

### 顏色規範

```dart
// ❌ 禁止
color: Color(0xff212121)

// ✅ 正確 — 先加到 lib/res/my_colors.dart，依色系歸類
color: MyColors.textPrimary
```

---

## 程式碼風格規範

所有 Dart 程式碼請同時參照以下兩個 Skill：

| Skill | 涵蓋範圍 |
|-------|---------|
| `dart-style-guide` | 命名慣例、class 成員排列順序、import 排序、格式化、型別宣告、async 寫法 |
| `dart-comment` | 中文 Dart Doc（`///`）與 inline（`//`）註解規範 |

### dart-style-guide 重點摘要

**命名**

| 類型 | 規則 | 範例 |
|------|------|------|
| Class、Enum | `UpperCamelCase` | `LoginResponse` |
| 變數、函式、參數 | `lowerCamelCase` | `loginInfo` |
| 常數 | `lowerCamelCase`（非 SCREAMING_CAPS）| `defaultTimeout` |
| 檔案、資料夾 | `snake_case` | `login_page.dart` |

**Class 成員排列順序**

```
1. 靜態常數
2. 靜態變數
3. 實例變數（final 優先）
4. constructor
5. named constructor / factory
6. getter / setter
7. 一般方法
8. override 方法
```

**其他重點**
- Import 排序：`dart:` → `package:`（第三方）→ 專案內部，群組間空一行
- 明確宣告型別，避免 `var`
- 超過 2 個參數改用具名參數
- 多行參數一律加 trailing comma
- 避免不必要的 `this.`、`new`、空的 `catch`

---

## 常用指令

```bash
# 重新生成多語系
flutter gen-l10n

# 格式化程式碼
dart format .
```

---

## 相關 Skill

| Skill | 用途 |
|-------|------|
| `flutter-bloc` | 產生 BLoC 三個檔案 |
| `flutter-response-model` | 產生 API Response 模型 |
| `dart-style-guide` | Dart 程式碼風格規範 |
| `dart-comment` | 中文註解規範 |
| `flutter-image-gen` | 產生圖片路徑管理檔案 |
| `git-readonly` | 禁止 git 寫入操作 |
