import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/AuthWorker.dart';
import 'package:tdlook_flutter_app/common/logger/logger.dart';
import 'package:tdlook_flutter_app/main.dart';

class CustomException implements Exception {
  final _message;
  final _prefix;

  CustomException([this._message, this._prefix]);

  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends CustomException {
  FetchDataException([String? message]) : super(message, "");
}

class BadRequestException extends CustomException {
  BadRequestException([message]) : super(message, '');
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([message]) : super(message, '');
}

class InvalidInputException extends CustomException {
  InvalidInputException([String? message]) : super(message, "Invalid Input: ");
}

class Response<T> {
  Status? status;
  T? data;
  String? message;

  Response.loading(this.message) : status = Status.LOADING;
  Response.completed(this.data) : status = Status.COMPLETED;
  Response.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    switch (status) {
      case Status.ERROR:
        return "\n Message : $message \n Data : $data";

      default:
        return "Status : $status \n Message : $message \n Data : $data";
    }
  }
}

class ParserResponse<T> {
  ParserResponseStatus status;
  T data;

  ParserResponse.completed(this.data) : status = ParserResponseStatus.COMPLETED;
  ParserResponse.error(this.data) : status = ParserResponseStatus.ERROR;
  ParserResponse.repeat(this.data) : status = ParserResponseStatus.REPEAT;
}

enum ParserResponseStatus { COMPLETED, ERROR, REPEAT }

enum Status { LOADING, COMPLETED, ERROR }

enum Request { GET, POST, PUT, PATCH }

extension RequestExtension on Request {
  HttpMethod perfomanceMethod() {
    switch (this) {
      case Request.GET:
        return HttpMethod.Get;
      case Request.POST:
        return HttpMethod.Post;
      case Request.PUT:
        return HttpMethod.Put;
      case Request.PATCH:
        return HttpMethod.Patch;
    }
  }
}

extension UserTypeNetworkExtension on UserType {
  String authPreffix() {
    switch (this) {
      case UserType.salesRep:
        return 'JWT';
      case UserType.endWearer:
        return 'EWJWT';
    }
  }
}

class NetworkAPI {
  static int itemsPerPage = 10;
  final Duration _timeout = Duration(seconds: 180);

  final String _baseUrl = "https://${Application.hostName}/";

  Future<dynamic> get(
    String url, {
    Map<String, String>? headers,
    bool useAuth = true,
    bool isJsonBody = false,
    bool tryToRefreshAuth = true,
  }) async {
    return call(
      Request.GET,
      url,
      headers: headers ?? {},
      useAuth: useAuth,
      isJsonBody: isJsonBody,
      tryToRefreshAuth: tryToRefreshAuth,
    );
  }

  Future<dynamic> post(String url,
      {Map<String, dynamic>? body,
      Map<String, String>? headers,
      bool useAuth = true,
      bool isJsonBody = false,
      bool tryToRefreshAuth = true}) async {
    return call(
      Request.POST,
      url,
      body: body ?? {},
      headers: headers ?? {},
      useAuth: useAuth,
      isJsonBody: isJsonBody,
      tryToRefreshAuth: tryToRefreshAuth,
    );
  }

  Future<dynamic> patch(String url,
      {Map<String, dynamic>? body,
      Map<String, String>? headers,
      bool useAuth = true,
      bool isJsonBody = false,
      bool tryToRefreshAuth = true}) async {
    return call(
      Request.PATCH,
      url,
      body: body ?? {},
      headers: headers ?? {},
      useAuth: useAuth,
      isJsonBody: isJsonBody,
      tryToRefreshAuth: tryToRefreshAuth,
    );
  }

  Future<dynamic> put(String url,
      {Map<String, dynamic>? body,
      Map<String, String>? headers,
      bool useAuth = true,
      bool isJsonBody = false,
      bool tryToRefreshAuth = true}) async {
    return call(
      Request.PUT,
      url,
      body: body ?? {},
      headers: headers ?? {},
      useAuth: useAuth,
      isJsonBody: isJsonBody,
      tryToRefreshAuth: tryToRefreshAuth,
    );
  }

