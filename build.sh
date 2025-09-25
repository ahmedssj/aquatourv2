#!/bin/bash

# Configurar el PATH de Flutter
export PATH="$PATH:`pwd`/flutter/bin"

# Verificar si Flutter ya está descargado
if [ ! -d "flutter" ]; then
    echo "Descargando Flutter versión compatible..."
    curl -sL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz | tar xJ
fi

# Configurar Git
git config --global --add safe.directory /vercel/path0/flutter

# Configurar Flutter para web
echo "Configurando Flutter para web..."
flutter config --enable-web

# Verificar la instalación
echo "Verificando la instalación de Flutter..."
flutter --version
flutter doctor

# Limpiar y obtener dependencias
echo "Obteniendo dependencias..."
flutter clean
flutter pub get

# Construir la aplicación (sin flags problemáticos)
echo "Construyendo la aplicación para web..."
flutter build web --release

# Verificar que el directorio de salida existe
if [ -d "build/web" ]; then
    echo "✅ Construcción completada exitosamente en build/web/"
    echo "📁 Contenido del directorio build/web/:"
    ls -la build/web/
else
    echo "❌ Error: No se pudo encontrar el directorio de salida build/web"
    echo "📁 Contenido del directorio actual:"
    ls -la
    echo "📁 Contenido del directorio build (si existe):"
    ls -la build/ || echo "Directorio build no existe"
    exit 1
fi
