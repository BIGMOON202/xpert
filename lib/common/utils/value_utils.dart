abstract class Late<T> {
  bool _initialized = false;

  T get value => _valueInternal;

  set value(T value) {
    _storeValueInternal(value);

    if (!_initialized) {
      _initialized = true;
    }
  }

  bool get initialized => _initialized;

  T get _valueInternal;

  void _storeValueInternal(T value);
}

abstract class OptionalLate<T> {
  bool _initialized = false;

  T? get value => _valueInternal;

  set value(T? value) {
    _storeValueInternal(value);

    if (!_initialized) {
      _initialized = true;
    }
  }

  bool get initialized => _initialized;

  T? get _valueInternal;

  void _storeValueInternal(T? value);
}

class LateValue<T> extends Late<T> {
  late T _value;

  @override
  void _storeValueInternal(T value) {
    _value = value;
  }

  @override
  T get _valueInternal => _value;
}

class OptionalLateValue<T> extends OptionalLate<T?> {
  late T? _value;

  @override
  void _storeValueInternal(T? value) {
    _value = value;
  }

  @override
  T? get _valueInternal => _value;
}

class LateFinalValue<T> extends Late<T> {
  late final T _value;

  @override
  void _storeValueInternal(T value) {
    _value = value;
  }

  @override
  T get _valueInternal => _value;
}

class LateFinalAutoValue<T> extends LateFinalValue<T> {
  final T Function() initializer;

  LateFinalAutoValue(this.initializer);

  @override
  @Deprecated('Uses initializer instead')
  set value(T value) {}

  @override
  T get value {
    if (!initialized) {
      super.value = initializer.call();
    }

    return super._value;
  }
}
