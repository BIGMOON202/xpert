import 'dart:async';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/UserModel.dart';

class UserInfoWorker {
  UserType userType;

  UserInfoWorker(this.userType);

  NetworkAPI _provider = NetworkAPI();
  Future<User> fetchData() async {
    final response = await _provider.get('${userType.apiUserInfoEnpoint()}/me/', useAuth: true);
    print('userinfo ${response}');
    return User.fromJson(response);
  }
}

class UserInfoBloc {
  UserType userType;

  UserInfoWorker _userInfoWorker;
  StreamController _listController;

  StreamSink<Response<User>> chuckListSink;

  Stream<Response<User>>  chuckListStream;

  UserInfoBloc() {
    _listController = StreamController<Response<User>>();

    chuckListSink = _listController.sink;
    chuckListStream = _listController.stream;
  }

  void set(UserType userType) {
    this.userType = userType;

    _userInfoWorker = UserInfoWorker(userType);
  }

  call() async {

    chuckListSink.add(Response.loading('Getting User Info'));
    try {
      User info = await _userInfoWorker.fetchData();
      chuckListSink.add(Response.completed(info));
    } catch (e) {
      chuckListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _listController?.close();
  }
}

extension _UserTypeNetworkExtension on UserType {
  String apiUserInfoEnpoint() {
    switch (this) {
      case UserType.salesRep: return 'users';
      case UserType.endWearer: return 'end_wearers';
    }
  }
}