# AquaTour CRM API Backend

API REST para el sistema CRM de AquaTour, construida con Node.js, Express y MySQL.

## 🚀 Características

- **Autenticación JWT** con refresh tokens
- **Base de datos MySQL** en Clever Cloud
- **Gestión de usuarios** con roles (empleado, administrador, superadministrador)
- **Gestión de contactos** con búsqueda y paginación
- **Seguridad** con Helmet, CORS y Rate Limiting
- **Validación** de datos con express-validator
- **Configuración automática** de base de datos

## 📋 Requisitos

- Node.js >= 16.0.0
- npm o yarn
- Base de datos MySQL (configurada en Clever Cloud)

## ⚙️ Instalación Local

1. **Clonar el repositorio:**
   ```bash
   cd backend
   ```

2. **Instalar dependencias:**
   ```bash
   npm install
   ```

3. **Configurar variables de entorno:**
   ```bash
   cp .env.example .env
   ```
   
   Edita el archivo `.env` con tus datos reales.

4. **Configurar base de datos:**
   ```bash
   npm run setup
   ```

5. **Iniciar servidor de desarrollo:**
   ```bash
   npm run dev
   ```

6. **Iniciar servidor de producción:**
   ```bash
   npm start
   ```

## 🌐 Despliegue en Clever Cloud

### Paso 1: Crear aplicación Node.js

