# 🚀 Deploy AquaTour CRM a Vercel

## 📋 Resumen

Este proyecto está completamente configurado para deploy en Vercel con:
- ✅ **Login restringido** solo a roles administrativos (Superadministrador, Administrador, Asesor)
- ✅ **Variables de entorno completas** para producción
- ✅ **Base de datos MySQL** en Clever Cloud
- ✅ **API Backend** lista para Vercel
- ✅ **Frontend Flutter Web** optimizado

## 🎯 Pasos para Deploy

### 1. Preparar el Build

```bash
# Ejecutar script de build para producción
.\build-for-vercel.bat
```

Este script:
- ✅ Configura variables de entorno para producción
- ✅ Limpia builds anteriores
- ✅ Ejecuta tests
- ✅ Construye Flutter para web
- ✅ Optimiza para Vercel

### 2. Subir a GitHub

```bash
# Inicializar repositorio (si no existe)
git init

# Agregar archivos
git add .

# Commit inicial
git commit -m "🚀 AquaTour CRM - Ready for Vercel Deploy"

# Agregar remote (reemplaza con tu repositorio)
git remote add origin https://github.com/tu-usuario/aquatour-crm.git

# Push a GitHub
git push -u origin main
```

### 3. Deploy Frontend en Vercel

1. **Ve a [Vercel Dashboard](https://vercel.com/dashboard)**
2. **Click "New Project"**
3. **Importa tu repositorio de GitHub**
4. **Configuración del proyecto:**
   - **Framework Preset:** Other
   - **Root Directory:** `./` (raíz)
   - **Build Command:** `flutter build web --release`
   - **Output Directory:** `build/web`
   - **Install Command:** `flutter pub get`

5. **Variables de entorno en Vercel:**
   ```
   API_BASE_URL=https://aquatour-crm-api.vercel.app/api
   APP_ENV=production
   DEBUG=false
   ALLOWED_ROLES=superadministrador,administrador,asesor
   ```

6. **Deploy!**

### 4. Deploy Backend en Vercel

1. **Crear nuevo proyecto en Vercel**
2. **Usar el mismo repositorio**
3. **Configuración del backend:**
   - **Framework Preset:** Node.js
   - **Root Directory:** `./backend`
   - **Build Command:** `npm install`
   - **Output Directory:** `./`
   - **Install Command:** `npm install`

4. **Variables de entorno del backend:**
   ```
   NODE_ENV=production
   PORT=3000
   DB_HOST=b8efu6n5kvpd18l7euw3-mysql.services.clever-cloud.com
   DB_PORT=3306
   DB_NAME=b8efu6n5kvpd18l7euw3
   DB_USER=uhqu4winvnanwdqy
   DB_PASSWORD=GDn4jPxnPiTGFDVx0TTq
   JWT_SECRET=aquatour-super-secret-jwt-key-2024-production-change-this
   JWT_REFRESH_SECRET=aquatour-refresh-secret-jwt-key-2024-production-change-this
   ALLOWED_LOGIN_ROLES=superadministrador,administrador,asesor
   CORS_ORIGIN=https://aquatour-crm.vercel.app
   ```

5. **Deploy!**

## 🔐 Seguridad Implementada

### ✅ Restricción de Login
- Solo **Superadministrador**, **Administrador** y **Asesor** pueden hacer login
- Los **Clientes** son bloqueados automáticamente
- Validación tanto en backend como frontend

### ✅ Variables de Entorno
- Configuración completa para desarrollo y producción
- Secrets seguros para JWT
- CORS configurado correctamente

### ✅ Base de Datos
- MySQL en Clever Cloud (ya configurado)
- Conexiones seguras con SSL
- Datos de ejemplo listos

## 👥 Usuarios de Prueba

Una vez desplegado, puedes usar estos usuarios:

- **Super Admin:** `superadmin@aquatour.com` / `superadmin123`
- **Admin:** `davidg@aquatour.com` / `Osquitar07`
- **Asesor:** `asesor@aquatour.com` / `asesor123`

❌ **Los clientes NO pueden hacer login** (por diseño)

## 🌐 URLs Esperadas

Después del deploy tendrás:

- **Frontend:** `https://aquatour-crm.vercel.app`
- **Backend API:** `https://aquatour-crm-api.vercel.app`

## 🧪 Verificar Deploy

### 1. Frontend
- ✅ Página de login carga correctamente
- ✅ Muestra "Conectado a base de datos" en verde
- ✅ Login funciona con usuarios administrativos
- ✅ Clientes son rechazados con mensaje de error

### 2. Backend API
```bash
# Verificar salud de la API
curl https://aquatour-crm-api.vercel.app/api/health

# Probar login
curl -X POST https://aquatour-crm-api.vercel.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"superadmin@aquatour.com","password":"superadmin123"}'
```

## 🔧 Configuración Avanzada

### Variables de Entorno Completas

#### Frontend (.env)
```env
API_BASE_URL=https://aquatour-crm-api.vercel.app/api
APP_ENV=production
DEBUG=false
APP_NAME=AquaTour CRM
ALLOWED_ROLES=superadministrador,administrador,asesor
TOKEN_STORAGE_KEY=aquatour_auth_token
ENABLE_LOCAL_STORAGE=true
ENABLE_OFFLINE_MODE=true
```

#### Backend (backend/.env)
```env
NODE_ENV=production
DB_HOST=b8efu6n5kvpd18l7euw3-mysql.services.clever-cloud.com
DB_NAME=b8efu6n5kvpd18l7euw3
DB_USER=uhqu4winvnanwdqy
DB_PASSWORD=GDn4jPxnPiTGFDVx0TTq
JWT_SECRET=tu-secret-super-seguro-aqui
ALLOWED_LOGIN_ROLES=superadministrador,administrador,asesor
CORS_ORIGIN=https://aquatour-crm.vercel.app
```

## 🐛 Troubleshooting

### Error: "API no disponible"
- Verifica que el backend esté desplegado
- Revisa las variables de entorno en Vercel
- Verifica la URL de la API en el frontend

### Error: "CORS"
- Asegúrate de que `CORS_ORIGIN` incluya tu dominio de Vercel
- Verifica que ambos proyectos estén desplegados

### Error: "Acceso denegado"
- ✅ **Esto es correcto!** Solo roles administrativos pueden hacer login
- Usa usuarios de prueba listados arriba

### Error de Base de Datos
- Verifica credenciales MySQL en variables de entorno
- Asegúrate de que Clever Cloud esté activo

## 🎉 ¡Listo!

Tu AquaTour CRM estará funcionando en:
- 🌐 **Frontend:** https://aquatour-crm.vercel.app
- 🔧 **Backend:** https://aquatour-crm-api.vercel.app
- 📊 **Base de datos:** MySQL en Clever Cloud

Con login restringido solo a personal administrativo y todas las funcionalidades completas! 🌊
