import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlook_flutter_app/Extensions/String+Extension.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/data/enums/invite_type.dart';
import 'package:tdlook_flutter_app/data/models/errors/fields_errors.dart';
import 'package:tdlook_flutter_app/data/repositories/end_wearer/end_wearer_repository.dart';
import 'package:tdlook_flutter_app/data/repositories/end_wearer/end_wearer_repository_impl.dart';
import 'package:tdlook_flutter_app/generated/l10n.dart';
import 'package:tdlook_flutter_app/presentation/states/end_wearer_state.dart';
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

  Future<void> setInviteTypes(List<InviteType>? types) async {
    emit(state.copyWith(
      addToEventState: state.addToEventState.copyWith(
        errors: null,
        inviteTypes: types ?? [],
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
        errors: null,
        errorMessage: null,
      ),
    ));
    try {
      final response = await repository.addToEvent(
        id,
        name: name,
        email: email,
        phone: phone,
        isActive: true,
      );
      final ewId = response?.id;

      if (state.addToEventState.canSendSmsInvite && ewId != null) {
        await repository.invite(InviteType.sms, ewId: ewId, eventId: id);
      }

      if (state.addToEventState.canSendEmailInvite && ewId != null) {
        await repository.invite(InviteType.email, ewId: ewId, eventId: id);
      }

      logger.d('SUCCESS: $response');

      emit(state.copyWith(
        addToEventState: state.addToEventState.copyWith(
          isLoading: false,
          isSuccess: ewId != null,
          errorMessage: ewId != null ? null : S.current.error_smt_wrong,
          errors: null,
        ),
      ));
    } on BadRequestException catch (e) {
      logger.d('ERROR (BadRequestException): $e}');
      final errors = FieldsErrors.fromJson(jsonDecode(e.toString()));
      emit(state.copyWith(
        addToEventState: state.addToEventState.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: null,
          errors: errors,
        ),
      ));
    } catch (e) {
      logger.d('ERROR: $e}');
      emit(state.copyWith(
        addToEventState: state.addToEventState.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: e.toString(),
          errors: null,
        ),
      ));
    }
  }
}
