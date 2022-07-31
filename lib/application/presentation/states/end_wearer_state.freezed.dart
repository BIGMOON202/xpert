// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'end_wearer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$EWState {
  EWAddToEventState get addToEventState => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $EWStateCopyWith<EWState> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EWStateCopyWith<$Res> {
  factory $EWStateCopyWith(EWState value, $Res Function(EWState) then) =
      _$EWStateCopyWithImpl<$Res>;
  $Res call({EWAddToEventState addToEventState});

  $EWAddToEventStateCopyWith<$Res> get addToEventState;
}

/// @nodoc
class _$EWStateCopyWithImpl<$Res> implements $EWStateCopyWith<$Res> {
  _$EWStateCopyWithImpl(this._value, this._then);

  final EWState _value;
  // ignore: unused_field
  final $Res Function(EWState) _then;

  @override
  $Res call({
    Object? addToEventState = freezed,
  }) {
    return _then(_value.copyWith(
      addToEventState: addToEventState == freezed
          ? _value.addToEventState
          : addToEventState // ignore: cast_nullable_to_non_nullable
              as EWAddToEventState,
    ));
  }

  @override
  $EWAddToEventStateCopyWith<$Res> get addToEventState {
    return $EWAddToEventStateCopyWith<$Res>(_value.addToEventState, (value) {
      return _then(_value.copyWith(addToEventState: value));
    });
  }
}

/// @nodoc
abstract class _$$_EWStateCopyWith<$Res> implements $EWStateCopyWith<$Res> {
  factory _$$_EWStateCopyWith(
          _$_EWState value, $Res Function(_$_EWState) then) =
      __$$_EWStateCopyWithImpl<$Res>;
  @override
  $Res call({EWAddToEventState addToEventState});

  @override
  $EWAddToEventStateCopyWith<$Res> get addToEventState;
}

/// @nodoc
class __$$_EWStateCopyWithImpl<$Res> extends _$EWStateCopyWithImpl<$Res>
    implements _$$_EWStateCopyWith<$Res> {
  __$$_EWStateCopyWithImpl(_$_EWState _value, $Res Function(_$_EWState) _then)
      : super(_value, (v) => _then(v as _$_EWState));

  @override
  _$_EWState get _value => super._value as _$_EWState;

  @override
  $Res call({
    Object? addToEventState = freezed,
  }) {
    return _then(_$_EWState(
      addToEventState: addToEventState == freezed
          ? _value.addToEventState
          : addToEventState // ignore: cast_nullable_to_non_nullable
              as EWAddToEventState,
    ));
  }
}

/// @nodoc

class _$_EWState implements _EWState {
  _$_EWState({required this.addToEventState});

  @override
  final EWAddToEventState addToEventState;

  @override
  String toString() {
    return 'EWState(addToEventState: $addToEventState)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_EWState &&
            const DeepCollectionEquality()
                .equals(other.addToEventState, addToEventState));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(addToEventState));

  @JsonKey(ignore: true)
  @override
  _$$_EWStateCopyWith<_$_EWState> get copyWith =>
      __$$_EWStateCopyWithImpl<_$_EWState>(this, _$identity);
}

abstract class _EWState implements EWState {
  factory _EWState({required final EWAddToEventState addToEventState}) =
      _$_EWState;

