import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tdlook_flutter_app/Extensions/String+Extension.dart';
import 'package:tdlook_flutter_app/data/models/errors/fields_errors.dart';

part 'end_wearer_state.freezed.dart';

@freezed
class EWState with _$EWState {
  factory EWState({
    required EWAddToEventState addToEventState,
  }) = _EWState;
}

@freezed
class EWAddToEventState with _$EWAddToEventState {
  factory EWAddToEventState({
    @Default(false) bool isLoading,
    @Default(false) bool isSuccess,
    String? name,
    String? email,
    String? phone,
    String? errorMessage,
    FieldsErrors? errors,
  }) = _EWAddToEventState;
}

extension EWStateExt on EWState {
  bool get isLoading => addToEventState.isLoading;
}

extension EWAddToEventStateExt on EWAddToEventState {
  bool get isValidData {
    bool isEmailPassed = true;
    if (email?.trim().isNotEmpty == true) {
      isEmailPassed = email?.isValidEmail() == true;
    }
    bool isPhonePasse = true;
    if (phone?.trim().isNotEmpty == true) {
      isPhonePasse = phone?.isNotEmpty == true;
    }
    bool isNamePassed = name?.trim().isNotEmpty == true;

    return isNamePassed && isEmailPassed && isPhonePasse;
  }
}
