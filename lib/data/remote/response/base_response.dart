import 'package:azzoa_grocery/constants.dart';

class BaseResponse {
  final int status;
  final String message;

  BaseResponse({
    this.status,
    this.message,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    String message = kDefaultString;

    List<String> messageList = [];

    Map<String, dynamic> bodyObject = json;

    if (bodyObject.containsKey(kKeyData)) {
      Map<String, dynamic> dataObject = bodyObject[kKeyData];

      if (dataObject.containsKey(kKeyJsonObject)) {
        Map<String, dynamic> jsonObject = dataObject[kKeyJsonObject];

        jsonObject.forEach((key, value) {
          messageList.add(value);
        });
      }

      if (dataObject.containsKey(kKeyStringData)) {
        message = dataObject[kKeyStringData] as String;
      }
    }

    if (bodyObject.containsKey(kKeyMessage)) {
      message = bodyObject[kKeyMessage] as String;
    }

    if (messageList.isNotEmpty) {
      message = messageList.join(kNewLineString);
    }

    return BaseResponse(
      status: json[kKeyStatus],
      message: message,
    );
  }
}
