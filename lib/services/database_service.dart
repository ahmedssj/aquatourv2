import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';
import '../models/contact.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Base URL de la API
  String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';
  
  // Timeout para requests HTTP
  int get timeoutSeconds => int.tryParse(dotenv.env['HTTP_TIMEOUT'] ?? '30') ?? 30;

  // Headers comunes para todas las requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers con token de autenticación
  Map<String, String> _headersWithAuth(String token) => {
    ..._headers,
    'Authorization': 'Bearer $token',
  };

  // Manejo de errores HTTP
  void _handleHttpError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        throw Exception('Solicitud inválida: ${response.body}');
      case 401:
        throw Exception('No autorizado: Credenciales inválidas');
      case 403:
        throw Exception('Prohibido: No tienes permisos para esta acción');
      case 404:
        throw Exception('No encontrado: El recurso solicitado no existe');
      case 422:
        throw Exception('Datos inválidos: ${response.body}');
      case 500:
        throw Exception('Error interno del servidor');
      default:
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // ==================== AUTENTICACIÓN ====================

  /// Iniciar sesión con email y contraseña
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      print('🚀 Intentando login con API: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: json.encode({
          'email': email.toLowerCase().trim(),
          'password': password,
        }),
      ).timeout(Duration(seconds: timeoutSeconds));

      print('📡 Respuesta del servidor: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('✅ Login exitoso');
        return data;
      } else {
        print('❌ Error en login: ${response.statusCode}');
        _handleHttpError(response);
        return null;
      }
    } catch (e) {
      print('❌ Error de conexión en login: $e');
      rethrow;
    }
  }

  /// Cerrar sesión
  Future<bool> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: _headersWithAuth(token),
      ).timeout(Duration(seconds: timeoutSeconds));

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error en logout: $e');
      return false;
    }
  }

  /// Verificar token de autenticación
  Future<User?> verifyToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify'),
        headers: _headersWithAuth(token),
      ).timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return User.fromMap(data['user']);
      } else {
        _handleHttpError(response);
        return null;
      }
    } catch (e) {
      print('❌ Error verificando token: $e');
      return null;
    }
  }

  /// Refrescar token de autenticación
  Future<Map<String, dynamic>?> refreshToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: _headers,
        body: json.encode({
          'refresh_token': refreshToken,
        }),
      ).timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        _handleHttpError(response);
        return null;
      }
    } catch (e) {
      print('❌ Error refrescando token: $e');
      return null;
    }
  }

  // ==================== USUARIOS ====================

  /// Obtener todos los usuarios
  Future<List<User>> getAllUsers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: _headersWithAuth(token),
      ).timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final usersList = data['users'] as List<dynamic>;
        return usersList.map((json) => User.fromMap(json as Map<String, dynamic>)).toList();
      } else {
        _handleHttpError(response);
        return [];
      }
    } catch (e) {
      print('❌ Error obteniendo usuarios: $e');
      rethrow;
    }
  }

  /// Obtener usuario por ID
  Future<User?> getUserById(String token, int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: _headersWithAuth(token),
      ).timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return User.fromMap(data['user']);
      } else {
        _handleHttpError(response);
        return null;
      }
    } catch (e) {
      print('❌ Error obteniendo usuario: $e');
      return null;
    }
  }

  /// Crear nuevo usuario
  Future<User?> createUser(String token, User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: _headersWithAuth(token),
        body: json.encode(user.toMap()),
      ).timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return User.fromMap(data['user']);
      } else {
        _handleHttpError(response);
        return null;
      }
    } catch (e) {
      print('❌ Error creando usuario: $e');
      rethrow;
    }
  }

  /// Actualizar usuario
  Future<User?> updateUser(String token, User user) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/${user.idUsuario}'),
        headers: _headersWithAuth(token),
        body: json.encode(user.toMap()),
      ).timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return User.fromMap(data['user']);
      } else {
        _handleHttpError(response);
        return null;
      }
    } catch (e) {
      print('❌ Error actualizando usuario: $e');
      rethrow;
    }
  }

  /// Eliminar usuario
  Future<bool> deleteUser(String token, int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$userId'),
        headers: _headersWithAuth(token),
      ).timeout(Duration(seconds: timeoutSeconds));

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('❌ Error eliminando usuario: $e');
      return false;
    }
  }

  // ==================== CONTACTOS ====================

  /// Obtener todos los contactos
  Future<List<Contact>> getAllContacts(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/contacts'),
        headers: _headersWithAuth(token),
      ).timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final contactsList = data['contacts'] as List<dynamic>;
        return contactsList.map((json) => Contact.fromMap(json as Map<String, dynamic>)).toList();
      } else {
        _handleHttpError(response);
        return [];
      }
    } catch (e) {
      print('❌ Error obteniendo contactos: $e');
      rethrow;
    }
  }

  /// Crear nuevo contacto
  Future<Contact?> createContact(String token, Contact contact) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/contacts'),
        headers: _headersWithAuth(token),
        body: json.encode(contact.toMap()),
      ).timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Contact.fromMap(data['contact']);
      } else {
        _handleHttpError(response);
        return null;
      }
    } catch (e) {
      print('❌ Error creando contacto: $e');
      rethrow;
    }
  }

  /// Actualizar contacto
  Future<Contact?> updateContact(String token, Contact contact) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/contacts/${contact.id}'),
        headers: _headersWithAuth(token),
        body: json.encode(contact.toMap()),
      ).timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Contact.fromMap(data['contact']);
      } else {
        _handleHttpError(response);
        return null;
      }
    } catch (e) {
      print('❌ Error actualizando contacto: $e');
      rethrow;
    }
  }

  /// Eliminar contacto
  Future<bool> deleteContact(String token, int contactId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/contacts/$contactId'),
        headers: _headersWithAuth(token),
      ).timeout(Duration(seconds: timeoutSeconds));

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('❌ Error eliminando contacto: $e');
      return false;
    }
  }

  // ==================== UTILIDADES ====================

  /// Verificar conectividad con la API
  Future<bool> checkApiHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: _headers,
      ).timeout(Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('❌ API no disponible: $e');
      return false;
    }
  }

  /// Obtener información de la API
  Future<Map<String, dynamic>?> getApiInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/info'),
        headers: _headers,
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('❌ Error obteniendo info de API: $e');
      return null;
    }
  }
}
