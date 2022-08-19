import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/language.dart';

class HelpResponse {
  final int status;
  final String faqUrl;
  final String termAndConditionsUrl;

  HelpResponse({
    this.status,
    this.faqUrl,
    this.termAndConditionsUrl,
  });

  factory HelpResponse.fromJson(Map<String, dynamic> json) {
    String faqUrl = kDefaultString;
    String termAndConditionsUrl = kDefaultString;

    if (json.containsKey(kKeyData)) {
      Map<String, dynamic> dataMap = json[kKeyData];

      if (dataMap.containsKey(kKeyJsonObject)) {
        Map<String, dynamic> objectMap = dataMap[kKeyJsonObject];

        if (objectMap.containsKey(kKeyFaqText)) {
          faqUrl = objectMap[kKeyFaqText];
        }

        if (objectMap.containsKey(kKeyTermsAndConditionsText)) {
          termAndConditionsUrl = objectMap[kKeyTermsAndConditionsText];
        }
      }
    }

    return HelpResponse(
      status: json[kKeyStatus],
      faqUrl: faqUrl,
      termAndConditionsUrl: termAndConditionsUrl,
    );
  }
}
