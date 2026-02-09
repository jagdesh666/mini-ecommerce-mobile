import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  String? _token;
  bool _isLoading = false;

  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  // Login function
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/login/"),
      body: {"username": username, "password": password},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _token = data['token'];

      // Token ko phone ki memory mein save karein
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout function
  Future<void> logout() async {
    _token = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}