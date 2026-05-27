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

- **單一扁平 State**，不用 sealed variants，不用 StateData
- 所有欄位直接放在 `{Name}PageState`，用 `isLoading` 表示載入狀態
- Event 為 `sealed class`，不繼承 Equatable（有需要再自行加）
- State 繼承 `Equatable`，手寫 `copyWith`
- emit 直接用 `state.copyWith(...)`，不需型別判斷

---

## Import 規範

```dart
// ❌ 禁止跨目錄相對路徑
import '../../../../bean/bean.dart';

// ✅ 正確
import 'package:your_app/bean/bean.dart';

// ✅ 同層級才可用相對路徑
import 'bean.dart';
```

---

## UI 撰寫規範

### flutter_screenutil

```dart
// ❌ 禁止裸數字
width: 100, height: 48, BorderRadius.circular(12)

// ✅ 正確
width: 100.w, height: 48.h, BorderRadius.circular(12.r)
```

| 用途 | 寫法 |
|------|------|
| 寬度 | `.w` |
| 高度 | `.h` |
| 圓角 | `.r` |
| 字體 | `.sp` |

### 顏色規範

```dart
// ❌ 禁止
color: Color(0xff212121)

// ✅ 正確 — 先加到 lib/res/my_colors.dart，依色系歸類
color: MyColors.textPrimary
```

---

## 常用指令

```bash
# 重新生成多語系
flutter gen-l10n
```

---

## 相關 Skill

| Skill | 用途 |
|-------|------|
| `flutter-bloc` | 產生 BLoC 三個檔案 |
| `flutter-response-model` | 產生 API Response 模型 |
| `dart-comment` | 中文註解規範 |
| `flutter-image-gen` | 產生圖片路徑管理檔案 |
| `git-readonly` | 禁止 git 寫入操作 |
