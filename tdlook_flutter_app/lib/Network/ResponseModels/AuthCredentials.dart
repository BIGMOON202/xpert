
class AuthCredentials {
  final String refresh;
  final String access;

  AuthCredentials({this.refresh, this.access});

  factory AuthCredentials.fromJson(Map<String, dynamic> json) {
    return AuthCredentials(
      refresh: json['refresh'],
      access: json['access'],
    );
  }
}
