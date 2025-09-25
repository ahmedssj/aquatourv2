#!/bin/bash
set -e

echo "🚀 Build robusto para Vercel..."

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

# Intentar con pubspec normal primero
echo "📦 Intentando con dependencias normales..."
if flutter pub get; then
    echo "✅ Dependencias normales funcionan"
else
    echo "⚠️ Dependencias normales fallan, usando versión minimal..."
    cp pubspec-minimal.yaml pubspec.yaml
    rm -f pubspec.lock
    flutter pub get
fi

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
