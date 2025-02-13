import 'package:tdlook_flutter_app/data/enums/invite_type.dart';
import 'package:tdlook_flutter_app/data/models/responses/invite_ew_response.dart';
import 'package:tdlook_flutter_app/data/sources/base/base_remote_source.dart';

abstract class EWRepository {
  Future<InviteEwResponse?> addToEvent(
    Id id, {
    required String name,
    String? email,
    String? phone,
    required bool isActive,
  });
  Future<bool?> invite(
    InviteType type, {
    required Id ewId,
    required Id eventId,
  });
}