  @override
  EWAddToEventState get addToEventState => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$_EWStateCopyWith<_$_EWState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$EWAddToEventState {
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isSuccess => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  FieldsErrors? get errors => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $EWAddToEventStateCopyWith<EWAddToEventState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EWAddToEventStateCopyWith<$Res> {
  factory $EWAddToEventStateCopyWith(
          EWAddToEventState value, $Res Function(EWAddToEventState) then) =
      _$EWAddToEventStateCopyWithImpl<$Res>;
  $Res call(
      {bool isLoading,
      bool isSuccess,
      String? name,
      String? email,
      String? phone,
      String? errorMessage,
      FieldsErrors? errors});

  $FieldsErrorsCopyWith<$Res>? get errors;
}

/// @nodoc
class _$EWAddToEventStateCopyWithImpl<$Res>
    implements $EWAddToEventStateCopyWith<$Res> {
  _$EWAddToEventStateCopyWithImpl(this._value, this._then);

  final EWAddToEventState _value;
  // ignore: unused_field
  final $Res Function(EWAddToEventState) _then;

  @override
  $Res call({
    Object? isLoading = freezed,
    Object? isSuccess = freezed,
    Object? name = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? errorMessage = freezed,
    Object? errors = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: isLoading == freezed
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSuccess: isSuccess == freezed
          ? _value.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      email: email == freezed
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: phone == freezed
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: errorMessage == freezed
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      errors: errors == freezed
          ? _value.errors
          : errors // ignore: cast_nullable_to_non_nullable
              as FieldsErrors?,
    ));
  }

  @override
  $FieldsErrorsCopyWith<$Res>? get errors {
    if (_value.errors == null) {
      return null;
    }

    return $FieldsErrorsCopyWith<$Res>(_value.errors!, (value) {
      return _then(_value.copyWith(errors: value));
    });
  }
}

/// @nodoc
abstract class _$$_EWAddToEventStateCopyWith<$Res>
    implements $EWAddToEventStateCopyWith<$Res> {
  factory _$$_EWAddToEventStateCopyWith(_$_EWAddToEventState value,
          $Res Function(_$_EWAddToEventState) then) =
      __$$_EWAddToEventStateCopyWithImpl<$Res>;
  @override
  $Res call(
      {bool isLoading,
      bool isSuccess,
      String? name,
      String? email,
      String? phone,
      String? errorMessage,
      FieldsErrors? errors});

  @override
  $FieldsErrorsCopyWith<$Res>? get errors;
}

/// @nodoc
class __$$_EWAddToEventStateCopyWithImpl<$Res>
    extends _$EWAddToEventStateCopyWithImpl<$Res>
    implements _$$_EWAddToEventStateCopyWith<$Res> {
  __$$_EWAddToEventStateCopyWithImpl(
      _$_EWAddToEventState _value, $Res Function(_$_EWAddToEventState) _then)
      : super(_value, (v) => _then(v as _$_EWAddToEventState));

  @override
  _$_EWAddToEventState get _value => super._value as _$_EWAddToEventState;

  @override
  $Res call({
    Object? isLoading = freezed,
    Object? isSuccess = freezed,
    Object? name = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? errorMessage = freezed,
    Object? errors = freezed,
  }) {
    return _then(_$_EWAddToEventState(
      isLoading: isLoading == freezed
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSuccess: isSuccess == freezed
          ? _value.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      email: email == freezed
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: phone == freezed
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: errorMessage == freezed
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      errors: errors == freezed
          ? _value.errors
          : errors // ignore: cast_nullable_to_non_nullable
              as FieldsErrors?,
    ));
  }
}

/// @nodoc

class _$_EWAddToEventState implements _EWAddToEventState {
  _$_EWAddToEventState(
      {this.isLoading = false,
      this.isSuccess = false,
      this.name,
      this.email,
      this.phone,
      this.errorMessage,
      this.errors});

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isSuccess;
  @override
  final String? name;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final String? errorMessage;
  @override
  final FieldsErrors? errors;

  @override
  String toString() {
    return 'EWAddToEventState(isLoading: $isLoading, isSuccess: $isSuccess, name: $name, email: $email, phone: $phone, errorMessage: $errorMessage, errors: $errors)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_EWAddToEventState &&
            const DeepCollectionEquality().equals(other.isLoading, isLoading) &&
            const DeepCollectionEquality().equals(other.isSuccess, isSuccess) &&
            const DeepCollectionEquality().equals(other.name, name) &&
            const DeepCollectionEquality().equals(other.email, email) &&
            const DeepCollectionEquality().equals(other.phone, phone) &&
            const DeepCollectionEquality()
                .equals(other.errorMessage, errorMessage) &&
            const DeepCollectionEquality().equals(other.errors, errors));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(isLoading),
      const DeepCollectionEquality().hash(isSuccess),
      const DeepCollectionEquality().hash(name),
      const DeepCollectionEquality().hash(email),
      const DeepCollectionEquality().hash(phone),
      const DeepCollectionEquality().hash(errorMessage),
      const DeepCollectionEquality().hash(errors));

  @JsonKey(ignore: true)
  @override
  _$$_EWAddToEventStateCopyWith<_$_EWAddToEventState> get copyWith =>
      __$$_EWAddToEventStateCopyWithImpl<_$_EWAddToEventState>(
          this, _$identity);
}

abstract class _EWAddToEventState implements EWAddToEventState {
  factory _EWAddToEventState(
      {final bool isLoading,
      final bool isSuccess,
      final String? name,
      final String? email,
      final String? phone,
      final String? errorMessage,
      final FieldsErrors? errors}) = _$_EWAddToEventState;

  @override
  bool get isLoading => throw _privateConstructorUsedError;
  @override
  bool get isSuccess => throw _privateConstructorUsedError;
  @override
  String? get name => throw _privateConstructorUsedError;
  @override
  String? get email => throw _privateConstructorUsedError;
  @override
  String? get phone => throw _privateConstructorUsedError;
  @override
  String? get errorMessage => throw _privateConstructorUsedError;
  @override
  FieldsErrors? get errors => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$_EWAddToEventStateCopyWith<_$_EWAddToEventState> get copyWith =>
      throw _privateConstructorUsedError;
}
