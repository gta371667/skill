# flutter-freezed-response

> Claude Code Skill — 自動從 API Response JSON 產生 Flutter Freezed 模型檔案

---

## 這個 Skill 做什麼？

將放在 `assets/jsons/response/` 的 API response JSON 檔案，自動轉換成 Flutter 專案使用的 Freezed model `.dart` 檔案，並執行 `build_runner` 完成程式碼生成。

---

## 安裝

```bash
claude skill install flutter-freezed-response.skill
```

---

## 使用方式

將 JSON 檔案放到專案的 `assets/jsons/response/` 目錄下，然後告訴 Claude Code：

```
幫我從 assets/jsons/response/ 生成 Response 模型
```

---

## 輸出結構

每個 `{name}.json` 會產生一個 response 檔案，並自動更新 `lib/bean/bean.dart`：

```
lib/bean/
├── bean.dart                          ← 統一 export 所有 response（自動維護）
└── response/
    ├── login/
    │   └── login_response.dart
    └── toilet/
        └── toilet_response.dart
```

| 項目 | 路徑 |
|------|------|
| Response 檔案 | `lib/bean/response/{name}/{name}_response.dart` |
| 共用 Export 檔 | `lib/bean/bean.dart` |

### `bean.dart` 範例

```dart
export 'response/login/login_response.dart';
export 'response/toilet/toilet_response.dart';
```

> 每新增一個 JSON，Skill 會自動在 `bean.dart` 補上對應的 export，不會覆蓋現有內容。

---

## 生成格式說明

### 欄位規則

- **每個欄位都加 `@JsonKey(name: 'original_key')`**，無例外
- **Dart 欄位名一律 lowerCamelCase**（JSON key 如有需要會自動轉換）
- **巢狀物件**自動拆成獨立的 `@freezed sealed class`，命名為 `{Parent}{NestedName}`
- **空字串 `""` 維持 `required String`**，只有 JSON 明確是 `null` 才用 nullable（`String?`）

### JSON → Dart 型別對應

| JSON 型別 | Dart 型別 |
|-----------|-----------|
| `string` | `String` |
| `number` (整數) | `int` |
| `number` (小數) | `double` |
| `boolean` | `bool` |
| `object` | 新的巢狀 `@freezed` class |
| `array of objects` | `List<NestedClass>` |
| `array of primitives` | `List<String>` / `List<int>` 等 |
| `null` | `String?` / `int?` 等 nullable 型別 |

---

## 範例

### 輸入：`assets/jsons/response/login.json`

```json
{
  "data": {
    "sn": "aa891669-...",
    "truckSn": "694d70ef-...",
    "token": "eyJ...",
    "appVersion": {
      "versionCode": "1.0.4",
      "date": "2026-04-07T15:11:00",
      "downloadUrl": "https://..."
    },
    "capacity": 5,
    "needChangePassword": false
  },
  "isSuccess": true,
  "message": ""
}
```

> `isSuccess`、`message` 等 envelope 欄位會被忽略，只處理 `data` 內容。

### 輸出 1：`lib/bean/response/login/login_response.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

@freezed
sealed class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    @JsonKey(name: 'sn') required String sn,
    @JsonKey(name: 'truckSn') required String truckSn,
    @JsonKey(name: 'token') required String token,
    @JsonKey(name: 'appVersion') required LoginResponseAppVersion appVersion,
    @JsonKey(name: 'capacity') required int capacity,
    @JsonKey(name: 'needChangePassword') required bool needChangePassword,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

@freezed
sealed class LoginResponseAppVersion with _$LoginResponseAppVersion {
  const factory LoginResponseAppVersion({
    @JsonKey(name: 'versionCode') required String versionCode,
    @JsonKey(name: 'date') required String date,
    @JsonKey(name: 'downloadUrl') required String downloadUrl,
  }) = _LoginResponseAppVersion;

  factory LoginResponseAppVersion.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseAppVersionFromJson(json);
}
```

### 輸出 2：`lib/bean/bean.dart`（自動新增 export）

```dart
export 'response/login/login_response.dart';
```

---

## 特殊情境處理

### 無 `data` wrapper（扁平結構）
若 JSON 頂層沒有 `data` 欄位，直接以所有頂層欄位建模。

### 全大寫 key（如政府 API）
```json
{ "DATA": [...], "STATUS": "1" }
```
自動轉換：`DATA` → Dart 欄位 `data`，並加上 `@JsonKey(name: 'DATA')`。

### key 含小寫但非 camelCase
```json
{ "toilettype": "男廁所", "pictype": "1" }
```
自動轉換：`toilettype` → `toiletType`，`pictype` → `picType`。

### 多個 JSON 檔案
一次給多個 JSON 檔，Skill 會全部處理完後只執行一次 `build_runner`，並在 `bean.dart` 補上所有新增的 export。

---

## 執行 build_runner

所有檔案產生完畢後，Skill 會自動執行：

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 需要的 Flutter 套件

```yaml
dependencies:
  freezed_annotation: ^2.x.x

dev_dependencies:
  build_runner: ^2.x.x
  freezed: ^2.x.x
  json_serializable: ^6.x.x
```
