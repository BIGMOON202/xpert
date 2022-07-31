import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlook_flutter_app/Extensions/String+Extension.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/application/presentation/states/end_wearer_state.dart';
import 'package:tdlook_flutter_app/data/models/errors/fields_errors.dart';
import 'package:tdlook_flutter_app/data/repositories/end_wearer/end_wearer_repository.dart';
import 'package:tdlook_flutter_app/data/repositories/end_wearer/end_wearer_repository_impl.dart';
import 'package:tdlook_flutter_app/generated/l10n.dart';
import 'package:tdlook_flutter_app/utilt/logger.dart';

class EWCubit extends Cubit<EWState> {
  final EWRepository repository = EWRepositoryImpl();
  final UserType userType;

  EWCubit({required this.userType})
      : super(EWState(
          addToEventState: EWAddToEventState(),
        ));

  Future<void> setName(String? name) async {
    emit(state.copyWith(
      addToEventState: state.addToEventState.copyWith(
        errors: null,
        name: name,
      ),
    ));
  }

  Future<void> setEmail(String? email) async {
    emit(state.copyWith(
      addToEventState: state.addToEventState.copyWith(
        errors: null,
        email: email,
      ),
    ));
  }

  Future<void> setPhone(String? phone) async {
    final onlyDigits = phone?.onlyDigits;
    emit(state.copyWith(
      addToEventState: state.addToEventState.copyWith(
        errors: null,
        phone: onlyDigits,
      ),
    ));
  }

  Future<void> addToEvent(
    int id, {
    required String name,
    String? email,
    String? phone,
  }) async {
    emit(state.copyWith(
      addToEventState: state.addToEventState.copyWith(
        isLoading: true,
      ),
    ));
    logger.d('START...');
    try {
      final success = await repository.addToEvent(
        id,
        name: name,
        email: email,
        phone: phone,
        isActive: true,
      );

      logger.d('SUCCESS: $success');

      emit(state.copyWith(
        addToEventState: state.addToEventState.copyWith(
          isLoading: false,
          isSuccess: success == true,
          errorMessage: success == true ? null : S.current.error_smt_wrong,
          errors: null,
        ),
      ));
    } catch (e) {
      logger.d('ERROR_1: $e');
      final errors = FieldsErrors.fromJson(json.decode(e.toString()));
      logger.d('ERROR_2: $errors');
      json.decode(e.toString());
      emit(state.copyWith(
        addToEventState: state.addToEventState.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: e.toString(),
          errors: errors,
        ),
      ));
    }
  }
}
