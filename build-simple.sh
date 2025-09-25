#!/bin/bash

echo "🚀 Iniciando build simple de Flutter..."

# Descargar e instalar Flutter
echo "📦 Descargando Flutter..."
curl -sL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz | tar xJ

# Configurar PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Configurar Git (evitar errores de permisos)
git config --global --add safe.directory /vercel/path0/flutter

# Habilitar web
echo "🌐 Habilitando Flutter Web..."
flutter config --enable-web

# Verificar instalación
echo "🔍 Verificando Flutter..."
flutter --version

# Obtener dependencias
echo "📦 Obteniendo dependencias..."
flutter pub get

# Build para web
echo "🏗️ Construyendo para web..."
flutter build web --release

# Verificar resultado
if [ -d "build/web" ] && [ -f "build/web/index.html" ]; then
    echo "✅ Build exitoso!"
    echo "📁 Archivos generados:"
    ls -la build/web/
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
