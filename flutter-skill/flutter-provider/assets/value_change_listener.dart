import 'package:flutter/widgets.dart';

/// 監聽任意型別的值，當其符合觸發條件時執行一次性動作。
///
/// 這是 Provider 架構下對應 BLoC `BlocListener` 的元件：
/// 不重建子 Widget（[child] 原樣回傳），只在值變化時執行 side effect，
/// 常見情境為「撈完 API 後把回傳值填入 [TextEditingController]」。
///
/// 使用時通常搭配 `Consumer` / `context.watch`，把 state 的值傳入 [value]；
/// 外層重建帶入新的 [value] 後，[didUpdateWidget] 會比對並決定是否觸發 [onChanged]。
///
/// 範例：
/// ```dart
/// Consumer<EditProfilePageNotifier>(
///   builder: (context, notifier, _) {
///     return ValueChangeListener<Profile?>(
///       value: notifier.state.profile.dataOrNull,
///       // 只在第一次拿到資料時設值，避免 refresh 覆蓋使用者輸入
///       listenWhen: (previous, current) => previous == null && current != null,
///       onChanged: (profile) {
///         if (profile != null) _nameController.text = profile.name;
///       },
///       child: TextField(controller: _nameController),
///     );
///   },
/// )
/// ```
class ValueChangeListener<T> extends StatefulWidget {
  /// 要監聽的值。
  final T value;

  /// 值符合觸發條件時執行的動作（對應 BlocListener 的 listener）。
  final void Function(T value) onChanged;

  /// 自訂觸發條件（對應 BlocListener 的 listenWhen）。
  ///
  /// 回傳 `true` 才會執行 [onChanged]。
  /// 預設為 `previous != current`，即值有變化就觸發。
  final bool Function(T previous, T current)? listenWhen;

  /// 子 Widget，不會因為 [value] 變化而重建。
  final Widget child;

  const ValueChangeListener({
    super.key,
    required this.value,
    required this.onChanged,
    this.listenWhen,
    required this.child,
  });

  @override
  State<ValueChangeListener<T>> createState() => _ValueChangeListenerState<T>();
}

class _ValueChangeListenerState<T> extends State<ValueChangeListener<T>> {
  @override
  void didUpdateWidget(ValueChangeListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 有傳 listenWhen 就用自訂條件，否則預設用 != 比較
    final shouldTrigger =
        widget.listenWhen?.call(oldWidget.value, widget.value) ??
            (widget.value != oldWidget.value);

    if (shouldTrigger) {
      widget.onChanged(widget.value);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
