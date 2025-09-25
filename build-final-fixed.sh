#!/bin/bash
set -e

echo "🚀 Build final con correcciones automáticas..."

# Descargar Flutter 3.22.0
echo "📦 Descargando Flutter 3.22.0..."
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.0-stable.tar.xz | tar xJ

# Configurar PATH
export PATH="$PWD/flutter/bin:$PATH"

# Configurar Git
git config --global --add safe.directory "$PWD/flutter"

# Verificar Flutter
echo "🔍 Verificando Flutter..."
flutter --version

# Configurar para web
echo "🌐 Habilitando web..."
flutter config --enable-web --no-analytics

# Limpiar
rm -f pubspec.lock

# Usar pubspec minimal (sin google_fonts)
echo "📦 Usando configuración minimal..."
cp pubspec-minimal.yaml pubspec.yaml

# Reemplazar google_fonts en todos los archivos Dart
echo "🔧 Eliminando referencias a google_fonts..."
find lib -name "*.dart" -type f -exec sed -i "s/import 'package:google_fonts\/google_fonts.dart';//g" {} \;
find lib -name "*.dart" -type f -exec sed -i "s/GoogleFonts\.[^(]*(/TextStyle(/g" {} \;
find lib -name "*.dart" -type f -exec sed -i "s/GoogleFonts\..*,/fontFamily: 'Roboto',/g" {} \;

# Instalar dependencias
echo "📦 Instalando dependencias..."
flutter pub get

# Build
echo "🏗️ Construyendo aplicación..."
flutter build web --release

# Verificar
if [ -f "build/web/index.html" ]; then
    echo "✅ ¡Build exitoso!"
    echo "📁 Archivos generados:"
    ls -la build/web/ | head -5
else
    echo "❌ Error en build"
    echo "📁 Contenido actual:"
    ls -la
    exit 1
fi

echo "🎉 Deploy completado!"
