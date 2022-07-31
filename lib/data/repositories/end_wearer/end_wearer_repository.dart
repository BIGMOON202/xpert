import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';

abstract class EWRepository {
  Future<bool?> addToEvent(
    int id, {
    required String name,
    String? email,
    String? phone,
    required bool isActive,
  });
}
