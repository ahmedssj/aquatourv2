@echo off
echo.
echo ========================================
echo   AquaTour CRM - Build para Vercel
echo ========================================
echo.

echo 📋 Configurando variables de entorno para producción...

echo # Configuracion para Produccion > .env
echo API_BASE_URL=https://aquatour-crm-api.vercel.app/api >> .env
echo APP_ENV=production >> .env
echo DEBUG=false >> .env
echo APP_NAME=AquaTour CRM >> .env
echo APP_VERSION=1.0.0 >> .env
echo COMPANY_NAME=AquaTour >> .env
echo ALLOWED_ROLES=superadministrador,administrador,asesor >> .env
echo TOKEN_STORAGE_KEY=aquatour_auth_token >> .env
echo REFRESH_TOKEN_KEY=aquatour_refresh_token >> .env
echo USER_DATA_KEY=aquatour_user_data >> .env
echo SESSION_TIMEOUT=3600000 >> .env
echo ENABLE_LOCAL_STORAGE=true >> .env
echo ENABLE_OFFLINE_MODE=true >> .env
echo VERCEL_ENV=production >> .env

echo ✅ Variables de entorno configuradas para producción

echo.
echo 🧹 Limpiando builds anteriores...
if exist build rmdir /s /q build
if exist .dart_tool rmdir /s /q .dart_tool

echo.
echo 📦 Obteniendo dependencias...
call flutter pub get

echo.
echo 🔧 Analizando código...
call flutter analyze

echo.
echo 🧪 Ejecutando tests...
call flutter test

echo.
echo 🏗️ Construyendo para web (producción)...
call flutter build web --release --base-href /

echo.
echo 📁 Verificando archivos de build...
if exist build\web\index.html (
    echo ✅ Build completado exitosamente
    echo 📊 Tamaño del build:
    dir build\web /s /-c | find "File(s)"
) else (
    echo ❌ Error: No se encontró index.html en build/web
    exit /b 1
)

echo.
echo 📋 Archivos principales generados:
if exist build\web\main.dart.js echo ✅ main.dart.js
if exist build\web\flutter.js echo ✅ flutter.js
if exist build\web\canvaskit echo ✅ canvaskit/
if exist build\web\assets echo ✅ assets/
if exist build\web\icons echo ✅ icons/

echo.
echo 🚀 ¡Build listo para deploy en Vercel!
echo.
echo 📋 Próximos pasos:
echo 1. Sube tu código a GitHub
echo 2. Conecta el repositorio en Vercel
echo 3. Configura las variables de entorno en Vercel
echo 4. Deploy automático
echo.
echo 🌐 URLs esperadas:
echo    Frontend: https://aquatour-crm.vercel.app
echo    Backend:  https://aquatour-crm-api.vercel.app
echo.
pause
