import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<void> login(String email, String password) async {
    // TODO: Implement Supabase login
    notifyListeners();
  }

  Future<void> signup(String email, String password, String name) async {
    // TODO: Implement Supabase signup
    notifyListeners();
  }

  Future<void> logout() async {
    // TODO: Implement Supabase logout
    _user = null;
    notifyListeners();
  }
}
