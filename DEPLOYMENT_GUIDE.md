# 🚀 Guía de Despliegue - AquaTour CRM

Esta guía te ayudará a desplegar tu aplicación AquaTour CRM con base de datos real en Clever Cloud.

## 📋 Resumen de lo Implementado

✅ **Backend API completo** con Node.js y Express  
✅ **Base de datos MySQL** configurada en Clever Cloud  
✅ **Autenticación JWT** con refresh tokens  
✅ **Aplicación Flutter** actualizada para usar API real  
✅ **Fallback local** cuando la API no está disponible  
✅ **Seguridad completa** con validaciones y rate limiting  

## 🎯 Pasos para Desplegar

### Paso 1: Preparar el Backend

1. **Navega a la carpeta backend:**
   ```bash
   cd backend
   ```

2. **Instala dependencias:**
   ```bash
   npm install
   ```

3. **Configura variables de entorno:**
   ```bash
   copy .env.example .env
   ```
   
   Edita `.env` con tus datos (ya están configurados):
   ```env
   DB_HOST=b8efu6n5kvpd18l7euw3-mysql.services.clever-cloud.com
   DB_PORT=3306
   DB_NAME=b8efu6n5kvpd18l7euw3
   DB_USER=uhqu4winvnanwdqy
   DB_PASSWORD=GDn4jPxnPiTGFDVx0TTq
   ```

4. **Prueba la conexión a la base de datos:**
   ```bash
   npm run test-db
   ```
   
   Esto verificará que puedes conectarte a tu base de datos MySQL en Clever Cloud.

5. **Configura la base de datos:**
   ```bash
   npm run setup
   ```

6. **Prueba localmente:**
   ```bash
   npm run dev
   ```
   
   Deberías ver: `✅ ¡Servidor iniciado exitosamente!`

### Paso 2: Desplegar en Clever Cloud

