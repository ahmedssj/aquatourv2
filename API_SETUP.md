# Configuración de API Backend para AquaTour CRM

Este documento explica cómo configurar un backend API para que funcione con el sistema de autenticación de AquaTour CRM.

## Estructura de la API

La aplicación espera los siguientes endpoints:

### Autenticación

#### POST `/api/auth/login`
Iniciar sesión con email y contraseña.

**Request:**
```json
{
  "email": "usuario@aquatour.com",
  "password": "contraseña123"
}
```

**Response (200):**
```json
{
  "access_token": "jwt_token_here",
  "refresh_token": "refresh_token_here",
  "user": {
    "id_usuario": 1,
    "nombre": "Juan",
    "apellido": "Pérez",
    "email": "usuario@aquatour.com",
    "rol": "administrador",
    "tipo_documento": "CC",
    "num_documento": "12345678",
    "fecha_nacimiento": "1990-01-01T00:00:00.000Z",
    "genero": "Masculino",
    "telefono": "+57 300 123 4567",
    "direccion": "Calle 123 #45-67",
    "ciudad_residencia": "Bogotá",
    "pais_residencia": "Colombia",
    "activo": true,
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z"
  }
}
```

#### POST `/api/auth/logout`
Cerrar sesión (requiere token).

**Headers:**
```
Authorization: Bearer jwt_token_here
```

#### GET `/api/auth/verify`
Verificar token de autenticación.

**Headers:**
```
Authorization: Bearer jwt_token_here
```

**Response (200):**
```json
{
  "user": {
    // Datos del usuario
  }
}
```

#### POST `/api/auth/refresh`
Refrescar token de acceso.

**Request:**
```json
{
  "refresh_token": "refresh_token_here"
}
```

### Usuarios

#### GET `/api/users`
Obtener todos los usuarios (requiere permisos de administrador).

#### GET `/api/users/:id`
Obtener usuario por ID.

#### POST `/api/users`
Crear nuevo usuario.

#### PUT `/api/users/:id`
Actualizar usuario.

#### DELETE `/api/users/:id`
Eliminar usuario.

### Contactos

#### GET `/api/contacts`
Obtener todos los contactos.

#### POST `/api/contacts`
Crear nuevo contacto.

#### PUT `/api/contacts/:id`
Actualizar contacto.

#### DELETE `/api/contacts/:id`
Eliminar contacto.

### Salud de la API

#### GET `/api/health`
Verificar que la API esté funcionando.

**Response (200):**
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

#### GET `/api/info`
Obtener información de la API.

**Response (200):**
```json
{
  "name": "AquaTour CRM API",
  "version": "1.0.0",
  "environment": "production"
}
```

## Configuración de Base de Datos

### Tabla `usuarios`
```sql
CREATE TABLE usuarios (
    id_usuario SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    rol VARCHAR(50) NOT NULL DEFAULT 'empleado',
    tipo_documento VARCHAR(10) NOT NULL,
    num_documento VARCHAR(50) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero VARCHAR(20) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    direccion TEXT NOT NULL,
    ciudad_residencia VARCHAR(100) NOT NULL,
    pais_residencia VARCHAR(100) NOT NULL,
    contrasena VARCHAR(255) NOT NULL, -- Hash de la contraseña
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Tabla `contactos`
```sql
CREATE TABLE contactos (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    company VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Ejemplo de Implementación con Node.js/Express

### Dependencias necesarias
```json
{
  "express": "^4.18.0",
  "bcryptjs": "^2.4.3",
  "jsonwebtoken": "^9.0.0",
  "pg": "^8.8.0",
  "cors": "^2.8.5",
  "dotenv": "^16.0.0"
}
```

### Ejemplo de endpoint de login
```javascript
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    // Buscar usuario en la base de datos
    const user = await db.query(
      'SELECT * FROM usuarios WHERE email = $1 AND activo = true',
      [email.toLowerCase()]
    );
    
    if (user.rows.length === 0) {
      return res.status(401).json({ error: 'Credenciales incorrectas' });
    }
    
    const userData = user.rows[0];
    
    // Verificar contraseña
    const isValidPassword = await bcrypt.compare(password, userData.contrasena);
    
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Credenciales incorrectas' });
    }
    
    // Generar tokens
    const accessToken = jwt.sign(
      { userId: userData.id_usuario, email: userData.email },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );
    
    const refreshToken = jwt.sign(
      { userId: userData.id_usuario },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: '7d' }
    );
    
    // Remover contraseña de la respuesta
    delete userData.contrasena;
    
    res.json({
      access_token: accessToken,
      refresh_token: refreshToken,
      user: userData
    });
    
  } catch (error) {
    console.error('Error en login:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});
```

## Variables de Entorno

Crea un archivo `.env` en tu proyecto Flutter con:

```env
# URL de tu API REST
API_BASE_URL=https://tu-api-url.com/api

# Configuración de la aplicación
APP_ENV=production
DEBUG=false

# Timeout para requests HTTP (en segundos)
HTTP_TIMEOUT=30
```

## Modo Fallback

Si la API no está disponible, la aplicación automáticamente usará el almacenamiento local con los usuarios de ejemplo:

- **Super Admin:** `superadmin@aquatour.com` / `superadmin123`
- **Admin:** `davidg@aquatour.com` / `Osquitar07`
- **Empleado:** `empleado@aquatour.com` / `empleado123`

## Seguridad

1. **Contraseñas:** Siempre usa hash (bcrypt) para almacenar contraseñas
2. **JWT:** Usa secretos seguros y tokens con expiración
3. **HTTPS:** Siempre usa HTTPS en producción
4. **CORS:** Configura CORS apropiadamente
5. **Validación:** Valida todos los inputs del usuario
6. **Rate Limiting:** Implementa límites de velocidad para prevenir ataques

## Testing

Puedes probar los endpoints usando herramientas como:
- Postman
- Insomnia
- curl
- Thunder Client (VS Code)

Ejemplo con curl:
```bash
curl -X POST https://tu-api-url.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"usuario@aquatour.com","password":"contraseña123"}'
```
