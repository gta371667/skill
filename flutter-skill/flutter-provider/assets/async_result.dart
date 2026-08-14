/// 非同步操作狀態封裝。
///
/// 用於 StateData 中需要追蹤 API 呼叫狀態的欄位。
/// [T] 為成功時的資料型別，[E] 為錯誤訊息型別（通常為 String）。
sealed class AsyncResult<T, E> {
  const AsyncResult();

  /// 初始狀態，尚未發起請求。
  const factory AsyncResult.idle() = _Idle<T, E>;

  /// 請求進行中；可選擇性攜帶上一筆資料（refresh 時保留畫面）。
  const factory AsyncResult.loading({T? data}) = _Loading<T, E>;

  /// 請求成功，攜帶資料；可選擇性帶成功提示訊息 [message]（如「已儲存」）。
  const factory AsyncResult.success({required T data, String? message}) =
      _Success<T, E>;

  /// 請求失敗，攜帶錯誤訊息；可選擇性保留上一筆資料（失敗時仍顯示舊資料）。
  const factory AsyncResult.failure({required E error, T? data}) =
      _Failure<T, E>;
}

/// AsyncResult 的擴充方法，提供狀態轉換快捷方式。
extension AsyncResultX<T, E> on AsyncResult<T, E> {
  /// 轉換至 loading 狀態。
  ///
  /// 預設不保留資料；[keepData] 為 true 時帶上目前的 data，
  /// 讓 refresh 期間畫面仍可顯示舊資料。
  AsyncResult<T, E> loading({bool keepData = false}) =>
      AsyncResult.loading(data: keepData ? dataOrNull : null);

  /// 轉換至 success 狀態；可選擇性帶成功提示訊息 [message]。
  AsyncResult<T, E> setSuccess({required T data, String? message}) =>
      AsyncResult.success(data: data, message: message);

  /// 轉換至 failure 狀態。
  ///
  /// 預設不保留資料；[keepData] 為 true 時帶上目前的 data，
  /// 讓失敗後畫面仍可顯示舊資料。
  AsyncResult<T, E> setError({required E error, bool keepData = false}) =>
      AsyncResult.failure(error: error, data: keepData ? dataOrNull : null);

  bool get isLoading => this is _Loading<T, E>;

  bool get isSuccess => this is _Success<T, E>;

  bool get isFailure => this is _Failure<T, E>;

  /// 是否有可顯示的資料（success，或帶資料的 loading）。
  bool get hasData => dataOrNull != null;

  E? get error => switch (this) {
    _Failure(:final error) => error,
    _ => null,
  };

  /// success 狀態的成功提示訊息（非 success 或未帶訊息時為 null）。
  String? get successMessage => switch (this) {
    _Success(:final message) => message,
    _ => null,
  };

  T? get dataOrNull => switch (this) {
    _Success(:final data) => data,
    _Loading(:final data) => data,
    _Failure(:final data) => data,
    _ => null,
  };
}

class _Idle<T, E> extends AsyncResult<T, E> {
  const _Idle();
}

class _Loading<T, E> extends AsyncResult<T, E> {
  /// 進行中時可選擇性保留的上一筆資料。
  final T? data;

  const _Loading({this.data});
}

class _Success<T, E> extends AsyncResult<T, E> {
  final T data;

  /// 成功後的提示訊息（可為 null）。
  final String? message;

  const _Success({required this.data, this.message});
}

class _Failure<T, E> extends AsyncResult<T, E> {
  final E error;

  /// 失敗時可選擇性保留的上一筆資料。
  final T? data;

  const _Failure({required this.error, this.data});
}
