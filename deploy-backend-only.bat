@echo off
echo.
echo ========================================
echo   AquaTour CRM - Deploy Solo Backend
echo ========================================
echo.

echo 🔧 Preparando backend para deploy en Vercel...

cd backend

echo.
echo 📋 Verificando archivos necesarios...
if exist "server.js" (
    echo ✅ server.js
) else (
    echo ❌ server.js - FALTA
    pause
    exit /b 1
)

if exist "package.json" (
    echo ✅ package.json
) else (
    echo ❌ package.json - FALTA
    pause
    exit /b 1
)

if exist "vercel.json" (
    echo ✅ vercel.json
) else (
    echo ❌ vercel.json - FALTA
    pause
    exit /b 1
)

echo.
echo 📦 Instalando dependencias...
call npm install

echo.
echo 🧪 Probando conexión a base de datos...
call npm run test-db

echo.
echo 📊 Configurando datos de ejemplo...
call npm run setup

echo.
echo ✅ ¡Backend listo para deploy!
echo.
echo 🚀 Próximos pasos para Vercel:
echo.
echo 1. Ve a https://vercel.com/dashboard
echo 2. Click "New Project"
echo 3. Import tu repositorio de GitHub
echo 4. Configuración:
echo    - Framework Preset: Node.js
echo    - Root Directory: backend
echo    - Build Command: npm install
echo    - Output Directory: ./
echo.
echo 5. Variables de entorno:
echo    NODE_ENV=production
echo    PORT=3000
echo    DB_HOST=b8efu6n5kvpd18l7euw3-mysql.services.clever-cloud.com
echo    DB_PORT=3306
echo    DB_NAME=b8efu6n5kvpd18l7euw3
echo    DB_USER=uhqu4winvnanwdqy
echo    DB_PASSWORD=GDn4jPxnPiTGFDVx0TTq
echo    JWT_SECRET=aquatour-super-secret-jwt-key-2024-production
echo    JWT_REFRESH_SECRET=aquatour-refresh-secret-jwt-key-2024-production
echo    ALLOWED_LOGIN_ROLES=superadministrador,administrador,asesor
echo    CORS_ORIGIN=*
echo.
echo 6. Click Deploy
echo.
echo 🧪 Para probar la API desplegada:
echo    GET https://tu-url.vercel.app/api/health
echo    POST https://tu-url.vercel.app/api/auth/login
echo.
echo 👥 Usuarios de prueba:
echo    - superadmin@aquatour.com / superadmin123
echo    - davidg@aquatour.com / Osquitar07
echo    - asesor@aquatour.com / asesor123
echo.
echo ❌ Los clientes están BLOQUEADOS (como solicitaste)
echo.

cd ..

echo ========================================
echo ✅ ¡BACKEND LISTO PARA VERCEL!
echo ========================================
echo.
pause
