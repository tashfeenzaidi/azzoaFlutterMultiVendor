import 'package:azzoa_grocery/constants.dart';
import 'package:intl/intl.dart';

class TimeUtil {
  static String getFormattedDate(DateTime dateTime, String format) {
    return DateFormat(format).format(dateTime);
  }

  static String getFormattedDateFromText(
    String dateTime,
    String givenFormat,
    String desiredFormat,
  ) {
    if (dateTime == null) return kDefaultString;

    DateTime receivedDateTime = DateFormat(givenFormat,"en").parse(dateTime);
    return DateFormat(desiredFormat)
        .format(receivedDateTime);
  }
}
