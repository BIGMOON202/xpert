import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/MeasurementsModel.dart';
import 'package:tdlook_flutter_app/common/logger/logger.dart';
import 'package:tdlook_flutter_app/presentation/states/events_page_options_state.dart';
import 'package:tuple/tuple.dart';

@injectable
class EventsPageOptionsCubit extends Cubit<EventsPageOptionsState> {
  EventsPageOptionsCubit() : super(EventsPageOptionsState());

  Future<void> updateOriginalEventList(EventList? eventList) async {
    final count = eventList?.count ?? 0;
    logger.d('[STEP] Update original events $count');
    final current = state.originalEventsCount;
    emit(state.copyWith(
      originalEvents: eventList,
      originalEventsCount: count,
    ));
  }

  Future<void> updateFilteredEventList(EventList? eventList) async {
    final count = eventList?.count ?? 0;
    emit(state.copyWith(
      filteredEvents: eventList,
      filteredEventsCount: count,
    ));
  }

  Future<void> updateResponse(Response<Tuple2<EventList, MeasurementsList>>? response) async {
    emit(state.copyWith(
      response: response,
    ));
  }

  Future<void> updateSearchText(String? text) async {
    emit(state.copyWith(
      searchText: text,
    ));
  }
}
