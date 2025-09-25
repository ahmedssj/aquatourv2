# 🚀 Pasos Finales para Deploy - AquaTour CRM

## ✅ Lo que ya tienes funcionando:
- ✅ **Backend desplegado** en Vercel: `https://aquatour-crm-api-123.vercel.app`
- ✅ **Base de datos MySQL** funcionando en Clever Cloud
- ✅ **Autenticación JWT** con restricción de roles
- ✅ **Solo roles administrativos** pueden hacer login

## 🎯 Pasos para completar el deploy:

### 1. 📤 Subir a GitHub

```bash
# Si no tienes repositorio, créalo en GitHub primero
# Luego ejecuta:

git remote add origin https://github.com/tu-usuario/aquatour-crm.git
git branch -M main
git push -u origin main
```

### 2. 🚀 Deploy Frontend en Vercel

1. **Ve a [Vercel Dashboard](https://vercel.com/dashboard)**
2. **Click "New Project"**
3. **Import tu repositorio de GitHub**
4. **Configuración:**
   - **Framework Preset:** Other
   - **Build Command:** `flutter build web --release`
   - **Output Directory:** `build/web`
   - **Install Command:** `flutter pub get`
   - **Root Directory:** `./` (raíz)

5. **Variables de entorno:**
   ```
   API_BASE_URL=https://aquatour-crm-api-123.vercel.app/api
   APP_ENV=production
   DEBUG=false
   ALLOWED_ROLES=superadministrador,administrador,asesor
   ```

6. **Click "Deploy"**

### 3. 🧪 Probar el Sistema Completo

Una vez desplegado, tendrás:

- **Frontend:** `https://aquatour-crm.vercel.app`
- **Backend:** `https://aquatour-crm-api-123.vercel.app`

**Usuarios de prueba:**
- **Super Admin:** `superadmin@aquatour.com` / `superadmin123`
- **Admin:** `davidg@aquatour.com` / `Osquitar07`
- **Asesor:** `asesor@aquatour.com` / `asesor123`

❌ **Los clientes están BLOQUEADOS** (como solicitaste)

### 4. ✅ Verificaciones Finales

#### Frontend:
- [ ] Página de login carga correctamente
- [ ] Muestra "Conectado a base de datos" en verde
- [ ] Login funciona con usuarios administrativos
- [ ] Clientes son rechazados con mensaje de error
- [ ] Dashboard se carga después del login
- [ ] Gestión de usuarios funciona

#### Backend:
```bash
# Verificar salud de la API
curl https://aquatour-crm-api-123.vercel.app/api/health

# Probar login
curl -X POST https://aquatour-crm-api-123.vercel.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"superadmin@aquatour.com","password":"superadmin123"}'

# Verificar usuarios
curl -X GET https://aquatour-crm-api-123.vercel.app/api/users \
  -H "Authorization: Bearer tu-jwt-token"
```

## 🎉 ¡Sistema Completo Funcionando!

Una vez completados estos pasos tendrás:

### ✅ **Sistema CRM Completo:**
- 🌐 **Frontend Flutter Web** desplegado en Vercel
- 🔧 **Backend Node.js API** desplegado en Vercel
- 📊 **Base de datos MySQL** en Clever Cloud
- 🔐 **Autenticación segura** con JWT
- 🛡️ **Restricción de acceso** solo a roles administrativos

### 🔒 **Seguridad Implementada:**
- Solo **Superadministrador**, **Administrador** y **Asesor** pueden hacer login
- **Clientes bloqueados** automáticamente
- **Tokens JWT** con expiración y refresh
- **Contraseñas hasheadas** con bcrypt
- **Rate limiting** y CORS configurado

### 🌐 **URLs del Sistema:**
- **Frontend:** https://aquatour-crm.vercel.app
- **Backend API:** https://aquatour-crm-api-123.vercel.app
- **Base de datos:** MySQL en Clever Cloud (privada)

### 📱 **Funcionalidades:**
- ✅ Login con validación de roles
- ✅ Dashboard administrativo
- ✅ Gestión de usuarios
- ✅ Conexión real a base de datos
- ✅ Modo offline como fallback
- ✅ Interfaz moderna y responsive

---

**¡Tu AquaTour CRM estará completamente funcional en producción!** 🌊

## 📞 Soporte Post-Deploy

Si encuentras algún problema:

1. **Revisa los logs** en Vercel Dashboard
2. **Verifica las variables de entorno**
3. **Prueba los endpoints** de la API
4. **Verifica la conexión** a la base de datos

**¡Todo está listo para funcionar perfectamente!** 🎯
