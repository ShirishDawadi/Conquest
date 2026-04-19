class AuthModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  AuthModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'],
    );
  }
}