// Configuración de tests para evitar problemas con dart:html
// Este archivo se puede usar para configurar tests específicos para web

import 'package:flutter/foundation.dart';

bool get isWeb => kIsWeb;

// Función helper para tests que requieren web
void skipIfNotWeb(String reason) {
  if (!kIsWeb) {
    // Skip test if not running on web
    return;
  }
}
