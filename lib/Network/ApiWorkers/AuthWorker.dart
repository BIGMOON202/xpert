import 'dart:async';
import 'dart:convert';

import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/AuthCredentials.dart';
import 'package:tdlook_flutter_app/common/logger/logger.dart';

class AuthWorker {
  String? email;
  String? password;
  UserType? userType;
  CompanyType? provider;
  AuthWorker(this.email, this.password, this.userType, this.provider);

  NetworkAPI _provider = NetworkAPI();

  Future<AuthCredentials> fetchData() async {
    var body = {'email': email, 'password': password};
    if (userType == UserType.salesRep && provider != null) {
      body = {
        'email': email,
        'password': password,
        'provider': provider?.apiKey(),
      };
    }
    final response =
        await _provider.post(userType?._authEndPoint() ?? '', body: body, useAuth: false);
    return AuthCredentials.fromJson(response);
  }
}

class AuthRefreshWorker extends AuthWorker {
  String? token;
  UserType? userType;

  AuthRefreshWorker(this.token, this.userType) : super(null, null, null, null);
  NetworkAPI _provider = NetworkAPI();

  @override
  Future<AuthCredentials> fetchData() async {
    final response = await _provider.post(userType?._authRefreshEndPoint() ?? '',
        body: {'refresh': token}, useAuth: false, tryToRefreshAuth: false);
    return AuthCredentials.fromJson(response);
  }
}

extension UserTypeEndpointExtension on UserType {
  String _authEndPoint() {
    switch (this) {
      case UserType.endWearer:
        return 'auth/end_wearers/jwt-create/';
      case UserType.salesRep:
        return 'auth/jwt-create/';
    }
  }

  String _authRefreshEndPoint() {
    switch (this) {
      case UserType.endWearer:
        return 'auth/end_wearers/jwt-refresh/';
      case UserType.salesRep:
        return 'auth/jwt-refresh/';
    }
  }
}

class AuthWorkerBlocArguments {
  String? email;
  String? password;

  String? refreshToken;
  UserType? userType;
  CompanyType? provider;

  AuthWorkerBlocArguments(
      {this.email, this.password, this.refreshToken, this.userType, this.provider});
}

class AuthWorkerBloc {
  AuthWorkerBlocArguments? arguments;

  late AuthWorker _authWorker;
  late StreamController _listController;
  late StreamSink<Response<AuthCredentials>> chuckListSink;
  late Stream<Response<AuthCredentials>> chuckListStream;

  AuthWorkerBloc(this.arguments) {
    final ctrl = StreamController<Response<AuthCredentials>>();
    _listController = ctrl;

    chuckListSink = ctrl.sink;
    chuckListStream = ctrl.stream;

    if (arguments?.refreshToken == null) {
      _authWorker = AuthWorker(
          arguments?.email, arguments?.password, arguments?.userType, arguments?.provider);
    } else {
      _authWorker = AuthRefreshWorker(arguments?.refreshToken, arguments?.userType);
    }
  }

  call() async {
    chuckListSink.add(Response.loading('Getting Chuck AUTH.'));
    try {
      AuthCredentials credentials = await _authWorker.fetchData();
      chuckListSink.add(Response.completed(credentials));
    } catch (e) {
      String returnValue = handle(error: e);
      chuckListSink.add(Response.error(returnValue));
    }
  }

  Future<AuthCredentials?> callWithFuture() async {
    try {
      return await _authWorker.fetchData();
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  String handle({dynamic error}) {
    var returnValue = error.toString();

    var decodeSucceeded = false;
    try {
      var x = json.decode(error.toString()) as Map<String, dynamic>;
      decodeSucceeded = true;
    } on FormatException catch (e) {
      logger.e(e);
    }

    if (decodeSucceeded == true) {
      var json = jsonDecode(error.toString());
      final parsedError = LoginValidationError.fromJson(json);
      if (parsedError != null) {
        returnValue = parsedError.toString();
      } else {}
    } else {
      returnValue = error.toString();
    }

    return returnValue;
  }

  dispose() {
    _listController.close();
  }
}

class LoginValidationError {
  List<String>? email;
  List<String>? password;
  String? details;

  LoginValidationError({this.email, this.password, this.details});

  LoginValidationError.fromJson(Map<String, dynamic> json) {
    // logger.d('parse JSON: ${json}');
    details = json['details'] != null ? json['details'] : null;
    //logger.d('${details}');

    var emailErrors = json['email'];
    // logger.d('${emailErrors}');
    email = emailErrors != null ? List.from(emailErrors) : null;

    var passwordErrors = json['password'];
    password = passwordErrors != null ? List.from(passwordErrors) : null;
  }

  @override
  String toString() {
    var description = '';

    if (email != null && email?.isEmpty == false) {
      description += email?.join('\n') ?? '';
    }

    if (password != null && password?.isEmpty == false) {
      description += password?.join('\n') ?? '';
    }

    if (details != null && details?.isEmpty == false) {
      description += details ?? '';
    }

    return description;
  }
}
