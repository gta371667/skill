---
name: flutter-image-gen-skill
description: Claude Code Skill — 自動掃描 assets/images/ 產生 Flutter 圖片路徑管理檔案
---

# flutter-image-gen

> Claude Code Skill — 自動掃描 assets/images/ 產生 Flutter 圖片路徑管理檔案

---

## 這個 Skill 做什麼？

掃描 `assets/images/` 目錄下的所有圖片，自動產生統一管理路徑的 `lib/res/my_images.dart`，並確認 `pubspec.yaml` 已正確引入圖片資源。

---

## 安裝

```bash
claude skill install flutter-image-gen.skill
```

---

## 使用方式

```
產生圖片路徑
```

```
更新 my_images
```

```
掃描 assets/images/ 的圖片
```

---

## 流程說明

### Step 1 — 檢查 pubspec.yaml

確認 `pubspec.yaml` 已包含：

```yaml
flutter:
  assets:
    - assets/images/
```

若未包含，會提示使用者手動新增後再執行。

### Step 2 — 掃描圖片

遞迴掃描 `assets/images/` 目錄，支援副檔名：

```
.png  .jpg  .jpeg  .gif  .webp  .svg
```

### Step 3 — 產生變數名稱

檔名（不含副檔名）轉換為 lowerCamelCase：

| 檔名 | 變數名稱 |
|------|---------|
| `ic_logo.png` | `icLogo` |
| `splash_logo.png` | `splashLogo` |
| `home_banner.png` | `homeBanner` |
| `onboarding_1.png` | `onboarding1` |
| `empty_state.png` | `emptyState` |

### Step 4 — 自動分組歸類

依照**子目錄名稱**或**檔名前綴**自動歸類：

| 前綴 / 子目錄 | 群組 |
|--------------|------|
| `ic_` | 獨立置頂（無群組標題）|
| `app_`、`logo_`、無明確前綴 | Common |
| `splash_` | Splash |
| `home_` | Home |
| `onboarding_` | Onboarding |
| `empty_`、`error_` | Error / Empty |
| 子目錄名稱 | 以目錄名稱為群組 |

群組順序：Common 優先，其餘按字母排序。同群組內的圖片按字母排序。

### Step 5 — 輸出 my_images.dart

覆寫 `lib/res/my_images.dart`（已存在則直接覆蓋）。

---

## 輸出範例

**`assets/images/` 內容：**

```
assets/images/
├── ic_logo.png
├── app_logo.png
├── placeholder.png
├── splash_logo.png
├── home_banner.png
├── onboarding_1.png
├── onboarding_2.png
├── onboarding_3.png
├── empty_state.png
└── error_state.png
```

**產生的 `lib/res/my_images.dart`：**

```dart
/// 統一管理 assets 圖片路徑
class MyImages {
  MyImages._();

  static const String icLogo = 'assets/images/ic_logo.png';

  // ── Common ───────────────────────────────────────────────────────
  static const String appLogo = 'assets/images/app_logo.png';
  static const String placeholder = 'assets/images/placeholder.png';

  // ── Splash ───────────────────────────────────────────────────────
  static const String splashLogo = 'assets/images/splash_logo.png';

  // ── Home ─────────────────────────────────────────────────────────
  static const String homeBanner = 'assets/images/home_banner.png';

  // ── Onboarding ───────────────────────────────────────────────────
  static const String onboarding1 = 'assets/images/onboarding_1.png';
  static const String onboarding2 = 'assets/images/onboarding_2.png';
  static const String onboarding3 = 'assets/images/onboarding_3.png';

  // ── Error / Empty ────────────────────────────────────────────────
  static const String emptyState = 'assets/images/empty_state.png';
  static const String errorState = 'assets/images/error_state.png';
}
```

---

## Edge Cases

| 情況 | 處理方式 |
|------|---------|
| `assets/images/` 無圖片 | 產生空的 `MyImages` 類別並提示使用者 |
| 變數名稱衝突（不同路徑同檔名）| 加上群組前綴，例如 `homeLogo`、`splashLogo` |
| `my_images.dart` 已存在 | 直接覆蓋，不詢問 |
| 非圖片檔案 | 略過 |
| 子目錄內有子目錄 | 以最近一層目錄名稱為群組 |
