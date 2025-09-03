import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class LocalDataSource {
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', user.username);
    await prefs.setString('password', user.password);
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final password = prefs.getString('password');
    if (username != null && password != null) {
      return UserModel(username: username, password: password);
    }
    return null;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
  }
}
