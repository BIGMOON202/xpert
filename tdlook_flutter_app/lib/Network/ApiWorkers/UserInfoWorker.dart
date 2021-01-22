

import 'dart:async';

import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/UserModel.dart';

class UserInfoWorker {
  NetworkAPI _provider = NetworkAPI();
  Future<User> fetchData() async {
    final response = await _provider.get('users/me/');
    return User.fromJson(response);
  }
}

class UserInfoBloc {

  UserInfoWorker _userInfoWorker;
  StreamController _listController;

  StreamSink<Response<User>> chuckListSink;

  Stream<Response<User>>  chuckListStream;

  AuthWorkerBloc() {
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