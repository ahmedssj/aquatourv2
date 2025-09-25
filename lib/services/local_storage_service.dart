import 'dart:convert';
import '../models/contact.dart';
import '../models/user.dart';

// Importación condicional para web
import 'dart:html' as html show window;

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static const String _contactsKey = 'aquatour_contacts';
  static const String _usersKey = 'aquatour_users';
  static const String _quotesKey = 'aquatour_quotes';
  static const String _reservationsKey = 'aquatour_reservations';

  // Inicializar con datos de ejemplo
  Future<void> initializeData() async {
    // Inicializar contactos
    if (html.window.localStorage[_contactsKey] == null) {
      final sampleContacts = [
        Contact(
          id: 1,
          name: 'Juan Pérez',
          email: 'juan.perez@email.com',
          phone: '+1234567890',
          company: 'Empresa ABC',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Contact(
          id: 2,
          name: 'María García',
          email: 'maria.garcia@email.com',
          phone: '+0987654321',
          company: 'Turismo XYZ',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Contact(
          id: 3,
          name: 'Carlos López',
          email: 'carlos.lopez@email.com',
          phone: '+1122334455',
          company: 'Viajes Premium',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      await _saveContacts(sampleContacts);
    }

    // Inicializar usuarios
    if (html.window.localStorage[_usersKey] == null) {
      final sampleUsers = [
        User(
          idUsuario: 1,
          nombre: 'Super',
          apellido: 'Admin',
          email: 'superadmin@aquatour.com',
          rol: UserRole.superadministrador,
          tipoDocumento: 'Cedula Ciudadania',
          numDocumento: '00000000',
          fechaNacimiento: DateTime(1980, 1, 1),
          lugarNacimiento: 'Bogotá',
          genero: 'M',
          telefono: '573000000000',
          direccion: 'Oficina Principal',
          ciudadResidencia: 'Bogotá',
          paisResidencia: 'Colombia',
          contrasena: 'superadmin123',
          activo: true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        User(
          idUsuario: 2,
          nombre: 'David',
          apellido: 'Gonzalez',
          email: 'davidg@aquatour.com',
          rol: UserRole.administrador,
          tipoDocumento: 'Cedula Ciudadania',
          numDocumento: '1017924927',
          fechaNacimiento: DateTime(2005, 9, 7),
          lugarNacimiento: 'Medellín',
          genero: 'M',
          telefono: '573233053830',
          direccion: 'Carrera 85f #58a - 51',
          ciudadResidencia: 'Medellín',
          paisResidencia: 'Colombia',
          contrasena: 'Osquitar07',
          activo: true,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now(),
        ),
        User(
          idUsuario: 3,
          nombre: 'Luis',
          apellido: 'Martínez',
          email: 'asesor@aquatour.com',
          rol: UserRole.asesor,
          tipoDocumento: 'Cedula Ciudadania',
          numDocumento: '87654321',
          fechaNacimiento: DateTime(1985, 8, 22),
          lugarNacimiento: 'Medellín',
          genero: 'M',
          telefono: '573109876543',
          direccion: 'Carrera 45 #12-34',
          ciudadResidencia: 'Medellín',
          paisResidencia: 'Colombia',
          contrasena: 'asesor123',
          activo: true,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          updatedAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ];

      await _saveUsers(sampleUsers);
    }

    print('✅ Datos de ejemplo inicializados en localStorage');
  }

  // CRUD para Contactos

  Future<List<Contact>> getAllContacts() async {
    try {
      final contactsJson = html.window.localStorage[_contactsKey];
      if (contactsJson == null) return [];

      final List<dynamic> contactsList = json.decode(contactsJson);
      return contactsList.map((json) => Contact.fromMap(json)).toList();
    } catch (e) {
      print('❌ Error obteniendo contactos: $e');
      return [];
    }
  }

  Future<int> insertContact(Contact contact) async {
    try {
      final contacts = await getAllContacts();
      
      // Generar nuevo ID
      final newId = contacts.isEmpty ? 1 : contacts.map((c) => c.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      
      final newContact = contact.copyWith(
        id: newId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      contacts.add(newContact);
      await _saveContacts(contacts);
      
      return newId;
    } catch (e) {
      print('❌ Error insertando contacto: $e');
      rethrow;
    }
  }

  Future<bool> updateContact(Contact contact) async {
    try {
      final contacts = await getAllContacts();
      final index = contacts.indexWhere((c) => c.id == contact.id);
      
      if (index != -1) {
        contacts[index] = contact.copyWith(updatedAt: DateTime.now());
        await _saveContacts(contacts);
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error actualizando contacto: $e');
      return false;
    }
  }

  Future<bool> deleteContact(int id) async {
    try {
      final contacts = await getAllContacts();
      contacts.removeWhere((contact) => contact.id == id);
      await _saveContacts(contacts);
      return true;
    } catch (e) {
      print('❌ Error eliminando contacto: $e');
      return false;
    }
  }

  Future<void> _saveContacts(List<Contact> contacts) async {
    try {
      final contactsJson = json.encode(contacts.map((c) => c.toMap()).toList());
      html.window.localStorage[_contactsKey] = contactsJson;
    } catch (e) {
      print('❌ Error guardando contactos: $e');
      rethrow;
    }
  }

  // CRUD para Usuarios

  Future<List<User>> getAllUsers() async {
    try {
      final usersJson = html.window.localStorage[_usersKey];
      if (usersJson == null) return [];

      final List<dynamic> usersList = json.decode(usersJson);
      return usersList.map((json) => User.fromMap(json)).toList();
    } catch (e) {
      print('❌ Error obteniendo usuarios: $e');
      return [];
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final users = await getAllUsers();
      
      final user = users.where((u) => 
        u.email.toLowerCase() == email.toLowerCase() && 
        u.contrasena == password && 
        u.activo
      ).firstOrNull;
      
      return user;
    } catch (e) {
      print('❌ Error en login local: $e');
      return null;
    }
  }

  Future<int> insertUser(User user) async {
    try {
      final users = await getAllUsers();
      
      // Generar nuevo ID
      final newId = users.isEmpty ? 1 : users.map((u) => u.idUsuario ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      
      final newUser = user.copyWith(
        idUsuario: newId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      users.add(newUser);
      await _saveUsers(users);
      
      return newId;
    } catch (e) {
      print('❌ Error insertando usuario: $e');
      rethrow;
    }
  }

  Future<bool> updateUser(User user) async {
    try {
      final users = await getAllUsers();
      final index = users.indexWhere((u) => u.idUsuario == user.idUsuario);
      
      if (index != -1) {
        users[index] = user.copyWith(updatedAt: DateTime.now());
        await _saveUsers(users);
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error actualizando usuario: $e');
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      final users = await getAllUsers();
      users.removeWhere((user) => user.idUsuario == id);
      await _saveUsers(users);
      return true;
    } catch (e) {
      print('❌ Error eliminando usuario: $e');
      return false;
    }
  }

  Future<void> _saveUsers(List<User> users) async {
    try {
      final usersJson = json.encode(users.map((u) => u.toMap()).toList());
      html.window.localStorage[_usersKey] = usersJson;
    } catch (e) {
      print('❌ Error guardando usuarios: $e');
      rethrow;
    }
  }

  // Limpiar todos los datos
  Future<void> clearAllData() async {
    html.window.localStorage.remove(_contactsKey);
    html.window.localStorage.remove(_usersKey);
    html.window.localStorage.remove(_quotesKey);
    html.window.localStorage.remove(_reservationsKey);
    print('🗑️ Todos los datos locales eliminados');
  }
}
