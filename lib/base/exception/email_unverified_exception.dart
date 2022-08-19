import 'package:azzoa_grocery/base/exception/app_exception.dart';

class EmailUnverifiedException extends AppException {
  EmailUnverifiedException([message]) : super(message, "With Error: ");
}
