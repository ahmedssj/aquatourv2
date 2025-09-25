#!/bin/bash
set -e

echo "🚀 Build con Flutter más reciente..."

# Usar Flutter 3.27.0 que tiene Dart SDK 3.6.0+
echo "📦 Descargando Flutter 3.27.0..."
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.0-stable.tar.xz | tar xJ

# Configurar PATH
export PATH="$PWD/flutter/bin:$PATH"

# Configurar Git
git config --global --add safe.directory "$PWD/flutter"

# Verificar Flutter y Dart SDK
echo "🔍 Verificando versiones..."
flutter --version
dart --version

# Configurar Flutter para web
echo "🌐 Configurando Flutter Web..."
flutter config --enable-web --no-analytics

# Obtener dependencias
echo "📦 Obteniendo dependencias..."
flutter pub get

# Build para web
echo "🏗️ Construyendo aplicación..."
flutter build web --release

# Verificar resultado
if [ -f "build/web/index.html" ]; then
    echo "✅ Build exitoso con Flutter 3.27.0!"
    echo "📁 Archivos generados:"
    ls -la build/web/ | head -5
else
    echo "❌ Build falló"
    ls -la
    exit 1
fi

echo "🎉 Deploy listo!"
