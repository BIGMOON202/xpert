import 'dart:convert';

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

      String returnValue = handle(error: e);
      chuckListSink.add(Response.error(returnValue));
      print(e);
    }
  }

  String handle({dynamic error}) {
    print('e: ${error} ${error.runtimeType}');
    var returnValue = error.toString();

    var decodeSucceeded = false;
    try {
      var x = json.decode(error.toString()) as Map<String, dynamic>;
      decodeSucceeded = true;
    } on FormatException catch (e) {

    }

    if (decodeSucceeded == true) {
      var json = jsonDecode(error.toString());
      print('j: ${json} ${json.runtimeType}');
      var parsedError = LoginValidationError.fromJson(json);
      if (parsedError != null) {
        returnValue = parsedError.toString();
      } else {

      }
    } else {
      returnValue = error.toString();
    }

    return returnValue;
  }



  dispose() {
    _listController?.close();
  }
}

class LoginValidationError {
  List<String> email;
  List<String> password;
  String details;

  LoginValidationError({this.email, this.password, this.details});

  LoginValidationError.fromJson(Map<String, dynamic> json) {

    print('parse JSON: ${json}');
    details = json['details'] != null ? json['details'] : null;
    print('${details}');

    var emailErrors = json['email'];
    print('${emailErrors}');
    email = emailErrors != null ? List.from(emailErrors) : null;

    var passwordErrors = json['password'];
    password = passwordErrors != null ? List.from(passwordErrors) : null;
  }

  @override
  String toString() {
    var description = '';

    if (email != null && email.isEmpty == false) {
      description += email.join('\n');
    }

    if (password != null && password.isEmpty == false) {
      description += password.join('\n');
    }

    if (details != null && details.isEmpty == false) {
      description += details;
    }

    return description;
  }
}