  Future<dynamic> call(
    Request request,
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool useAuth = true,
    required bool isJsonBody,
    bool tryToRefreshAuth = true,
  }) async {
    logger.d('call $request on $url');
    var responseJson;

    Future<void> makeCall() async {
      dynamic bodyToSend = body;
      try {
        if (useAuth == true) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          var accessToken = prefs.getString('access');

          UserType? userType;
          final value = prefs.getString("userType");

          if (value != null) {
            userType = EnumToString.fromString(UserType.values, value);
          }

          if (accessToken == null || userType == null) {
            //LOGOUT;
          }
          var authKey = {'Authorization': '${userType?.authPreffix()} $accessToken'};
          if (headers == null) {
            headers = authKey;
          } else {
            headers?.addAll(authKey);
            if (headers!['Content-Type'] == 'application/json') {
              bodyToSend = jsonEncode(body);
            }
          }
        }
        logger.d('REQUEST HEADERS: $headers');
        var finalUrl = Uri.parse(_baseUrl + url);

        logger.d('$finalUrl, $headers, $body');
        http.Response response;

        final HttpMetric metric =
            FirebasePerformance.instance.newHttpMetric(url, request.perfomanceMethod());
        await metric.start();

        switch (request) {
          case Request.POST:
            response =
                await http.post(finalUrl, headers: headers, body: bodyToSend).timeout(_timeout);
            break;

          case Request.PUT:
            response =
                await http.put(finalUrl, headers: headers, body: bodyToSend).timeout(_timeout);
            break;

          case Request.PATCH:
            response =
                await http.patch(finalUrl, headers: headers, body: bodyToSend).timeout(_timeout);
            break;

          case Request.GET:
            response = await http.get(finalUrl, headers: headers).timeout(_timeout);
            break;
        }

        metric
          ..responsePayloadSize = response.contentLength
          ..responseContentType = response.headers['Content-Type']
          ..httpResponseCode = response.statusCode;

        var parserResponse = await _response(
          response,
          tryToRefreshAuth: tryToRefreshAuth,
          isJsonBody: isJsonBody,
        );
        switch (parserResponse.status) {
          case ParserResponseStatus.COMPLETED:
            responseJson = parserResponse.data;
            break;
          case ParserResponseStatus.ERROR:
            responseJson = parserResponse.data;
            break;
          case ParserResponseStatus.REPEAT:
            logger.i('should repeat call');
            await makeCall();
            break;
        }

        await metric.stop();

        // logger.d('call results: $responseJson');
      } on SocketException {
        final exception = FetchDataException('No Internet connection');
        FirebaseCrashlytics.instance.recordError(exception, StackTrace.current);
        throw exception;
      } catch (e) {
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
        throw e;
      }
    }

    await makeCall();

    logger.i('should return response JSON');
    return responseJson;
  }

  Future<ParserResponse<dynamic>> _response(http.Response response,
      {bool tryToRefreshAuth = true, required bool isJsonBody}) async {
    logger.e(
        'SRESPONSE[${response.statusCode}]: HEADER:${response.headers}, URL: ${response.request?.url}');

    FirebaseCrashlytics.instance
        .log('Response [${response.statusCode}] ${response.request?.url}, ${response.headers}');
    switch (response.statusCode) {
      case 200:
      case 201:
        if (isJsonBody) {
          //logger.d('RESPONSE_200_201: ${response.body}');
          return ParserResponse.completed(response.body);
        }
        var responseJson = json.decode(utf8.decode(response.bodyBytes));
        //logger.i(responseJson);
        //logger.d('RESPONSE_200_201: $responseJson');
        return ParserResponse.completed(responseJson);
      case 400:
        logger.d('RESPONSE_403: ${response.body}');
        throw BadRequestException(response.body);
      case 401:
      case 403:
        var responseJson = json.decode(utf8.decode(response.bodyBytes));
        logger.d('RESPONSE_403: $responseJson');
        if (tryToRefreshAuth == true) {
          if (shouldRefreshTokenFor(json: responseJson)) {
            logger.i('Load new access token');
            var successRefresh = await refreshTokenOrLogout();
            if (successRefresh == true) {
              logger.d('successRefresh == true');
              return ParserResponse.repeat(responseJson);
            } else {
              logger.d('successRefresh == false');
              return ParserResponse.error(responseJson);
            }
          }
        }

        logger.d(responseJson);
        final details = responseJson['detail'];
        throw UnauthorisedException(details != null ? details : response.body);
      case 500:
      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }

  bool shouldRefreshTokenFor({dynamic json}) {
    if (json['code'] == 'token_not_valid') {
      return true;
    }
    return false;
  }

  static AuthRefresh _isRefreshingToken = AuthRefresh();
  static Future<bool> refreshTokenOrLogout() async {
    if (_isRefreshingToken.isRefreshing == false) {
      logger.i('_isRefreshingToken.isRefreshing == false');
      _isRefreshingToken.setIsRefreshing(true);
    } else {
      logger.i('_isRefreshingToken.isRefreshing == true');
      // wait until isRefreshingToken == false

      Future<bool> waitForEndOfRefresh() async {
        Completer<bool> c = new Completer<bool>();

        _isRefreshingToken.addListener(() {
          logger.d("_isRefreshingToken updated ${_isRefreshingToken.isRefreshing}");
          c.complete(_isRefreshingToken.isSuccessRefresh);
        });
        return c.future;
      }

      return await waitForEndOfRefresh();
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var refreshToken = prefs.getString('refresh');
    final value = prefs.getString('userType');
    UserType? userType;
    if (value != null) {
      userType = EnumToString.fromString(UserType.values, value);
    }

    logger.d('refreshTokenOrLogout: $refreshToken');
    AuthWorkerBloc refreshAuthBloc =
        AuthWorkerBloc(AuthWorkerBlocArguments(refreshToken: refreshToken, userType: userType));

    var credentials = await refreshAuthBloc.callWithFuture();
    logger.d('credentials: $credentials');
    if (credentials != null) {
      logger.d('REFRESH TOKEN RESPONSE: $credentials');
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('refresh', credentials.refresh ?? ''); // for string value
      prefs.setString('access', credentials.access ?? ''); // for string value
      _isRefreshingToken.isSuccessRefresh = true;
      _isRefreshingToken.setIsRefreshing(false);
      return true;
    } else {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('refresh');
      prefs.remove('access');
      prefs.remove(SessionParameters.keyProMode);
      _isRefreshingToken.isSuccessRefresh = false;
      _isRefreshingToken.setIsRefreshing(false);
      NavigationService.instance.pushNamedAndRemoveUntil("/");
      return false;
    }

    // refreshAuthBloc.chuckListStream.listen((event) async {
    //   switch (event.status) {
    //     case Status.COMPLETED:
    //       // SAVE CREDENTIANLS AND CONTINUE LAST REQUEST
    //       logger.d('REFRESH TOKEN RESPONSE: ${event.data}');
    //       final SharedPreferences prefs = await SharedPreferences.getInstance();
    //       prefs.setString('refresh', event.data.refresh); // for string value
    //       prefs.setString('access', event.data.access); // for string value

    //       return true;

    //     case Status.ERROR:
    //       logger.d('REFRESH TOKEN ERROR: ${event.message}');

    //       final SharedPreferences prefs = await SharedPreferences.getInstance();
    //       prefs.remove('refresh');
    //       prefs.remove('access'); // for string value
    //       return false;
    //     //NEED TO LOGOUT
    //     // _errorMessage = event.message;
    //   }
    // });
    // await refreshAuthBloc.call();
  }

  // Future<AuthCredentials> authWith(String email, String password) async {
  //   final http.Response response = await http.post(
  //     _baseUrl,
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(<String, String>{
  //       'email': email,
  //       'password': password
  //     }),
  //   );
  //   if (response.statusCode == 200) {
  //     // If the server did return a 200 UPDATED response,
  //     // then parse the JSON.
  //     return AuthCredentials.fromJson(jsonDecode(response.body));
  //   } else {
  //     // If the server did not return a 200 UPDATED response,
  //     // then throw an exception.
  //     throw Exception('Failed to load album');
  //   }
  // }
}

class AuthRefresh with ChangeNotifier {
  bool isRefreshing = false;
  bool? isSuccessRefresh;

  void setIsRefreshing(bool newValue) {
    isRefreshing = newValue;
    notifyListeners();
  }
}
