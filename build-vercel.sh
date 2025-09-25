#!/bin/bash
set -e  # Salir si cualquier comando falla

echo "🚀 Iniciando build para Vercel..."

# Crear directorio temporal para Flutter
mkdir -p /tmp/flutter-install
cd /tmp/flutter-install

# Descargar Flutter si no existe
if [ ! -d "/tmp/flutter" ]; then
    echo "📦 Descargando Flutter 3.16.0..."
    wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
    tar xf flutter_linux_3.16.0-stable.tar.xz
    mv flutter /tmp/flutter
fi

# Volver al directorio del proyecto
cd $VERCEL_PROJECT_ROOT || cd /vercel/path0

# Configurar PATH
export PATH="/tmp/flutter/bin:$PATH"

# Configurar Git
git config --global --add safe.directory /tmp/flutter

# Verificar Flutter
echo "🔍 Verificando Flutter..."
flutter --version || {
    echo "❌ Flutter no funciona, intentando instalación alternativa..."
    # Instalación alternativa
    curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz | tar xJ -C /tmp/
    export PATH="/tmp/flutter/bin:$PATH"
    flutter --version
}

# Configurar Flutter para web
echo "🌐 Configurando Flutter Web..."
flutter config --enable-web --no-analytics

# Obtener dependencias
echo "📦 Obteniendo dependencias..."
flutter pub get

# Limpiar build anterior
flutter clean

# Build para web
echo "🏗️ Construyendo aplicación..."
flutter build web --release --verbose

# Verificar resultado
if [ -f "build/web/index.html" ]; then
    echo "✅ Build exitoso!"
    echo "📁 Archivos generados:"
    ls -la build/web/ | head -10
    echo "📊 Tamaño total:"
    du -sh build/web/
else
    echo "❌ Build falló - index.html no encontrado"
    echo "📁 Contenido actual:"
    ls -la
    echo "📁 Contenido de build/:"
    ls -la build/ 2>/dev/null || echo "Directorio build no existe"
    exit 1
fi

echo "🎉 Build completado exitosamente!"
