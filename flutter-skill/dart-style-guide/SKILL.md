---
name: dart-style-guide
description: 
  Dart 和 Flutter 的程式碼風格規範，涵蓋命名慣例、class 成員排列順序、
  格式化規則、import 排列、註解風格。當使用者詢問 Dart 程式碼應該怎麼寫、
  變數或 class 的命名、成員排列順序、import 怎麼排、或任何 Dart/Flutter 
  程式碼風格相關問題時，優先參照此 Skill。
  也適用於 code review、重構建議、或要求符合 Dart 官方規範的情境。
---

# Dart Style Guide

參考來源：[Effective Dart](https://dart.dev/effective-dart) 官方文件。

---

## 命名慣例

| 類型 | 規則 | 範例 |
|------|------|------|
| Class、Enum、typedef、型別參數 | `UpperCamelCase` | `LoginResponse`、`AsyncResult` |
| 變數、函式、參數、named constructor | `lowerCamelCase` | `loginInfo`、`fromJson` |
| 常數 | `lowerCamelCase`（非 SCREAMING_CAPS） | `defaultTimeout`、`maxRetry` |
| 檔案、資料夾 | `snake_case` | `login_page.dart`、`api_service.dart` |
| Library、package | `snake_case` | `flutter_project_base` |
| Private 成員 | 前綴 `_` | `_loginInfoSubject`、`_request` |

```dart
// ✅ 正確
class LoginResponse {}
const int maxRetry = 3;
void fetchUserData() {}

// ❌ 錯誤
class login_response {}
const int MAX_RETRY = 3;
void FetchUserData() {}
```

---

## Class 成員排列順序

```dart
class MyClass extends ParentClass {
  // 1. 靜態常數
  static const int maxRetry = 3;

  // 2. 靜態變數
  static int instanceCount = 0;

  // 3. 實例變數（final 優先）
  final String id;
  final String name;
  String? description;

  // 4. constructor
  const MyClass({
    required this.id,
    required this.name,
    this.description,
  });

  // 5. named constructor / factory
  factory MyClass.fromJson(Map<String, dynamic> json) => MyClass(
    id: json['id'] as String,
    name: json['name'] as String,
  );

  // 6. getter / setter
  bool get isEmpty => name.isEmpty;

  // 7. 一般方法
  void doSomething() {}

  // 8. override 方法
  @override
  String toString() => 'MyClass(id: $id, name: $name)';

  @override
  List<Object?> get props => [id, name];
}
```

---

## Import 排列順序

```dart
// 1. dart: 開頭
import 'dart:async';
import 'dart:convert';

// 2. package: 開頭（第三方套件）
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 3. 專案內部檔案（相對路徑或 package 路徑）
import 'package:flutter_project_base/data/model/login_response.dart';
import 'package:flutter_project_base/res/my_colors.dart';
```

- 每個群組之間空一行
- 每個群組內按字母排序
- 不混用相對路徑和 package 路徑，統一用 package 路徑

---

## 格式化規則

### 行寬
- 預設 80 字元，可接受 100~120（依團隊設定）
- 使用 `dart format` 自動格式化

### 大括號
```dart
// ✅ 同行開括號
if (condition) {
  doSomething();
}

// ✅ 單行可省略大括號
if (condition) doSomething();

// ❌ 換行開括號
if (condition)
{
  doSomething();
}
```

### 空行
```dart
// class 成員之間空一行
class MyClass {
  final String id;

  const MyClass({required this.id});

  bool get isEmpty => id.isEmpty;

  void doSomething() {}
}
```

### Trailing comma
```dart
// ✅ 多行參數加 trailing comma，dart format 才會正確格式化
const MyWidget(
  child: Text('hello'),
  padding: EdgeInsets.all(8),
);

// ❌ 沒有 trailing comma，dart format 可能壓成一行
const MyWidget(child: Text('hello'), padding: EdgeInsets.all(8));
```

---

## 型別宣告

```dart
// ✅ 明確宣告型別
final String name = 'test';
final List<LoginResponse> responses = [];

// ✅ 型別可推導時可省略
final name = 'test';
final responses = <LoginResponse>[];

// ❌ 不要用 var（除非型別會變動）
var name = 'test';
```

---

## 字串

```dart
// ✅ 字串插值
final message = 'Hello, $name!';
final info = 'User: ${user.name}, ID: ${user.id}';

// ❌ 字串串接
final message = 'Hello, ' + name + '!';
```

---

## 條件判斷

```dart
// ✅ 使用 ?? 處理 null
final name = user?.name ?? '未知';

// ✅ 使用 ?. 安全存取
final length = user?.name.length;

// ✅ 簡單條件用三元運算子
final label = isLoading ? '載入中' : '確認';

// ❌ 不必要的 null 檢查
if (name != null) {
  return name;
} else {
  return '未知';
}
```

---

## Collection

```dart
// ✅ 使用 collection literal
final list = <String>[];
final map = <String, int>{};
final set = <String>{};

// ✅ 使用 collection if / for
final items = [
  'item1',
  if (showExtra) 'item2',
  for (final item in extraItems) item,
];

// ❌ 不必要的建構子
final list = List<String>();
```

---

## 函式

```dart
// ✅ 單行函式用 => 
String get fullName => '$firstName $lastName';
bool isValid(String value) => value.isNotEmpty;

// ✅ 具名參數（超過 2 個參數建議用具名參數）
void login({
  required String account,
  required String password,
}) {}

// ❌ 位置參數超過 2 個不易閱讀
void login(String account, String password, bool rememberMe) {}
```

---

## Async

```dart
// ✅ 使用 async/await
Future<LoginResponse> login() async {
  final response = await _request.login();
  return response;
}

// ❌ 不必要的 .then()
Future<LoginResponse> login() {
  return _request.login().then((response) => response);
}
```

---

## 避免的寫法

```dart
// ❌ 不必要的 this.
this.name = name; // 只有命名衝突時才需要

// ❌ 不必要的 new
final user = new User(); // Dart 2 之後不需要 new

// ❌ 不必要的 return null
String? getName() {
  return null; // 直接省略 return 即可
}

// ❌ 空的 catch
try {
  doSomething();
} catch (e) {} // 至少要 log 錯誤
```
