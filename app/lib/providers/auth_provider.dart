import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? user;
  bool loading = true;

  AuthProvider() {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      try {
        final res = await ApiClient().dio.get('/auth/me');
        user = AppUser.fromJson(res.data);
      } catch (_) {
        await prefs.remove('token');
      }
    }
    loading = false;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    try {
      final res = await ApiClient().dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', res.data['token']);
      user = AppUser.fromJson(res.data['user']);
      notifyListeners();
      return null;
    } catch (e) {
      return 'No se pudo iniciar sesion. Verifica tus credenciales.';
    }
  }

  Future<String?> register(String name, String email, String password, String phone) async {
    try {
      final res = await ApiClient().dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'role': 'coach',
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', res.data['token']);
      user = AppUser.fromJson(res.data['user']);
      notifyListeners();
      return null;
    } catch (e) {
      return 'No se pudo crear la cuenta.';
    }
  }

  Future<bool> uploadPhoto(List<int> bytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        'photo': MultipartFile.fromBytes(bytes, filename: filename),
      });
      final res = await ApiClient().dio.post('/auth/photo', data: formData);
      user = AppUser.fromJson(res.data);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await ApiClient().dio.post('/auth/logout');
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    user = null;
    notifyListeners();
  }
}
