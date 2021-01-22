import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'secrets.dart';
import 'package:http/http.dart' as http;

class NetworkAPI {

  final Duration _timeout = Duration(seconds: 30);



  final String _baseUrl = "https://wlb-expertfit-test.3dlook.me/";
  static const Map<String, String> _authHeaders = {"Authorization": API_KEY};

  Future<dynamic> get(String url, {Map<String, String> headers}) async {
    var responseJson;
    try {
      var finalUrl = _baseUrl + url;
      print('$finalUrl, $headers');
      final response = await http.get(finalUrl, headers: headers).timeout(_timeout);
      responseJson = _response(response);
      print('get results: $responseJson');
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> post(String url, {Map <String, dynamic> body, Map<String, String> headers}) async {
    var responseJson;
    try {
      var finalUrl = _baseUrl + url;
      print('$finalUrl, $headers, $body');
      final response = await http.post(finalUrl, headers: headers, body: body).timeout(_timeout);
      responseJson = _response(response);
      print('post results: $responseJson');
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  dynamic _response(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        print(responseJson);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:

      case 403:
        var responseJson = json.decode(response.body.toString());
        print(responseJson);
        var details = responseJson['detail'];
        print(details);
        throw UnauthorisedException(details != null ? details : response.body.toString());
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

  void refreshTokenOrLogout() {

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

class CustomException implements Exception {
  final _message;
  final _prefix;

  CustomException([this._message, this._prefix]);

  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends CustomException {
  FetchDataException([String message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends CustomException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([message]) : super(message, "");
}

class InvalidInputException extends CustomException {
  InvalidInputException([String message]) : super(message, "Invalid Input: ");
}

class Response<T> {
  Status status;
  T data;
  String message;

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

enum Status { LOADING, COMPLETED, ERROR }
