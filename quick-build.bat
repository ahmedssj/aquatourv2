@echo off
echo.
echo ========================================
echo   AquaTour CRM - Build Rapido
echo ========================================
echo.

echo 📋 Configurando .env para producción...
echo API_BASE_URL=https://aquatour-crm-api.vercel.app/api > .env
echo APP_ENV=production >> .env
echo DEBUG=false >> .env
echo ALLOWED_ROLES=superadministrador,administrador,asesor >> .env

echo ✅ Variables configuradas

echo.
echo 🧹 Limpiando...
if exist build rmdir /s /q build

echo.
echo 📦 Obteniendo dependencias...
flutter pub get

echo.
echo 🏗️ Construyendo para web...
flutter build web --release

echo.
echo 📁 Verificando resultado...
if exist build\web\index.html (
    echo ✅ ¡Build exitoso!
    echo 📊 Archivos generados:
    dir build\web
    echo.
    echo 🚀 Listo para Vercel!
) else (
    echo ❌ Build falló
    echo 🔍 Contenido de build:
    if exist build dir build
)

echo.
pause
