import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aquatour/dashboard_screen.dart';
import 'package:aquatour/limited_dashboard_screen.dart';
import 'package:aquatour/widgets/custom_button.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:aquatour/services/auth_service.dart';
import 'package:aquatour/services/local_storage_service.dart';
import 'package:aquatour/models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _claveFormulario = GlobalKey<FormState>();
  final _controladorUsuario = TextEditingController();
  final _controladorClave = TextEditingController();
  bool _ocultarClave = true;
  final AuthService _authService = AuthService();
  final LocalStorageService _localStorageService = LocalStorageService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isApiAvailable = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    _controladorUsuario.dispose();
    _controladorClave.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    try {
      // Cargar variables de entorno
      await dotenv.load(fileName: ".env.local");
      
      // Inicializar servicios
      await _authService.initialize();
      await _localStorageService.initializeData();
      
      // Verificar si hay una sesión activa
      if (_authService.isLoggedIn) {
        _navigateToAppropriateScreen(_authService.currentUser!);
        return;
      }
      
      setState(() {
        _isApiAvailable = true; // Se actualizará cuando se haga el primer login
      });
    } catch (e) {
      print('⚠️ Error inicializando servicios: $e');
      setState(() {
        _errorMessage = 'Error inicializando la aplicación';
      });
    }
  }

  Future<void> _iniciarSesion() async {
    if (_claveFormulario.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final result = await _authService.login(
          _controladorUsuario.text.trim(),
          _controladorClave.text,
        );

        setState(() {
          _isLoading = false;
        });

        if (result.success && result.user != null && mounted) {
          _navigateToAppropriateScreen(result.user!);
        } else if (mounted) {
          setState(() {
            _errorMessage = result.errorMessage ?? 'Error desconocido';
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error de conexión: ${e.toString()}';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  void _navigateToAppropriateScreen(User user) {
    if (user.esAdministrador) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LimitedDashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4C39A6), Color(0xFF2C53A4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 50.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _claveFormulario,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const SizedBox(height: 16),
                        // Logo de AquaTour
                        Image.asset(
                          'assets/images/aqua-tour.png',
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'AquaTour CRM',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Inicia sesión para continuar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _controladorUsuario,
                          decoration: InputDecoration(
                            labelText: 'Usuario o correo',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: RequiredValidator(errorText: 'El correo o usuario es obligatorio').call,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _controladorClave,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _ocultarClave ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _ocultarClave = !_ocultarClave;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          obscureText: _ocultarClave,
                          validator: MinLengthValidator(6,
                                  errorText: 'La contraseña debe tener al menos 6 caracteres').call,
                        ),
                        const SizedBox(height: 24),
                        // Indicador de estado de conexión
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              border: Border.all(color: Colors.red.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Indicador de modo de conexión
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: _isApiAvailable ? Colors.green.shade50 : Colors.orange.shade50,
                            border: Border.all(
                              color: _isApiAvailable ? Colors.green.shade200 : Colors.orange.shade200,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isApiAvailable ? Icons.cloud_done : Icons.cloud_off,
                                color: _isApiAvailable ? Colors.green.shade600 : Colors.orange.shade600,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isApiAvailable ? 'Conectado a base de datos' : 'Modo local (sin conexión)',
                                style: TextStyle(
                                  color: _isApiAvailable ? Colors.green.shade700 : Colors.orange.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : CustomButton(
                                text: 'Iniciar Sesión',
                                onPressed: _iniciarSesion,
                                color: const Color(0xFF4C39A6),
                              ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
