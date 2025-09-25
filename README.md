# 🌊 AquaTour CRM

Sistema de gestión CRM completo para empresas de turismo, desarrollado con Flutter Web y Node.js API.

## ✨ Características Principales

- 🔐 **Autenticación segura** con JWT y roles administrativos
- 👥 **Gestión completa de usuarios** con base de datos MySQL
- 🏢 **Sistema de roles** restringido a personal administrativo
- 🌐 **API REST completa** con Node.js y Express
- 📊 **Base de datos real** en Clever Cloud MySQL
- 🚀 **Deploy automático** en Vercel
- 📱 **Interfaz moderna** y responsive
- 🔄 **Modo offline** con fallback local

## 🔒 Seguridad Implementada

### Restricción de Acceso
**Solo personal administrativo puede hacer login:**
- ✅ **Superadministrador** - Acceso completo
- ✅ **Administrador** - Gestión de usuarios y configuración  
- ✅ **Asesor** - Gestión de clientes y reservas
- ❌ **Cliente** - **ACCESO BLOQUEADO**

### Características de Seguridad
- 🔐 Autenticación JWT con refresh tokens
- 🛡️ Contraseñas hasheadas con bcrypt
- 🚫 Rate limiting y CORS configurado
- 🔒 Validación de roles en backend y frontend

## 🚀 Inicio Rápido

### Opción 1: Configuración Automática
```bash
# Verificar que todo esté listo
.\verify-deploy-ready.bat

# Configurar y ejecutar todo automáticamente
.\setup.bat
```

### Opción 2: Configuración Manual

#### 1. Requisitos Previos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versión 3.16.0+)
- [Node.js](https://nodejs.org/) (versión 18+)
- Un navegador web moderno

#### 2. Clona el repositorio
```bash
git clone https://github.com/tu-usuario/aquatour-crm.git
cd aquatour-crm
```

#### 3. Configura el Frontend
```bash
# Crear archivo .env
copy .env.example .env

# Instalar dependencias
flutter pub get

# Ejecutar en desarrollo
flutter run -d chrome
```

#### 4. Configura el Backend
```bash
cd backend

# Crear archivo .env
copy .env.example .env

# Instalar dependencias
npm install

# Configurar base de datos
npm run setup

# Ejecutar servidor
npm run dev
```

## 👥 Usuarios de Prueba

Una vez configurado, puedes usar estos usuarios:

- **Super Admin:** `superadmin@aquatour.com` / `superadmin123`
- **Admin:** `davidg@aquatour.com` / `Osquitar07`
- **Asesor:** `asesor@aquatour.com` / `asesor123`

❌ **Los clientes NO pueden hacer login** (por diseño de seguridad)

## 🏗️ Arquitectura del Sistema

```
📁 AquaTour CRM/
├── 📱 Frontend (Flutter Web)
│   ├── lib/
│   │   ├── main.dart                    # Punto de entrada
│   │   ├── screens/
│   │   │   ├── login_screen.dart        # Pantalla de login
│   │   │   ├── dashboard_screen.dart    # Dashboard principal
│   │   │   └── user_management_screen.dart # Gestión de usuarios
│   │   ├── services/
│   │   │   ├── auth_service.dart        # Autenticación
│   │   │   ├── database_service.dart    # Conexión API
│   │   │   └── local_storage_service.dart # Fallback local
│   │   └── models/
│   │       └── user.dart                # Modelo de usuario
│   └── vercel.json                      # Configuración Vercel
│
├── 🔧 Backend (Node.js API)
│   ├── server.js                        # Servidor principal
│   ├── config/database.js               # Conexión MySQL
│   ├── routes/
│   │   ├── auth.js                      # Autenticación JWT
│   │   ├── users.js                     # Gestión usuarios
│   │   └── contacts.js                  # Gestión contactos
│   ├── middleware/auth.js               # Middleware seguridad
│   └── vercel.json                      # Configuración Vercel
│
└── 📊 Base de Datos (MySQL en Clever Cloud)
    ├── Rol                              # Tabla de roles
    ├── Usuario                          # Tabla de usuarios
    ├── Cliente                          # Tabla de clientes
    ├── Empleado                         # Tabla de empleados
    └── [Otras tablas del CRM]
```

## 🚀 Deploy en Vercel

### Preparar para Deploy
```bash
# Verificar que todo esté listo
.\verify-deploy-ready.bat

# Construir para producción
.\build-for-vercel.bat
```

### Subir a GitHub
```bash
git add .
git commit -m "🚀 Ready for Vercel deploy"
git push origin main
```

### Configurar en Vercel
1. **Frontend:** Conectar repositorio → Framework: Other → Build: `flutter build web`
2. **Backend:** Nuevo proyecto → Root: `./backend` → Framework: Node.js
3. **Variables de entorno:** Configurar según `DEPLOY_TO_VERCEL.md`

Ver guía completa: [`DEPLOY_TO_VERCEL.md`](./DEPLOY_TO_VERCEL.md)

## 📋 Funcionalidades Implementadas

### ✅ Sistema de Autenticación Completo
- 🔐 Login con JWT y refresh tokens
- 🛡️ Restricción a roles administrativos únicamente
- 🔄 Fallback automático a modo local
- 💾 Persistencia de sesión segura

### ✅ Base de Datos Real
- 📊 MySQL en Clever Cloud (configurado)
- 🔗 API REST completa con Node.js
- 🔒 Conexiones seguras con SSL
- 📈 Escalabilidad en la nube

### ✅ Gestión de Usuarios
- 👥 CRUD completo de usuarios
- 🏢 Sistema de roles y permisos
- 📝 Validación de datos
- 🔍 Búsqueda y filtros

### ✅ Interfaz Moderna
- 📱 Responsive design
- 🎨 Colores corporativos
- ⚡ Animaciones fluidas
- 🌐 Optimizado para web

### 🚧 Próximos Módulos
- 📋 Cotizaciones de viajes
- 🎫 Gestión de reservas
- 📞 Directorio de contactos
- 🏢 Gestión de proveedores
- 💰 Historial de pagos

## 🔧 Scripts Disponibles

```bash
# Desarrollo
.\setup.bat                    # Configuración automática completa
.\verify-deploy-ready.bat      # Verificar que todo esté listo

# Producción
.\build-for-vercel.bat         # Construir para deploy en Vercel

# Backend
cd backend
npm run dev                    # Servidor desarrollo
npm run setup                  # Configurar base de datos
npm run test-db               # Probar conexión MySQL
```

## 🌐 URLs del Sistema

### Desarrollo
- **Frontend:** http://localhost:3000
- **Backend:** http://localhost:3000/api

### Producción (Vercel)
- **Frontend:** https://aquatour-crm.vercel.app
- **Backend:** https://aquatour-crm-api.vercel.app

## 📞 Soporte

Para soporte técnico o preguntas:
- 📧 Email: support@aquatour.com
- 📋 Issues: GitHub Issues
- 📖 Documentación: Ver archivos `.md` del proyecto

---

**🌊 AquaTour CRM v1.0.0**  
*Sistema CRM completo para empresas de turismo*  
**Última actualización:** Septiembre 2024
