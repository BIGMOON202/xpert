// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'events_page_options_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$EventsPageOptionsState {
  bool get isLoading => throw _privateConstructorUsedError;
  Response<Tuple2<EventList, MeasurementsList>>? get response =>
      throw _privateConstructorUsedError;
  EventList? get filteredEvents => throw _privateConstructorUsedError;
  EventList? get originalEvents => throw _privateConstructorUsedError;
  int get originalEventsCount => throw _privateConstructorUsedError;
  int get filteredEventsCount => throw _privateConstructorUsedError;
  String? get searchText => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $EventsPageOptionsStateCopyWith<EventsPageOptionsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventsPageOptionsStateCopyWith<$Res> {
  factory $EventsPageOptionsStateCopyWith(EventsPageOptionsState value,
          $Res Function(EventsPageOptionsState) then) =
      _$EventsPageOptionsStateCopyWithImpl<$Res>;
  $Res call(
      {bool isLoading,
      Response<Tuple2<EventList, MeasurementsList>>? response,
      EventList? filteredEvents,
      EventList? originalEvents,
      int originalEventsCount,
      int filteredEventsCount,
      String? searchText});
}

/// @nodoc
class _$EventsPageOptionsStateCopyWithImpl<$Res>
    implements $EventsPageOptionsStateCopyWith<$Res> {
  _$EventsPageOptionsStateCopyWithImpl(this._value, this._then);

  final EventsPageOptionsState _value;
  // ignore: unused_field
  final $Res Function(EventsPageOptionsState) _then;

  @override
  $Res call({
    Object? isLoading = freezed,
    Object? response = freezed,
    Object? filteredEvents = freezed,
    Object? originalEvents = freezed,
    Object? originalEventsCount = freezed,
    Object? filteredEventsCount = freezed,
    Object? searchText = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: isLoading == freezed
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      response: response == freezed
          ? _value.response
          : response // ignore: cast_nullable_to_non_nullable
              as Response<Tuple2<EventList, MeasurementsList>>?,
      filteredEvents: filteredEvents == freezed
          ? _value.filteredEvents
          : filteredEvents // ignore: cast_nullable_to_non_nullable
              as EventList?,
      originalEvents: originalEvents == freezed
          ? _value.originalEvents
          : originalEvents // ignore: cast_nullable_to_non_nullable
              as EventList?,
      originalEventsCount: originalEventsCount == freezed
          ? _value.originalEventsCount
          : originalEventsCount // ignore: cast_nullable_to_non_nullable
              as int,
      filteredEventsCount: filteredEventsCount == freezed
          ? _value.filteredEventsCount
          : filteredEventsCount // ignore: cast_nullable_to_non_nullable
              as int,
      searchText: searchText == freezed
          ? _value.searchText
          : searchText // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$$_EventsPageOptionsStateCopyWith<$Res>
    implements $EventsPageOptionsStateCopyWith<$Res> {
  factory _$$_EventsPageOptionsStateCopyWith(_$_EventsPageOptionsState value,
          $Res Function(_$_EventsPageOptionsState) then) =
      __$$_EventsPageOptionsStateCopyWithImpl<$Res>;
  @override
  $Res call(
      {bool isLoading,
      Response<Tuple2<EventList, MeasurementsList>>? response,
      EventList? filteredEvents,
      EventList? originalEvents,
      int originalEventsCount,
      int filteredEventsCount,
      String? searchText});
}

/// @nodoc
class __$$_EventsPageOptionsStateCopyWithImpl<$Res>
    extends _$EventsPageOptionsStateCopyWithImpl<$Res>
    implements _$$_EventsPageOptionsStateCopyWith<$Res> {
  __$$_EventsPageOptionsStateCopyWithImpl(_$_EventsPageOptionsState _value,
      $Res Function(_$_EventsPageOptionsState) _then)
      : super(_value, (v) => _then(v as _$_EventsPageOptionsState));

  @override
  _$_EventsPageOptionsState get _value =>
      super._value as _$_EventsPageOptionsState;

  @override
  $Res call({
    Object? isLoading = freezed,
    Object? response = freezed,
    Object? filteredEvents = freezed,
    Object? originalEvents = freezed,
    Object? originalEventsCount = freezed,
    Object? filteredEventsCount = freezed,
    Object? searchText = freezed,
  }) {
    return _then(_$_EventsPageOptionsState(
      isLoading: isLoading == freezed
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      response: response == freezed
          ? _value.response
          : response // ignore: cast_nullable_to_non_nullable
              as Response<Tuple2<EventList, MeasurementsList>>?,
      filteredEvents: filteredEvents == freezed
          ? _value.filteredEvents
          : filteredEvents // ignore: cast_nullable_to_non_nullable
              as EventList?,
      originalEvents: originalEvents == freezed
          ? _value.originalEvents
          : originalEvents // ignore: cast_nullable_to_non_nullable
              as EventList?,
      originalEventsCount: originalEventsCount == freezed
          ? _value.originalEventsCount
          : originalEventsCount // ignore: cast_nullable_to_non_nullable
              as int,
      filteredEventsCount: filteredEventsCount == freezed
          ? _value.filteredEventsCount
          : filteredEventsCount // ignore: cast_nullable_to_non_nullable
              as int,
      searchText: searchText == freezed
          ? _value.searchText
          : searchText // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$_EventsPageOptionsState implements _EventsPageOptionsState {
  _$_EventsPageOptionsState(
      {this.isLoading = false,
      this.response,
      this.filteredEvents,
      this.originalEvents,
      this.originalEventsCount = 0,
      this.filteredEventsCount = 0,
      this.searchText});

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final Response<Tuple2<EventList, MeasurementsList>>? response;
  @override
  final EventList? filteredEvents;
  @override
  final EventList? originalEvents;
  @override
  @JsonKey()
  final int originalEventsCount;
  @override
  @JsonKey()
  final int filteredEventsCount;
  @override
  final String? searchText;

  @override
  String toString() {
    return 'EventsPageOptionsState(isLoading: $isLoading, response: $response, filteredEvents: $filteredEvents, originalEvents: $originalEvents, originalEventsCount: $originalEventsCount, filteredEventsCount: $filteredEventsCount, searchText: $searchText)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_EventsPageOptionsState &&
            const DeepCollectionEquality().equals(other.isLoading, isLoading) &&
            const DeepCollectionEquality().equals(other.response, response) &&
            const DeepCollectionEquality()
                .equals(other.filteredEvents, filteredEvents) &&
            const DeepCollectionEquality()
                .equals(other.originalEvents, originalEvents) &&
            const DeepCollectionEquality()
                .equals(other.originalEventsCount, originalEventsCount) &&
            const DeepCollectionEquality()
                .equals(other.filteredEventsCount, filteredEventsCount) &&
            const DeepCollectionEquality()
                .equals(other.searchText, searchText));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(isLoading),
      const DeepCollectionEquality().hash(response),
      const DeepCollectionEquality().hash(filteredEvents),
      const DeepCollectionEquality().hash(originalEvents),
      const DeepCollectionEquality().hash(originalEventsCount),
      const DeepCollectionEquality().hash(filteredEventsCount),
      const DeepCollectionEquality().hash(searchText));

  @JsonKey(ignore: true)
  @override
  _$$_EventsPageOptionsStateCopyWith<_$_EventsPageOptionsState> get copyWith =>
      __$$_EventsPageOptionsStateCopyWithImpl<_$_EventsPageOptionsState>(
          this, _$identity);
}

abstract class _EventsPageOptionsState implements EventsPageOptionsState {
  factory _EventsPageOptionsState(
      {final bool isLoading,
      final Response<Tuple2<EventList, MeasurementsList>>? response,
      final EventList? filteredEvents,
      final EventList? originalEvents,
      final int originalEventsCount,
      final int filteredEventsCount,
      final String? searchText}) = _$_EventsPageOptionsState;

  @override
  bool get isLoading => throw _privateConstructorUsedError;
  @override
  Response<Tuple2<EventList, MeasurementsList>>? get response =>
      throw _privateConstructorUsedError;
  @override
  EventList? get filteredEvents => throw _privateConstructorUsedError;
  @override
  EventList? get originalEvents => throw _privateConstructorUsedError;
  @override
  int get originalEventsCount => throw _privateConstructorUsedError;
  @override
  int get filteredEventsCount => throw _privateConstructorUsedError;
  @override
  String? get searchText => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$_EventsPageOptionsStateCopyWith<_$_EventsPageOptionsState> get copyWith =>
      throw _privateConstructorUsedError;
}
