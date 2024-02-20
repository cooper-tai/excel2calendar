import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  static late SharedPreferences _sharedPreferences;
  static const String employeeID = 'employee_id';
  static late SharedPreferencesUtil _sharedPreferencesUtil;

  static Future<void> init() async {
    _sharedPreferencesUtil = SharedPreferencesUtil._();
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  SharedPreferencesUtil._();

  static SharedPreferencesUtil get instance => _sharedPreferencesUtil;

  void saveEmployeeID(String id) {
    _sharedPreferences.setString(employeeID, id);
  }

  String loadEmployeeID() {
    return _sharedPreferences.getString(employeeID) ?? '';
  }
}