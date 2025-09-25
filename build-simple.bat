@echo off
echo.
echo ========================================
echo   AquaTour CRM - Build Simple
echo ========================================
echo.

echo 📋 Configurando variables de entorno para producción...

echo # Configuracion para Produccion > .env
echo API_BASE_URL=https://aquatour-crm-api.vercel.app/api >> .env
echo APP_ENV=production >> .env
echo DEBUG=false >> .env
echo APP_NAME=AquaTour CRM >> .env
echo ALLOWED_ROLES=superadministrador,administrador,asesor >> .env

echo ✅ Variables de entorno configuradas

echo.
echo 🧹 Limpiando builds anteriores...
if exist build rmdir /s /q build

echo.
echo 📦 Obteniendo dependencias...
call flutter pub get

echo.
echo 🏗️ Construyendo para web (producción)...
call flutter build web --release

echo.
echo 📁 Verificando archivos de build...
if exist build\web\index.html (
    echo ✅ Build completado exitosamente
    echo.
    echo 📋 Archivos principales generados:
    if exist build\web\main.dart.js echo ✅ main.dart.js
    if exist build\web\flutter.js echo ✅ flutter.js
    if exist build\web\canvaskit echo ✅ canvaskit/
    if exist build\web\assets echo ✅ assets/
    if exist build\web\icons echo ✅ icons/
    echo.
    echo 🚀 ¡Build listo para deploy en Vercel!
) else (
    echo ❌ Error: No se encontró index.html en build/web
    echo.
    echo 🔧 Intentando diagnóstico...
    if exist build\web echo ✅ Carpeta build/web existe
    if exist build\web echo 📁 Contenido de build/web:
    if exist build\web dir build\web
    exit /b 1
)

echo.
echo 🎉 ¡Listo para deploy!
echo.
pause
