import 'dart:async';

extension ObjectExtension<T> on T {
  K convert<K>(K Function(T value) op) {
    return op(this);
  }

  Future<void> let(FutureOr<void> Function(T value) op) async {
    await op(this);
  }
}
