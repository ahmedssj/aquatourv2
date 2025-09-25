import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'database_service.dart';
import 'local_storage_service.dart';

// Importación condicional para web
import 'dart:html' as html show window;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final LocalStorageService _localStorageService = LocalStorageService();

  static const String _tokenKey = 'aquatour_auth_token';
  static const String _refreshTokenKey = 'aquatour_refresh_token';
  static const String _currentUserKey = 'aquatour_current_user';

  // Usuario actual logueado
  User? _currentUser;
  String? _authToken;
  String? _refreshToken;

  // Getters
  User? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isLoggedIn => _currentUser != null && _authToken != null;

  /// Inicializar el servicio de autenticación
  Future<void> initialize() async {
    await _loadStoredAuth();
  }

  /// Cargar autenticación almacenada localmente
  Future<void> _loadStoredAuth() async {
    try {
      if (kIsWeb) {
        _authToken = html.window.localStorage[_tokenKey];
        _refreshToken = html.window.localStorage[_refreshTokenKey];
        
        final userJson = html.window.localStorage[_currentUserKey];
        if (userJson != null) {
          final userMap = json.decode(userJson) as Map<String, dynamic>;
          _currentUser = User.fromMap(userMap);
        }
      }

      // Verificar si el token sigue siendo válido
      if (_authToken != null) {
        final user = await _databaseService.verifyToken(_authToken!);
        if (user != null) {
          _currentUser = user;
          print('✅ Sesión restaurada para: ${user.nombreCompleto}');
        } else {
          // Token inválido, intentar refrescar
          await _tryRefreshToken();
        }
      }
    } catch (e) {
      print('❌ Error cargando autenticación: $e');
      await logout();
    }
  }

  /// Intentar refrescar el token de autenticación
  Future<bool> _tryRefreshToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await _databaseService.refreshToken(_refreshToken!);
      if (response != null) {
        _authToken = response['access_token'];
        _refreshToken = response['refresh_token'];
        _currentUser = User.fromMap(response['user']);
        
        await _saveAuthData();
        print('✅ Token refrescado exitosamente');
        return true;
      }
    } catch (e) {
      print('❌ Error refrescando token: $e');
    }
    
    return false;
  }

  /// Iniciar sesión con email y contraseña
  Future<LoginResult> login(String email, String password) async {
    try {
      print('🚀 Iniciando proceso de login...');
      
      // Verificar conectividad con la API
      final isApiAvailable = await _databaseService.checkApiHealth();
      
      if (!isApiAvailable) {
        print('⚠️ API no disponible, usando autenticación local');
        return await _loginWithLocalStorage(email, password);
      }

      // Intentar login con la API
      final response = await _databaseService.login(email, password);
      
      if (response != null) {
        final user = User.fromMap(response['user']);
        
        // Verificar que el rol esté permitido para login
        if (!_isRoleAllowed(user.rol)) {
          return LoginResult.failure('Acceso denegado. Solo personal administrativo puede acceder al sistema.');
        }
        
        _authToken = response['access_token'];
        _refreshToken = response['refresh_token'];
        _currentUser = user;
        
        await _saveAuthData();
        
        print('✅ Login exitoso con API: ${_currentUser!.nombreCompleto}');
        return LoginResult.success(_currentUser!);
      } else {
        return LoginResult.failure('Credenciales incorrectas');
      }
    } catch (e) {
      print('❌ Error en login con API: $e');
      
      // Fallback a autenticación local
      print('🔄 Intentando con autenticación local...');
      return await _loginWithLocalStorage(email, password);
    }
  }

  /// Login con almacenamiento local (fallback)
  Future<LoginResult> _loginWithLocalStorage(String email, String password) async {
    try {
      final user = await _localStorageService.login(email, password);
      
      if (user != null) {
        // Verificar que el rol esté permitido para login también en local
        if (!_isRoleAllowed(user.rol)) {
          return LoginResult.failure('Acceso denegado. Solo personal administrativo puede acceder al sistema.');
        }
        
        _currentUser = user;
        // No hay token real en modo local
        _authToken = 'local_token_${user.idUsuario}';
        
        await _saveAuthData();
        
        print('✅ Login exitoso con almacenamiento local: ${user.nombreCompleto}');
        return LoginResult.success(user);
      } else {
        return LoginResult.failure('Credenciales incorrectas o usuario inactivo');
      }
    } catch (e) {
      print('❌ Error en login local: $e');
      return LoginResult.failure('Error interno: ${e.toString()}');
    }
  }

  /// Guardar datos de autenticación
  Future<void> _saveAuthData() async {
    try {
      if (kIsWeb) {
        if (_authToken != null) {
          html.window.localStorage[_tokenKey] = _authToken!;
        }
        if (_refreshToken != null) {
          html.window.localStorage[_refreshTokenKey] = _refreshToken!;
        }
        if (_currentUser != null) {
          html.window.localStorage[_currentUserKey] = json.encode(_currentUser!.toMap());
        }
      }
    } catch (e) {
      print('❌ Error guardando datos de auth: $e');
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    try {
      // Intentar logout en el servidor si hay token
      if (_authToken != null && !_authToken!.startsWith('local_token_')) {
        await _databaseService.logout(_authToken!);
      }
    } catch (e) {
      print('⚠️ Error en logout del servidor: $e');
    }

    // Limpiar datos locales
    _currentUser = null;
    _authToken = null;
    _refreshToken = null;

    if (kIsWeb) {
      html.window.localStorage.remove(_tokenKey);
      html.window.localStorage.remove(_refreshTokenKey);
      html.window.localStorage.remove(_currentUserKey);
    }

    print('✅ Sesión cerrada exitosamente');
  }

  /// Verificar si el usuario tiene permisos específicos
  bool hasPermission(String permission) {
    if (_currentUser == null) return false;

    switch (permission) {
      case 'manage_users':
        return _currentUser!.puedeGestionarUsuarios;
      case 'view_all_modules':
        return _currentUser!.puedeVerTodosLosModulos;
      case 'delete_data':
        return _currentUser!.puedeEliminarDatos;
      case 'configure_system':
        return _currentUser!.puedeConfigurarSistema;
      default:
        return false;
    }
  }

  /// Verificar si el usuario es administrador
  bool get isAdmin => _currentUser?.esAdministrador ?? false;

  /// Verificar si el usuario es super administrador
  bool get isSuperAdmin => _currentUser?.esSuperAdministrador ?? false;

  /// Obtener token válido (con refresh automático si es necesario)
  Future<String?> getValidToken() async {
    if (_authToken == null) return null;

    // Si es token local, devolverlo directamente
    if (_authToken!.startsWith('local_token_')) {
      return _authToken;
    }

    // Verificar si el token sigue siendo válido
    try {
      final user = await _databaseService.verifyToken(_authToken!);
      if (user != null) {
        return _authToken;
      }
    } catch (e) {
      print('⚠️ Token inválido, intentando refrescar...');
    }

    // Intentar refrescar el token
    if (await _tryRefreshToken()) {
      return _authToken;
    }

    // Si no se puede refrescar, cerrar sesión
    await logout();
    return null;
  }

  /// Actualizar información del usuario actual
  Future<bool> updateCurrentUser(User updatedUser) async {
    try {
      final token = await getValidToken();
      if (token == null) return false;

      if (token.startsWith('local_token_')) {
        // Actualizar en almacenamiento local
        final success = await _localStorageService.updateUser(updatedUser);
        if (success) {
          _currentUser = updatedUser;
          await _saveAuthData();
        }
        return success;
      } else {
        // Actualizar en la API
        final user = await _databaseService.updateUser(token, updatedUser);
        if (user != null) {
          _currentUser = user;
          await _saveAuthData();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('❌ Error actualizando usuario: $e');
      return false;
    }
  }

  /// Verificar si el rol está permitido para login
  /// Solo roles administrativos pueden acceder al sistema
  bool _isRoleAllowed(UserRole role) {
    const allowedRoles = [
      UserRole.superadministrador,
      UserRole.administrador,
      UserRole.asesor,
    ];
    return allowedRoles.contains(role);
  }
}

/// Resultado del proceso de login
class LoginResult {
  final bool success;
  final User? user;
  final String? errorMessage;

  LoginResult.success(this.user) : success = true, errorMessage = null;
  LoginResult.failure(this.errorMessage) : success = false, user = null;
}
