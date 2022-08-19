import 'package:azzoa_grocery/constants.dart';

class PlainResponse {
  final int status;

  PlainResponse({
    this.status,
  });

  factory PlainResponse.fromJson(Map<String, dynamic> json) {
    return PlainResponse(
      status: json[kKeyStatus],
    );
  }
}
