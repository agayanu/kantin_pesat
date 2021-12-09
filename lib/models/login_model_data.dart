import 'dart:convert';

LoginData loginDataFromJson(String str) => LoginData.fromJson(json.decode(str));

String loginDataToJson(LoginData data) => json.encode(data.toJson());

class LoginData {
  LoginData(
      {required this.code,
      required this.status,
      required this.message,
      required this.accessToken,
      required this.data});

  int code;
  bool status;
  String message;
  String accessToken;
  Data data;

  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
        code: json["code"],
        status: json["status"],
        message: json["message"],
        accessToken: json["accessToken"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "status": status,
        "message": message,
        "accessToken": accessToken,
        "data": data.toJson()
      };
}

class Data {
  int id;
  String name;
  String email;
  String role;
  String gambar;

  Data(
      {required this.id,
      required this.name,
      required this.email,
      required this.role,
      required this.gambar});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
      id: json["id"],
      name: json["name"],
      email: json["email"],
      role: json["role"],
      gambar: json["gambar"]);

  Map<String, dynamic> toJson() =>
      {"id": id, "name": name, "email": email, "role": role, "gambar": gambar};
}
