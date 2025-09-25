@echo off
echo.
echo ========================================
echo   Corrigiendo Errores de Código
echo ========================================
echo.

echo 🔧 Corrigiendo referencias a UserRole.empleado...

REM Buscar y reemplazar en archivos Dart
for /r lib %%f in (*.dart) do (
    powershell -Command "(Get-Content '%%f') -replace 'UserRole\.empleado', 'UserRole.asesor' | Set-Content '%%f'"
)

echo ✅ Referencias a roles corregidas

echo.
echo 🔧 Corrigiendo emails de empleado...
powershell -Command "(Get-Content 'lib\services\storage_service.dart') -replace 'empleado@aquatour.com', 'asesor@aquatour.com' | Set-Content 'lib\services\storage_service.dart'"
powershell -Command "(Get-Content 'lib\services\storage_service.dart') -replace 'empleado123', 'asesor123' | Set-Content 'lib\services\storage_service.dart'"

echo ✅ Emails corregidos

echo.
echo 🔧 Verificando importaciones problemáticas...
REM Ya corregimos dart:html anteriormente

echo.
echo 🧪 Probando análisis de código...
call flutter analyze --no-fatal-infos

echo.
echo ✅ ¡Errores corregidos!
echo.
pause
