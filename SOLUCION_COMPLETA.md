# 🔧 Solución Completa - AquaTour CRM

## ❌ Problema: Error "No file or variants found for asset: .env"

Este error ocurre porque Flutter necesita el archivo `.env` que está declarado en `pubspec.yaml`.

## ✅ Solución Automática (Recomendada)

Ejecuta el script de configuración automática:

```bash
.\setup.bat
```

Este script hará todo automáticamente:
- ✅ Crear archivo `.env` para Flutter
- ✅ Configurar backend
- ✅ Instalar dependencias
- ✅ Probar conexión a base de datos
- ✅ Configurar datos de ejemplo
- ✅ Iniciar servidor backend
- ✅ Iniciar aplicación Flutter

## ✅ Solución Manual (Paso a Paso)

### 1. Crear archivo .env para Flutter

```bash
# Crear el archivo .env en la raíz del proyecto
echo # Configuracion de Variables de Entorno > .env
echo API_BASE_URL=http://localhost:3000/api >> .env
echo APP_ENV=development >> .env
echo DEBUG=true >> .env
```

### 2. Configurar Backend

```bash
# Ir al backend
cd backend

# Copiar configuración
copy .env.example .env

# Instalar dependencias
npm install

# Probar conexión
npm run test-db

# Configurar base de datos
npm run setup
```

### 3. Iniciar Servicios

```bash
# Terminal 1: Iniciar backend
cd backend
npm run dev

# Terminal 2: Iniciar Flutter (en otra terminal)
cd ..
flutter run -d chrome
```

## 📋 Contenido del archivo .env (Flutter)

Tu archivo `.env` debe contener:

```env
# Configuracion de Variables de Entorno
API_BASE_URL=http://localhost:3000/api
APP_ENV=development
DEBUG=true
```

## 📋 Contenido del archivo backend/.env

Tu archivo `backend/.env` debe contener:

```env
# Configuración del servidor
PORT=3000
NODE_ENV=development

# Base de datos MySQL en Clever Cloud
DB_HOST=b8efu6n5kvpd18l7euw3-mysql.services.clever-cloud.com
DB_PORT=3306
DB_NAME=b8efu6n5kvpd18l7euw3
DB_USER=uhqu4winvnanwdqy
DB_PASSWORD=GDn4jPxnPiTGFDVx0TTq

# JWT Secrets
JWT_SECRET=aquatour-super-secret-jwt-key-2024-clever-cloud
JWT_REFRESH_SECRET=aquatour-refresh-secret-jwt-key-2024-clever-cloud
JWT_EXPIRES_IN=1h
JWT_REFRESH_EXPIRES_IN=7d

# CORS
CORS_ORIGIN=http://localhost:3000,https://your-flutter-app-url.com

# Rate limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

## 🧪 Verificar que Todo Funciona

### 1. Backend API (http://localhost:3000)
```bash
# Verificar salud de la API
curl http://localhost:3000/api/health

# Probar login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"superadmin@aquatour.com","password":"superadmin123"}'
```

### 2. Flutter App
- ✅ Debe mostrar "Conectado a base de datos" en verde
- ✅ Login debe funcionar con usuarios de prueba
- ✅ Navegación debe funcionar según el rol

## 👥 Usuarios de Prueba

- **Super Admin:** `superadmin@aquatour.com` / `superadmin123`
- **Admin:** `davidg@aquatour.com` / `Osquitar07`
- **Asesor:** `asesor@aquatour.com` / `asesor123`

## 🔍 Diagnóstico de Problemas

### Error: "No file or variants found for asset: .env"
**Solución:** Crear archivo `.env` en la raíz del proyecto

### Error: "Connection refused" en Flutter
**Solución:** Asegurarse de que el backend esté ejecutándose en `http://localhost:3000`

### Error: "Database connection failed"
**Solución:** Verificar credenciales en `backend/.env`

### Error: "Invalid credentials"
**Solución:** Usar usuarios de prueba listados arriba

## 🎯 Resultado Esperado

Después de seguir estos pasos:

1. ✅ **Backend API** funcionando en `http://localhost:3000`
2. ✅ **Flutter App** funcionando en Chrome
3. ✅ **Conexión a base de datos** MySQL en Clever Cloud
4. ✅ **Login funcional** con usuarios reales
5. ✅ **Datos sincronizados** entre app y base de datos

## 🚀 Para Producción

Una vez que todo funcione localmente:

1. **Desplegar backend** en Clever Cloud
2. **Actualizar API_BASE_URL** en Flutter con la URL de producción
3. **Compilar Flutter** para web/móvil
4. **¡Listo para usar!**

---

## 📞 ¿Aún tienes problemas?

Si después de seguir estos pasos sigues teniendo problemas:

1. **Ejecuta `.\setup.bat`** para configuración automática
2. **Verifica que ambos archivos `.env` existan**
3. **Asegúrate de que el backend esté ejecutándose**
4. **Revisa la consola de Chrome** para errores de JavaScript

¡Tu AquaTour CRM estará funcionando perfectamente! 🌊