1. **Ve a [Clever Cloud Console](https://console.clever-cloud.com/)**

2. **Crea una nueva aplicación:**
   - Selecciona "Create an application"
   - Elige "Node.js"
   - Conecta tu repositorio Git o sube los archivos

3. **Configura variables de entorno:**
   En la sección "Environment variables", agrega:
   ```
   NODE_ENV=production
   PORT=8080
   DB_HOST=b8efu6n5kvpd18l7euw3-mysql.services.clever-cloud.com
   DB_PORT=3306
   DB_NAME=b8efu6n5kvpd18l7euw3
   DB_USER=uhqu4winvnanwdqy
   DB_PASSWORD=GDn4jPxnPiTGFDVx0TTq
   JWT_SECRET=aquatour-super-secret-jwt-key-2024-clever-cloud
   JWT_REFRESH_SECRET=aquatour-refresh-secret-jwt-key-2024-clever-cloud
   CORS_ORIGIN=*
   ```

4. **Despliega:**
   - Haz commit y push de tu código
   - Clever Cloud desplegará automáticamente
   - Espera a que termine el despliegue

5. **Obtén tu URL de API:**
   Una vez desplegado, tendrás una URL como:
   ```
   https://app-12345678-1234-1234-1234-123456789012.cleverapps.io
   ```

### Paso 3: Actualizar Flutter App

1. **Actualiza `.env.local`:**
   ```env
   API_BASE_URL=https://tu-url-de-clever-cloud.cleverapps.io/api
   ```

2. **Prueba la conexión:**
   - Ejecuta tu app Flutter
   - Intenta hacer login
   - Deberías ver "Conectado a base de datos" en verde

## 🧪 Probar la API

### Usuarios de Prueba

Una vez desplegada, puedes usar estos usuarios:

- **Super Admin:** `superadmin@aquatour.com` / `superadmin123`
- **Admin:** `davidg@aquatour.com` / `Osquitar07`
- **Asesor:** `asesor@aquatour.com` / `asesor123`

### Endpoints Principales

```bash
# Verificar que la API funciona
GET https://tu-url.cleverapps.io/api/health

# Login
POST https://tu-url.cleverapps.io/api/auth/login
{
  "email": "superadmin@aquatour.com",
  "password": "superadmin123"
}

# Obtener usuarios (requiere token)
GET https://tu-url.cleverapps.io/api/users
Authorization: Bearer tu-jwt-token
```

## 🔧 Configuración de Base de Datos

Tu base de datos MySQL ya está configurada con:

### Tablas Creadas:
- ✅ `usuarios` - Gestión de usuarios con roles
- ✅ `contactos` - Gestión de contactos
- ✅ `refresh_tokens` - Tokens de autenticación

### Datos de Ejemplo:
- ✅ 3 usuarios con diferentes roles
- ✅ 3 contactos de ejemplo
- ✅ Contraseñas hasheadas con bcrypt

## 🔒 Seguridad Implementada

- ✅ **JWT Tokens** con expiración (1 hora)
- ✅ **Refresh Tokens** (7 días)
- ✅ **Contraseñas hasheadas** con bcrypt
- ✅ **Rate Limiting** (100 requests/15 min)
- ✅ **CORS configurado**
- ✅ **Validación de datos** con express-validator
- ✅ **Headers de seguridad** con Helmet

## 📱 Funcionalidades Flutter

### ✅ Implementado:
- **Login con API real** y fallback local
- **Indicadores de conexión** visual
- **Manejo de errores** robusto
- **Persistencia de sesión** con JWT
- **Refresh automático** de tokens
- **Navegación por roles** (admin/empleado)

### 🎯 Flujo de Autenticación:
1. App intenta conectar con API
2. Si API disponible → Login con base de datos
3. Si API no disponible → Login local
4. Indicador visual muestra el estado
5. Tokens se guardan automáticamente
6. Refresh automático cuando expiran

## 🐛 Troubleshooting

### ❌ "API no disponible"
- Verifica que la URL en `.env.local` sea correcta
- Asegúrate de que la app esté desplegada en Clever Cloud
- Revisa los logs en Clever Cloud Console

### ❌ "Error de conexión a base de datos"
- Verifica las credenciales MySQL en variables de entorno
- Asegúrate de que la base de datos esté activa
- Ejecuta `npm run setup` para reconfigurar

### ❌ "Token expirado"
- Los tokens se refrescan automáticamente
- Si persiste, cierra sesión y vuelve a entrar

### ❌ "CORS Error"
- Agrega tu dominio a `CORS_ORIGIN`
- Para desarrollo usa `*` o `http://localhost:3000`

## 📊 Monitoreo

### Logs de la API:
- Ve a Clever Cloud Console → Tu app → Logs
- Verás requests, errores y información de debug

### Métricas:
- Clever Cloud proporciona métricas de CPU, memoria y requests
- Configura alertas si es necesario

## 🔄 Actualizaciones

### Para actualizar el backend:
1. Haz cambios en tu código
2. `git add . && git commit -m "Update"`
3. `git push`
4. Clever Cloud desplegará automáticamente

### Para actualizar la app Flutter:
1. Modifica el código
2. Ejecuta `flutter run` para probar
3. Compila para producción cuando esté listo

## 🎉 ¡Listo!

Tu aplicación AquaTour CRM ahora está completamente conectada a una base de datos real con:

- ✅ **Backend API** desplegado en Clever Cloud
- ✅ **Base de datos MySQL** configurada y funcionando
- ✅ **App Flutter** con conexión real y fallback local
- ✅ **Autenticación segura** con JWT
- ✅ **Gestión completa** de usuarios y contactos

### 🔗 URLs Importantes:
- **API Health:** `https://tu-url.cleverapps.io/api/health`
- **API Info:** `https://tu-url.cleverapps.io/api/info`
- **Clever Cloud Console:** https://console.clever-cloud.com/

### 📞 Soporte:
Si tienes problemas, revisa:
1. Los logs en Clever Cloud Console
2. La configuración de variables de entorno
3. El estado de la base de datos MySQL
4. Los indicadores de conexión en la app Flutter
