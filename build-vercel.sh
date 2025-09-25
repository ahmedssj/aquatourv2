#!/bin/bash
set -e

echo "🚀 Iniciando build simplificado para Vercel..."

# Descargar e instalar Flutter directamente en el directorio actual
echo "📦 Descargando Flutter 3.16.0..."
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz | tar xJ

# Configurar PATH
export PATH="$PWD/flutter/bin:$PATH"

# Configurar Git
git config --global --add safe.directory "$PWD/flutter"

# Verificar Flutter
echo "🔍 Verificando Flutter..."
flutter --version

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
    echo "✅ Build exitoso!"
    echo "📁 Archivos principales:"
    ls -la build/web/ | grep -E "(index.html|main.dart.js|flutter.js)" || ls -la build/web/ | head -5
else
    echo "❌ Build falló"
    echo "📁 Directorio actual:"
    ls -la
    if [ -d "build" ]; then
        echo "📁 Contenido de build/:"
        ls -la build/
    fi
    exit 1
fi

echo "🎉 Build completado!"
