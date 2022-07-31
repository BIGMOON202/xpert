// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'fields_errors.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

FieldsErrors _$FieldsErrorsFromJson(Map<String, dynamic> json) {
  return _FieldsErrors.fromJson(json);
}

/// @nodoc
mixin _$FieldsErrors {
  List<String>? get name => throw _privateConstructorUsedError;
  List<String>? get email => throw _privateConstructorUsedError;
  List<String>? get phone => throw _privateConstructorUsedError;
  List<String>? get event => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FieldsErrorsCopyWith<FieldsErrors> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FieldsErrorsCopyWith<$Res> {
  factory $FieldsErrorsCopyWith(
          FieldsErrors value, $Res Function(FieldsErrors) then) =
      _$FieldsErrorsCopyWithImpl<$Res>;
  $Res call(
      {List<String>? name,
      List<String>? email,
      List<String>? phone,
      List<String>? event});
}

/// @nodoc
class _$FieldsErrorsCopyWithImpl<$Res> implements $FieldsErrorsCopyWith<$Res> {
  _$FieldsErrorsCopyWithImpl(this._value, this._then);

  final FieldsErrors _value;
  // ignore: unused_field
  final $Res Function(FieldsErrors) _then;

  @override
  $Res call({
    Object? name = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? event = freezed,
  }) {
    return _then(_value.copyWith(
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      email: email == freezed
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      phone: phone == freezed
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      event: event == freezed
          ? _value.event
          : event // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
abstract class _$$_FieldsErrorsCopyWith<$Res>
    implements $FieldsErrorsCopyWith<$Res> {
  factory _$$_FieldsErrorsCopyWith(
          _$_FieldsErrors value, $Res Function(_$_FieldsErrors) then) =
      __$$_FieldsErrorsCopyWithImpl<$Res>;
  @override
  $Res call(
      {List<String>? name,
      List<String>? email,
      List<String>? phone,
      List<String>? event});
}

/// @nodoc
class __$$_FieldsErrorsCopyWithImpl<$Res>
    extends _$FieldsErrorsCopyWithImpl<$Res>
    implements _$$_FieldsErrorsCopyWith<$Res> {
  __$$_FieldsErrorsCopyWithImpl(
      _$_FieldsErrors _value, $Res Function(_$_FieldsErrors) _then)
      : super(_value, (v) => _then(v as _$_FieldsErrors));

  @override
  _$_FieldsErrors get _value => super._value as _$_FieldsErrors;

  @override
  $Res call({
    Object? name = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? event = freezed,
  }) {
    return _then(_$_FieldsErrors(
      name: name == freezed
          ? _value._name
          : name // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      email: email == freezed
          ? _value._email
          : email // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      phone: phone == freezed
          ? _value._phone
          : phone // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      event: event == freezed
          ? _value._event
          : event // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_FieldsErrors implements _FieldsErrors {
  _$_FieldsErrors(
      {final List<String>? name,
      final List<String>? email,
      final List<String>? phone,
      final List<String>? event})
      : _name = name,
        _email = email,
        _phone = phone,
        _event = event;

  factory _$_FieldsErrors.fromJson(Map<String, dynamic> json) =>
      _$$_FieldsErrorsFromJson(json);

  final List<String>? _name;
  @override
  List<String>? get name {
    final value = _name;
    if (value == null) return null;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _email;
  @override
  List<String>? get email {
    final value = _email;
    if (value == null) return null;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _phone;
  @override
  List<String>? get phone {
    final value = _phone;
    if (value == null) return null;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _event;
  @override
  List<String>? get event {
    final value = _event;
    if (value == null) return null;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'FieldsErrors(name: $name, email: $email, phone: $phone, event: $event)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_FieldsErrors &&
            const DeepCollectionEquality().equals(other._name, _name) &&
            const DeepCollectionEquality().equals(other._email, _email) &&
            const DeepCollectionEquality().equals(other._phone, _phone) &&
            const DeepCollectionEquality().equals(other._event, _event));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_name),
      const DeepCollectionEquality().hash(_email),
      const DeepCollectionEquality().hash(_phone),
      const DeepCollectionEquality().hash(_event));

  @JsonKey(ignore: true)
  @override
  _$$_FieldsErrorsCopyWith<_$_FieldsErrors> get copyWith =>
      __$$_FieldsErrorsCopyWithImpl<_$_FieldsErrors>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_FieldsErrorsToJson(this);
  }
}

abstract class _FieldsErrors implements FieldsErrors {
  factory _FieldsErrors(
      {final List<String>? name,
      final List<String>? email,
      final List<String>? phone,
      final List<String>? event}) = _$_FieldsErrors;

  factory _FieldsErrors.fromJson(Map<String, dynamic> json) =
      _$_FieldsErrors.fromJson;

  @override
  List<String>? get name => throw _privateConstructorUsedError;
  @override
  List<String>? get email => throw _privateConstructorUsedError;
  @override
  List<String>? get phone => throw _privateConstructorUsedError;
  @override
  List<String>? get event => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$_FieldsErrorsCopyWith<_$_FieldsErrors> get copyWith =>
      throw _privateConstructorUsedError;
}
