# 🚀 Inicio Rápido - AquaTour CRM

## ✅ ¡Tu base de datos ya está configurada!

Tu aplicación AquaTour CRM ahora está completamente integrada con tu base de datos MySQL real en Clever Cloud.

### 📊 **Base de Datos Configurada:**
- **Host:** `b8efu6n5kvpd18l7euw3-mysql.services.clever-cloud.com`
- **Base de datos:** `b8efu6n5kvpd18l7euw3`
- **Tablas creadas:** ✅ Rol, Usuario, Cliente, Empleado, Proveedores, Destino, Paquete_Turismo, Reserva, Pago, Cotizaciones

## 🎯 **Pasos para Probar Ahora:**

### 1. Probar el Backend Localmente

```bash
# Ir a la carpeta backend
cd backend

# Instalar dependencias
npm install

# Copiar configuración
copy .env.example .env

# Probar conexión a tu base de datos
npm run test-db

# Configurar datos de ejemplo
npm run setup

# Iniciar servidor
npm run dev
```

### 2. Probar la App Flutter

```bash
# En otra terminal, ir a la raíz del proyecto
cd ..

# Ejecutar la app Flutter
flutter run -d chrome
```

## 👥 **Usuarios de Prueba:**

- **Super Admin:** `superadmin@aquatour.com` / `superadmin123`
- **Admin:** `davidg@aquatour.com` / `Osquitar07`  
- **Asesor:** `asesor@aquatour.com` / `asesor123`

## 🔍 **Qué Esperar:**

### ✅ **Backend API (http://localhost:3000):**
- Conexión exitosa a MySQL en Clever Cloud
- Usuarios de ejemplo creados automáticamente
- Endpoints de autenticación funcionando
- Datos reales almacenados en la nube

### ✅ **App Flutter:**
- Indicador verde: "Conectado a base de datos"
- Login funcional con usuarios reales
- Datos sincronizados con la base de datos
- Fallback automático a modo local si hay problemas

## 🧪 **Endpoints para Probar:**

```bash
# Verificar API
GET http://localhost:3000/api/health

# Login
POST http://localhost:3000/api/auth/login
{
  "email": "superadmin@aquatour.com",
  "password": "superadmin123"
}

# Obtener usuarios (requiere token)
GET http://localhost:3000/api/users
Authorization: Bearer tu-jwt-token
```

## 🚀 **Para Desplegar en Producción:**

1. **Sube tu código a GitHub/GitLab**
2. **Crea app Node.js en Clever Cloud**
3. **Configura las variables de entorno**
4. **Despliega automáticamente**
5. **Actualiza la URL en Flutter**

Ver `DEPLOYMENT_GUIDE.md` para instrucciones detalladas.

## 🔧 **Estructura Implementada:**

```
backend/
├── config/database.js          # Conexión MySQL
├── routes/auth.js              # Autenticación JWT
├── routes/users.js             # Gestión usuarios
├── routes/contacts.js          # Gestión contactos
├── middleware/auth.js          # Middleware seguridad
├── setup-database.js           # Configuración automática
├── test-connection.js          # Pruebas de conexión
└── server.js                   # Servidor principal

lib/
├── services/auth_service.dart      # Autenticación Flutter
├── services/database_service.dart  # Conexión API
├── services/local_storage_service.dart # Fallback local
├── models/user.dart                # Modelo usuario actualizado
└── login_screen.dart               # UI actualizada
```

## 🎉 **¡Listo para Usar!**

Tu aplicación AquaTour CRM ahora tiene:

- ✅ **Base de datos real** en la nube
- ✅ **API REST completa** con seguridad JWT
- ✅ **App Flutter** con conexión real
- ✅ **Fallback automático** para alta disponibilidad
- ✅ **Gestión de roles** (Superadmin, Admin, Asesor, Cliente)
- ✅ **Datos de ejemplo** listos para usar

### 📞 **¿Problemas?**

1. **Backend no conecta:** Verifica credenciales en `.env`
2. **Flutter no conecta:** Verifica URL en `.env.local`
3. **Login falla:** Usa usuarios de ejemplo listados arriba
4. **API no responde:** Ejecuta `npm run test-db` para diagnosticar

¡Tu CRM está listo para gestionar clientes, reservas y todo tu negocio turístico! 🌊
