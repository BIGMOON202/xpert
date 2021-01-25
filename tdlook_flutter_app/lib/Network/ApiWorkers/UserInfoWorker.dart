

import 'dart:async';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/UserModel.dart';

class UserInfoWorker {
  NetworkAPI _provider = NetworkAPI();
  Future<User> fetchData() async {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // var accessToken = prefs.getString('access');
    // UserType userType = EnumToString.fromString(UserType.values, prefs.getString("userType"));

    final response = await _provider.get('users/me/', useAuth: true);
    return User.fromJson(response);
  }
}

class UserInfoBloc {

  UserInfoWorker _userInfoWorker;
  StreamController _listController;

  StreamSink<Response<User>> chuckListSink;

  Stream<Response<User>>  chuckListStream;

  UserInfoBloc() {
    _listController = StreamController<Response<User>>();

    chuckListSink = _listController.sink;
    chuckListStream = _listController.stream;

    print('${_listController.hasListener}');
    _userInfoWorker = UserInfoWorker();
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