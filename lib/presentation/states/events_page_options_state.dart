import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/MeasurementsModel.dart';
import 'package:tuple/tuple.dart';

part 'events_page_options_state.freezed.dart';

@freezed
class EventsPageOptionsState with _$EventsPageOptionsState {
  factory EventsPageOptionsState({
    @Default(false) bool isLoading,
    Response<Tuple2<EventList, MeasurementsList>>? response,
    EventList? filteredEvents,
    EventList? originalEvents,
    @Default(0) int originalEventsCount,
    @Default(0) int filteredEventsCount,
    String? searchText,
  }) = _EventsPageOptionsState;
}

extension EventsPageOptionsStateExt on EventsPageOptionsState {
  bool get isAvailableSearch => originalEventsCount > 2;
  bool get isAvailableFakeSearch =>
      originalEventsCount == 6 ||
      originalEventsCount == 12 ||
      originalEventsCount == 21 ||
      originalEventsCount == 30;
}
