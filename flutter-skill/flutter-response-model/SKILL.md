---
name: flutter-response-model
description: Claude Code Skill — 自動從 API Response JSON 產生 Flutter Equatable 模型檔案
---

# flutter-response-model

> Claude Code Skill — 自動從 API Response JSON 產生 Flutter Equatable 模型檔案

---

## 這個 Skill 做什麼？

將放在 `assets/jsons/response/` 的 API response JSON 檔案，自動轉換成 Flutter 專案使用的 model `.dart` 檔案。`fromJson` / `toJson` 由 `json_serializable` + `build_runner` 產生；`copyWith` 手寫。不需要 Equatable。

---

## 安裝

```bash
claude skill install flutter-response-model.skill
```

---

## 輸出結構

```
lib/bean/
├── bean.dart                          ← 統一 export（自動維護）
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

---

## 生成格式說明

### 欄位規則

- 每個欄位標注 `@JsonKey(name: 'original_key')`（無例外）
- Dart 欄位名一律 lowerCamelCase
- 手寫 `fromJson`、`toJson`、`copyWith`
- `""` 空字串維持 `required String`，只有 JSON 明確 `null` 才用 nullable
- nullable 欄位的 copyWith 用 `clearXxx = false` flag

### JSON → Dart 型別對應

| JSON 型別 | Dart 型別 |
|-----------|-----------|
| `string` | `String` |
| `number` (整數) | `int` |
| `number` (小數) | `double` |
| `boolean` | `bool` |
| `object` | 新的巢狀 class |
| `array of objects` | `List<NestedClass>` |
| `array of primitives` | `List<String>` / `List<int>` 等 |
| `null` | `String?` / `int?` 等 nullable |

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
  }
}
```

### 輸出：`lib/bean/response/login/login_response.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

/// 登入 API Response 模型。
@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'sn')
  final String sn;
  @JsonKey(name: 'truckSn')
  final String truckSn;
  @JsonKey(name: 'token')
  final String token;
  @JsonKey(name: 'appVersion')
  final LoginResponseAppVersion appVersion;
  @JsonKey(name: 'capacity')
  final int capacity;
  @JsonKey(name: 'needChangePassword')
  final bool needChangePassword;

  const LoginResponse({
    required this.sn,
    required this.truckSn,
    required this.token,
    required this.appVersion,
    required this.capacity,
    required this.needChangePassword,
  });

  /// 由 json_serializable 產生
  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  /// 由 json_serializable 產生
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  /// 手寫 copyWith
  LoginResponse copyWith({
    String? sn,
    String? truckSn,
    String? token,
    LoginResponseAppVersion? appVersion,
    int? capacity,
    bool? needChangePassword,
  }) {
    return LoginResponse(
      sn: sn ?? this.sn,
      truckSn: truckSn ?? this.truckSn,
      token: token ?? this.token,
      appVersion: appVersion ?? this.appVersion,
      capacity: capacity ?? this.capacity,
      needChangePassword: needChangePassword ?? this.needChangePassword,
    );
  }

}
```

---

## 特殊情境

| 情況 | 處理方式 |
|------|---------|
| 無 `data` wrapper | 直接用頂層欄位建模 |
| 全大寫 key（`DATA`）| 欄位轉 camelCase + `@JsonKey(name: 'DATA')`，fromJson/toJson 用原始 key |
| 非 camelCase（`toilettype`）| 轉 `toiletType` + `@JsonKey(name: 'toilettype')` |
| 多個 JSON 檔案 | 全部處理完後更新一次 `bean.dart` |

---

## 需要的套件

```yaml
dependencies:
  equatable: ^2.x.x
```

```yaml
dependencies:
  json_annotation: ^4.x.x

dev_dependencies:
  build_runner: ^2.x.x
  json_serializable: ^6.x.x
```

執行一次 build_runner 產生 `.g.dart`：

```bash
dart run build_runner build --delete-conflicting-outputs
```
