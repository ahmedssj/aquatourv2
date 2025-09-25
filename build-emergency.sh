#!/bin/bash
set -e

echo "🚨 Build de emergencia - máxima compatibilidad..."

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

# Usar configuración minimal
echo "📦 Usando configuración minimal..."
cp pubspec-minimal.yaml pubspec.yaml

# Usar main.dart simplificado
echo "🔧 Usando main.dart simplificado..."
cp lib/main-simple.dart lib/main.dart

# Limpiar
rm -f pubspec.lock

# Instalar dependencias
echo "📦 Instalando dependencias..."
flutter pub get

# Build
echo "🏗️ Construyendo aplicación..."
flutter build web --release

# Verificar
if [ -f "build/web/index.html" ]; then
    echo "✅ ¡Build de emergencia exitoso!"
    echo "📁 Archivos generados:"
    ls -la build/web/ | head -5
else
    echo "❌ Error en build de emergencia"
    echo "📁 Contenido actual:"
    ls -la
    exit 1
fi

echo "🎉 Deploy de emergencia completado!"
