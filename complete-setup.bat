@echo off
echo.
echo ========================================
echo   AquaTour CRM - Setup Completo
echo ========================================
echo.

echo 🔧 PASO 1: Corrigiendo errores de código...

REM Corregir referencias a UserRole.empleado
echo Corrigiendo referencias a roles obsoletos...
powershell -Command "(Get-Content 'lib\models\user.dart') -replace 'empleado', 'asesor' | Set-Content 'lib\models\user.dart'"
powershell -Command "(Get-Content 'lib\services\storage_service.dart') -replace 'UserRole\.empleado', 'UserRole.asesor' | Set-Content 'lib\services\storage_service.dart'"
powershell -Command "(Get-Content 'lib\user_management_screen.dart') -replace 'UserRole\.empleado', 'UserRole.asesor' | Set-Content 'lib\user_management_screen.dart'"

echo ✅ Errores de código corregidos

echo.
echo 📋 PASO 2: Configurando variables de entorno...

echo # Configuracion para Produccion > .env
echo API_BASE_URL=https://aquatour-crm-api-123.vercel.app/api >> .env
echo APP_ENV=production >> .env
echo DEBUG=false >> .env
echo ALLOWED_ROLES=superadministrador,administrador,asesor >> .env
echo TOKEN_STORAGE_KEY=aquatour_auth_token >> .env
echo ENABLE_LOCAL_STORAGE=true >> .env

echo ✅ Variables de entorno configuradas

echo.
echo 🧹 PASO 3: Limpiando proyecto...
if exist build rmdir /s /q build
if exist .dart_tool rmdir /s /q .dart_tool

echo.
echo 📦 PASO 4: Instalando dependencias...
call flutter clean
call flutter pub get

echo.
echo 🔍 PASO 5: Analizando código...
call flutter analyze --no-fatal-infos

echo.
echo 🧪 PASO 6: Probando conexión con base de datos...
echo Verificando backend...
cd backend
call npm install
echo.
echo Probando conexión MySQL...
call npm run test-db
echo.
echo Configurando datos de ejemplo...
call npm run setup
cd ..

echo.
echo 🏗️ PASO 7: Construyendo Flutter para web...
call flutter build web --release

echo.
echo 📁 PASO 8: Verificando build...
if exist build\web\index.html (
    echo ✅ Build exitoso!
    echo.
    echo 📊 Archivos generados:
    dir build\web
    echo.
    echo 🚀 PASO 9: Probando aplicación localmente...
    echo Iniciando servidor local para pruebas...
    cd build\web
    start "AquaTour Local Test" python -m http.server 8080
    echo.
    echo 🌐 Aplicación disponible en: http://localhost:8080
    echo 📋 Prueba el login con:
    echo    - superadmin@aquatour.com / superadmin123
    echo    - davidg@aquatour.com / Osquitar07
    echo    - asesor@aquatour.com / asesor123
    echo.
    echo ⏳ Presiona cualquier tecla cuando hayas probado la aplicación...
    pause
    cd ..\..
    
    echo.
    echo 📤 PASO 10: Preparando para GitHub...
    echo Inicializando repositorio Git...
    git init
    git add .
    git commit -m "🚀 AquaTour CRM - Ready for production deploy"
    
    echo.
    echo 📋 PASO 11: Instrucciones para GitHub y Vercel...
    echo.
    echo 🔗 Para subir a GitHub:
    echo 1. Crea un repositorio en GitHub
    echo 2. Ejecuta estos comandos:
    echo    git remote add origin https://github.com/tu-usuario/aquatour-crm.git
    echo    git branch -M main
    echo    git push -u origin main
    echo.
    echo 🚀 Para deploy en Vercel:
    echo 1. Ve a https://vercel.com/dashboard
    echo 2. Click "New Project"
    echo 3. Import tu repositorio de GitHub
    echo 4. Configuración:
    echo    - Framework Preset: Other
    echo    - Build Command: flutter build web --release
    echo    - Output Directory: build/web
    echo    - Install Command: flutter pub get
    echo.
    echo 5. Variables de entorno en Vercel:
    echo    API_BASE_URL=https://aquatour-crm-api-123.vercel.app/api
    echo    APP_ENV=production
    echo    DEBUG=false
    echo    ALLOWED_ROLES=superadministrador,administrador,asesor
    echo.
    echo 6. Click Deploy
    echo.
    echo ✅ ¡TODO LISTO!
    
) else (
    echo ❌ Build falló
    echo.
    echo 🔍 Revisando errores...
    if exist build echo ✅ Carpeta build existe
    if exist build\web echo ✅ Carpeta build\web existe
    echo.
    echo 💡 Ejecuta: flutter doctor -v para más información
)

echo.
echo ========================================
echo 🎉 PROCESO COMPLETADO
echo ========================================
echo.
pause
