import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/AuthCredentials.dart';
import 'dart:async';

class AuthWorker {
  String email;
  String password;
  UserType userType;

  AuthWorker(this.email, this.password, this.userType);

  NetworkAPI _provider = NetworkAPI();

  Future<AuthCredentials> fetchData() async {
    final response = await _provider.post(userType._authEndPoint(),
        body: {'email': email,
          'password':password}, useAuth: false);
    return AuthCredentials.fromJson(response);
  }
}

extension UserTypeEndpointExtension on UserType {
  String _authEndPoint() {
    switch (this) {
      case UserType.endWearer: return 'auth/end_wearers/jwt-create/';
      case UserType.salesRep: return 'auth/jwt-create/';
    }
  }
}

class AuthWorkerBloc {
  String email;
  String password;
  UserType userType;

  AuthWorker _authWorker;
  StreamController _listController;

  StreamSink<Response<AuthCredentials>> chuckListSink;

  Stream<Response<AuthCredentials>>  chuckListStream;

  AuthWorkerBloc(this.email, this.password, this.userType) {
    print('Initid block with $email, $password');
    _listController = StreamController<Response<AuthCredentials>>();

    chuckListSink = _listController.sink;
    chuckListStream = _listController.stream;

    print('${_listController.hasListener}');
    _authWorker = AuthWorker(this.email, this.password, this.userType);
  }

  call() async {
    print('call auth');

    chuckListSink.add(Response.loading('Getting Chuck AUTH.'));
    try {
      print('try block');
      AuthCredentials credentials = await _authWorker.fetchData();
      print('$credentials');
      chuckListSink.add(Response.completed(credentials));
    } catch (e) {
      chuckListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _listController?.close();
  }
}