import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/language.dart';

class LanguageResponse {
  final int status;
  final List<Language> data;

  LanguageResponse({
    this.status,
    this.data,
  });

  factory LanguageResponse.fromJson(Map<String, dynamic> json) {
    List<Language> languageList = [];

    if (json.containsKey(kKeyData)) {
      Map<String, dynamic> dataMap = json[kKeyData];

      if (dataMap.containsKey(kKeyJsonArray)) {
        for (var language in dataMap[kKeyJsonArray]) {
          languageList.add(
            Language(
              language[kKeyName],
              language[kKeyCode],
            ),
          );
        }
      }
    }

    return LanguageResponse(
      status: json[kKeyStatus],
      data: languageList,
    );
  }
}
