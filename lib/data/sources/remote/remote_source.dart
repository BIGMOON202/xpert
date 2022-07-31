import 'package:tdlook_flutter_app/data/sources/base/base_remote_source.dart';

abstract class RemoteSource {
  Future<bool> post({JsonData? data});
}
