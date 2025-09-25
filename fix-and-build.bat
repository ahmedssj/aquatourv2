@echo off
echo.
echo ========================================
echo   AquaTour CRM - Arreglar y Build
echo ========================================
echo.

echo 🔧 Paso 1: Configurando variables de entorno...

REM Pregunta por la URL del backend desplegado
set /p BACKEND_URL="Ingresa la URL de tu backend desplegado (ej: https://aquatour-api-123.vercel.app): "

if "%BACKEND_URL%"=="" (
    echo ⚠️ Usando URL por defecto...
    set BACKEND_URL=https://aquatour-crm-api.vercel.app
)

echo # Configuracion para Produccion > .env
echo API_BASE_URL=%BACKEND_URL%/api >> .env
echo APP_ENV=production >> .env
echo DEBUG=false >> .env
echo ALLOWED_ROLES=superadministrador,administrador,asesor >> .env
echo TOKEN_STORAGE_KEY=aquatour_auth_token >> .env
echo ENABLE_LOCAL_STORAGE=true >> .env

echo ✅ Variables configuradas con backend: %BACKEND_URL%

echo.
echo 🧹 Paso 2: Limpiando proyecto...
if exist build rmdir /s /q build
if exist .dart_tool rmdir /s /q .dart_tool

echo.
echo 📦 Paso 3: Obteniendo dependencias...
call flutter clean
call flutter pub get

echo.
echo 🔍 Paso 4: Verificando errores críticos...
echo Buscando referencias problemáticas...

REM Verificar que no haya referencias a empleado
findstr /S /I "UserRole.empleado" lib\*.dart > nul
if %errorlevel% equ 0 (
    echo ❌ Encontradas referencias a UserRole.empleado
    echo 🔧 Corrigiendo automáticamente...
    
    REM Crear script de PowerShell para reemplazar
    echo $files = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse > fix_roles.ps1
    echo foreach ($file in $files) { >> fix_roles.ps1
    echo     $content = Get-Content $file.FullName -Raw >> fix_roles.ps1
    echo     $content = $content -replace "UserRole\.empleado", "UserRole.asesor" >> fix_roles.ps1
    echo     Set-Content $file.FullName $content >> fix_roles.ps1
    echo } >> fix_roles.ps1
    
    powershell -ExecutionPolicy Bypass -File fix_roles.ps1
    del fix_roles.ps1
    
    echo ✅ Referencias corregidas
)

echo.
echo 🏗️ Paso 5: Intentando build...
call flutter build web --release

echo.
echo 📁 Paso 6: Verificando resultado...
if exist build\web\index.html (
    echo ✅ ¡Build exitoso!
    echo.
    echo 📊 Archivos generados:
    if exist build\web\main.dart.js echo ✅ main.dart.js
    if exist build\web\flutter.js echo ✅ flutter.js
    if exist build\web\assets echo ✅ assets/
    if exist build\web\icons echo ✅ icons/
    echo.
    echo 🚀 ¡Listo para deploy en Vercel!
    echo.
    echo 📋 Próximos pasos:
    echo 1. git add .
    echo 2. git commit -m "Frontend ready for deploy"
    echo 3. git push origin main
    echo 4. Crear proyecto en Vercel:
    echo    - Framework: Other
    echo    - Build Command: flutter build web --release
    echo    - Output Directory: build/web
    echo    - Root Directory: ./
    echo.
    echo 🌐 Tu backend: %BACKEND_URL%
    echo 🌐 Frontend será: https://aquatour-crm.vercel.app
    
) else (
    echo ❌ Build falló
    echo.
    echo 🔍 Diagnóstico:
    if exist build echo ✅ Carpeta build existe
    if exist build\web echo ✅ Carpeta build\web existe
    if exist build\web dir build\web
    echo.
    echo 💡 Posibles soluciones:
    echo 1. Verificar errores en el código
    echo 2. Ejecutar: flutter doctor
    echo 3. Revisar dependencias en pubspec.yaml
)

echo.
echo ========================================
pause
