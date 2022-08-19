import 'package:azzoa_grocery/base/exception/app_exception.dart';

class PhoneUnverifiedException extends AppException {
  PhoneUnverifiedException([message]) : super(message, "About Phone Number: ");
}