1. Ve a [Clever Cloud Console](https://console.clever-cloud.com/)
2. Crea una nueva aplicación Node.js
3. Conecta tu repositorio Git

### Paso 2: Configurar variables de entorno

En la consola de Clever Cloud, agrega estas variables:

```bash
NODE_ENV=production
PORT=8080
DB_HOST=b8efu6n5kvpd18l7euw3-mysql.services.clever-cloud.com
DB_PORT=3306
DB_NAME=b8efu6n5kvpd18l7euw3
DB_USER=uhqu4winvnanwdqy
DB_PASSWORD=GDn4jPxnPiTGFDVx0TTq
JWT_SECRET=tu-super-secreto-jwt-aqui
JWT_REFRESH_SECRET=tu-super-secreto-refresh-aqui
JWT_EXPIRES_IN=1h
JWT_REFRESH_EXPIRES_IN=7d
CORS_ORIGIN=https://tu-app-flutter.com,http://localhost:3000
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

### Paso 3: Desplegar

1. Haz push a tu repositorio
2. Clever Cloud detectará automáticamente que es una app Node.js
3. La aplicación se construirá y desplegará automáticamente
4. La base de datos se configurará automáticamente en el primer despliegue

### Paso 4: Obtener URL de la API

Una vez desplegada, obtendrás una URL como:
```
https://app-12345678-1234-1234-1234-123456789012.cleverapps.io
```

Actualiza tu archivo `.env.local` en Flutter con esta URL:
```env
API_BASE_URL=https://tu-app-url.cleverapps.io/api
```

## 📚 Endpoints de la API

### Autenticación
- `POST /api/auth/login` - Iniciar sesión
- `POST /api/auth/refresh` - Refrescar token
- `POST /api/auth/logout` - Cerrar sesión
- `GET /api/auth/verify` - Verificar token

### Usuarios
- `GET /api/users` - Listar usuarios (admin)
- `GET /api/users/:id` - Obtener usuario
- `POST /api/users` - Crear usuario (admin)
- `PUT /api/users/:id` - Actualizar usuario
- `DELETE /api/users/:id` - Eliminar usuario (super admin)

### Contactos
- `GET /api/contacts` - Listar contactos
- `GET /api/contacts/:id` - Obtener contacto
- `POST /api/contacts` - Crear contacto
- `PUT /api/contacts/:id` - Actualizar contacto
- `DELETE /api/contacts/:id` - Eliminar contacto

### Utilidades
- `GET /` - Información general
- `GET /api/health` - Estado del servidor
- `GET /api/info` - Información de la API

## 👥 Usuarios de Prueba

Una vez configurada la base de datos, tendrás estos usuarios:

- **Super Admin:** `superadmin@aquatour.com` / `superadmin123`
- **Admin:** `davidg@aquatour.com` / `Osquitar07`
- **Empleado:** `empleado@aquatour.com` / `empleado123`

## 🔒 Seguridad

- Contraseñas hasheadas con bcrypt (12 rounds)
- JWT tokens con expiración
- Refresh tokens almacenados en base de datos
- Rate limiting (100 requests por 15 minutos)
- CORS configurado
- Helmet para headers de seguridad
- Validación de entrada con express-validator

## 🧪 Testing

Puedes probar los endpoints usando:

### Con curl:
```bash
# Login
curl -X POST https://tu-api-url.cleverapps.io/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"superadmin@aquatour.com","password":"superadmin123"}'

# Obtener usuarios (requiere token)
curl -X GET https://tu-api-url.cleverapps.io/api/users \
  -H "Authorization: Bearer tu-jwt-token-aqui"
```

### Con Postman:
1. Importa la colección desde `postman/AquaTour-CRM.postman_collection.json`
2. Configura la variable `base_url` con tu URL de API
3. Ejecuta el login para obtener el token
4. Los demás endpoints usarán automáticamente el token

## 📊 Base de Datos

### Estructura de Tablas

#### usuarios
- `id_usuario` (INT, PK, AUTO_INCREMENT)
- `nombre` (VARCHAR(100))
- `apellido` (VARCHAR(100))
- `email` (VARCHAR(255), UNIQUE)
- `rol` (ENUM: empleado, administrador, superadministrador)
- `tipo_documento` (VARCHAR(10))
- `num_documento` (VARCHAR(50))
- `fecha_nacimiento` (DATE)
- `genero` (VARCHAR(20))
- `telefono` (VARCHAR(20))
- `direccion` (TEXT)
- `ciudad_residencia` (VARCHAR(100))
- `pais_residencia` (VARCHAR(100))
- `contrasena` (VARCHAR(255), HASHED)
- `activo` (BOOLEAN)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### contactos
- `id` (INT, PK, AUTO_INCREMENT)
- `name` (VARCHAR(255))
- `email` (VARCHAR(255))
- `phone` (VARCHAR(20))
- `company` (VARCHAR(255))
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### refresh_tokens
- `id` (INT, PK, AUTO_INCREMENT)
- `user_id` (INT, FK)
- `token` (VARCHAR(500))
- `expires_at` (TIMESTAMP)
- `created_at` (TIMESTAMP)

## 🐛 Troubleshooting

### Error de conexión a MySQL
- Verifica que las credenciales en `.env` sean correctas
- Asegúrate de que la base de datos esté activa en Clever Cloud
- Revisa los logs de la aplicación

### Error de CORS
- Agrega tu dominio a `CORS_ORIGIN` en las variables de entorno
- Para desarrollo local, usa `http://localhost:3000`

### Token expirado
- Los tokens de acceso expiran en 1 hora
- Usa el endpoint `/api/auth/refresh` para obtener un nuevo token
- Los refresh tokens expiran en 7 días

## 📝 Logs

Los logs se muestran en la consola de Clever Cloud. Incluyen:
- Requests HTTP con timestamp e IP
- Errores de base de datos
- Errores de autenticación
- Información de inicio del servidor

## 🔄 Actualizaciones

Para actualizar la API:
1. Haz cambios en tu código
2. Commit y push a tu repositorio
3. Clever Cloud desplegará automáticamente
4. La base de datos se actualizará si es necesario

## 📞 Soporte

Para problemas o preguntas:
- Revisa los logs en Clever Cloud Console
- Verifica la configuración de variables de entorno
- Asegúrate de que la base de datos esté funcionando
- Contacta al equipo de desarrollo
