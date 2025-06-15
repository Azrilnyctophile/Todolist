import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // ==============================
  // TOKEN MANAGEMENT
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (withAuth && token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==============================
  // AUTH - LOGIN (dengan hasil detail success/message)
  Future<Map<String, dynamic>> loginWithResponse(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['access_token']);
        return {'success': true};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Email atau password salah.'};
      } else {
        return {'success': false, 'message': 'Login gagal (${response.statusCode}).'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan email atau password.'};
    }
  }

  // ==============================
  // AUTH - REGISTER (dengan hasil success/message)
  Future<Map<String, dynamic>> registerWithResponse(
      String name, String email, String password, String passwordConfirmation) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);

        // Ambil pesan error detail dari 'errors' jika ada
        String errorMessage = data['message'] ?? 'Registrasi gagal.';

        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          errorMessage = errors.values
              .map((e) => (e as List).join(', '))
              .join('\n');
        }

        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi.'};
    }
  }

  // ==============================
  // AUTH - LOGOUT
  Future<void> logout() async {
    try {
      await http.post(Uri.parse('$baseUrl/logout'), headers: await _getHeaders());
    } catch (_) {
      // Tidak masalah kalau gagal, lanjut hapus token
    }
    await removeToken();
  }

  // ==============================
  // TASKS - GET ALL TASKS
  Future<List<Task>> getTasks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tasks'), headers: await _getHeaders());
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Gagal mengambil data: $e');
    }
  }

  // ==============================
  // TASKS - ADD TASK
  Future<bool> addTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: await _getHeaders(),
        body: jsonEncode(task.toJson()),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==============================
  // TASKS - UPDATE TASK
  Future<bool> updateTask(Task task) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tasks/${task.id}'),
        headers: await _getHeaders(),
        body: jsonEncode(task.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==============================
  // TASKS - DELETE TASK
  Future<bool> deleteTask(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tasks/$id'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
