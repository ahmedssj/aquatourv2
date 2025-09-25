@echo off
echo.
echo ========================================
echo   AquaTour CRM - Configuracion Completa
echo ========================================
echo.

echo 📁 Creando archivo .env para Flutter...
echo # Configuracion de Variables de Entorno > .env
echo # URL de tu API REST (para desarrollo local) >> .env
echo API_BASE_URL=http://localhost:3000/api >> .env
echo. >> .env
echo # Configuracion de la aplicacion >> .env
echo APP_ENV=development >> .env
echo DEBUG=true >> .env

echo ✅ Archivo .env creado

echo.
echo 📦 Configurando backend...
cd backend

echo 📋 Copiando configuracion del backend...
if not exist .env (
    copy .env.example .env
    echo ✅ Archivo backend/.env creado
) else (
    echo ℹ️  El archivo backend/.env ya existe
)

echo 📦 Instalando dependencias del backend...
call npm install

echo 🔧 Probando conexion a la base de datos...
call npm run test-db

echo 📊 Configurando base de datos...
call npm run setup

echo.
echo 🚀 Iniciando servidor backend...
start "AquaTour API" cmd /k "npm run dev"

echo.
echo ⏳ Esperando que el servidor inicie...
timeout /t 5 /nobreak > nul

cd ..

echo.
echo 📱 Iniciando aplicacion Flutter...
start "AquaTour Flutter" cmd /k "flutter run -d chrome"

echo.
echo ✅ ¡Configuracion completada!
echo.
echo 🌐 Backend API: http://localhost:3000
echo 📱 Flutter App: Se abrira automaticamente
echo.
echo 👥 Usuarios de prueba:
echo    - superadmin@aquatour.com / superadmin123
echo    - davidg@aquatour.com / Osquitar07
echo    - asesor@aquatour.com / asesor123
echo.
pause
