import 'package:freezed_annotation/freezed_annotation.dart';

part 'fields_errors.freezed.dart';
part 'fields_errors.g.dart';

@freezed
class FieldsErrors with _$FieldsErrors {
  factory FieldsErrors({
    List<String>? name,
    List<String>? email,
    List<String>? phone,
    List<String>? event,
  }) = _FieldsErrors;
  factory FieldsErrors.fromJson(Map<String, dynamic> json) => _$FieldsErrorsFromJson(json);
}

extension FieldsErrorsMessage on FieldsErrors {
  String? get nameErrorMessage {
    if (name?.isNotEmpty == true) {
      return name?[0];
    }
    return null;
  }

  String? get emailErrorMessage {
    if (email?.isNotEmpty == true) {
      return email?[0];
    }
    return null;
  }

  String? get phoneErrorMessage {
    if (phone?.isNotEmpty == true) {
      return phone?[0];
    }
    return null;
  }

  String? get eventErrorMessage {
    if (event?.isNotEmpty == true) {
      return event?[0];
    }
    return null;
  }
}
