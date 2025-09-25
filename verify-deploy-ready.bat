@echo off
echo.
echo ========================================
echo   AquaTour CRM - Verificacion Deploy
echo ========================================
echo.

set "errors=0"

echo 🔍 Verificando archivos necesarios para deploy...
echo.

REM Verificar archivos principales
echo 📁 Verificando estructura de archivos...
if exist "pubspec.yaml" (
    echo ✅ pubspec.yaml
) else (
    echo ❌ pubspec.yaml - FALTA
    set /a errors+=1
)

if exist "lib\main.dart" (
    echo ✅ lib\main.dart
) else (
    echo ❌ lib\main.dart - FALTA
    set /a errors+=1
)

if exist "vercel.json" (
    echo ✅ vercel.json
) else (
    echo ❌ vercel.json - FALTA
    set /a errors+=1
)

if exist ".env.example" (
    echo ✅ .env.example
) else (
    echo ❌ .env.example - FALTA
    set /a errors+=1
)

echo.
echo 🔧 Verificando backend...
if exist "backend\server.js" (
    echo ✅ backend\server.js
) else (
    echo ❌ backend\server.js - FALTA
    set /a errors+=1
)

if exist "backend\package.json" (
    echo ✅ backend\package.json
) else (
    echo ❌ backend\package.json - FALTA
    set /a errors+=1
)

if exist "backend\vercel.json" (
    echo ✅ backend\vercel.json
) else (
    echo ❌ backend\vercel.json - FALTA
    set /a errors+=1
)

if exist "backend\.env.example" (
    echo ✅ backend\.env.example
) else (
    echo ❌ backend\.env.example - FALTA
    set /a errors+=1
)

echo.
echo 📋 Verificando documentación...
if exist "DEPLOY_TO_VERCEL.md" (
    echo ✅ DEPLOY_TO_VERCEL.md
) else (
    echo ❌ DEPLOY_TO_VERCEL.md - FALTA
    set /a errors+=1
)

if exist "README.md" (
    echo ✅ README.md
) else (
    echo ⚠️  README.md - Recomendado
)

echo.
echo 🧪 Verificando dependencias Flutter...
call flutter --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Flutter instalado
    call flutter pub get >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ Dependencias Flutter OK
    ) else (
        echo ❌ Error en dependencias Flutter
        set /a errors+=1
    )
) else (
    echo ❌ Flutter no encontrado
    set /a errors+=1
)

echo.
echo 🔧 Verificando Node.js para backend...
call node --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Node.js instalado
    cd backend
    call npm install >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ Dependencias Node.js OK
    ) else (
        echo ❌ Error en dependencias Node.js
        set /a errors+=1
    )
    cd ..
) else (
    echo ❌ Node.js no encontrado
    set /a errors+=1
)

echo.
echo 🔐 Verificando configuración de seguridad...

REM Verificar que los roles estén configurados
findstr /C:"ALLOWED_LOGIN_ROLES" backend\.env.example >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Roles de login configurados en backend
) else (
    echo ❌ Roles de login NO configurados en backend
    set /a errors+=1
)

findstr /C:"ALLOWED_ROLES" .env.example >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Roles configurados en frontend
) else (
    echo ❌ Roles NO configurados en frontend
    set /a errors+=1
)

echo.
echo 📊 Verificando configuración de base de datos...
findstr /C:"DB_HOST=b8efu6n5kvpd18l7euw3" backend\.env.example >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Base de datos MySQL configurada
) else (
    echo ❌ Base de datos NO configurada
    set /a errors+=1
)

echo.
echo ========================================
if %errors% equ 0 (
    echo ✅ ¡TODO LISTO PARA DEPLOY!
    echo.
    echo 🚀 Próximos pasos:
    echo 1. Ejecutar: .\build-for-vercel.bat
    echo 2. Subir a GitHub: git add . ^&^& git commit -m "Ready for deploy" ^&^& git push
    echo 3. Crear proyecto en Vercel
    echo 4. Configurar variables de entorno
    echo 5. ¡Deploy automático!
    echo.
    echo 👥 Usuarios que podrán hacer login:
    echo    ✅ Superadministrador
    echo    ✅ Administrador  
    echo    ✅ Asesor
    echo    ❌ Cliente ^(BLOQUEADO^)
    echo.
    echo 🌐 URLs esperadas:
    echo    Frontend: https://aquatour-crm.vercel.app
    echo    Backend:  https://aquatour-crm-api.vercel.app
) else (
    echo ❌ ERRORES ENCONTRADOS: %errors%
    echo.
    echo 🔧 Soluciona los errores antes de continuar
    echo 📋 Revisa los archivos marcados con ❌
)
echo ========================================
echo.
pause
