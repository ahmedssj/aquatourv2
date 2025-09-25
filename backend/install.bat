@echo off
echo.
echo ========================================
echo   AquaTour CRM API - Instalacion
echo ========================================
echo.

echo 📦 Instalando dependencias...
call npm install

echo.
echo 📋 Copiando archivo de configuracion...
if not exist .env (
    copy .env.example .env
    echo ✅ Archivo .env creado desde .env.example
    echo ⚠️  IMPORTANTE: Edita el archivo .env con tus credenciales reales
) else (
    echo ℹ️  El archivo .env ya existe
)

echo.
echo 🔧 Configurando base de datos...
call npm run setup

echo.
echo ✅ ¡Instalacion completada!
echo.
echo 🚀 Para iniciar el servidor:
echo    npm run dev     (desarrollo)
echo    npm start       (produccion)
echo.
echo 👥 Usuarios de prueba:
echo    Super Admin: superadmin@aquatour.com / superadmin123
echo    Admin: davidg@aquatour.com / Osquitar07
echo    Empleado: empleado@aquatour.com / empleado123
echo.
pause
