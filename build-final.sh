#!/bin/bash
set -e

echo "🚀 Build final para Vercel..."

# Usar Flutter 3.22.0 que es estable y compatible
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

# Limpiar pubspec.lock para evitar conflictos
rm -f pubspec.lock

# Obtener dependencias
echo "📦 Instalando dependencias..."
flutter pub get

# Build
echo "🏗️ Construyendo..."
flutter build web --release

# Verificar
if [ -f "build/web/index.html" ]; then
    echo "✅ ¡Build exitoso!"
    ls build/web/
else
    echo "❌ Error en build"
    exit 1
fi
