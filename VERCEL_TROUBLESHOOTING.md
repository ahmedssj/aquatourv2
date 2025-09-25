# 🔧 Solución de Errores de Vercel - Flutter

## ❌ Errores Comunes y Soluciones

### Error 1: "Build Command Failed"
**Solución:**
- Framework Preset: **Other** (NO Flutter)
- Build Command: `chmod +x build.sh && ./build.sh`
- Output Directory: `build/web`
- Install Command: `echo "No install needed"`

### Error 2: "Flutter not found"
**Solución:**
- Usar el archivo `build.sh` que ya está configurado
- Build Command: `bash build.sh`

### Error 3: "CORS Error" o "API not accessible"
**Solución:**
Variables de entorno en Vercel:
```
API_BASE_URL=https://aquatour-crm-api-123.vercel.app/api
APP_ENV=production
DEBUG=false
ALLOWED_ROLES=superadministrador,administrador,asesor
```

### Error 4: "Routes not working"
**Solución:**
Usar el archivo `vercel.json` correcto (ya está configurado)

## 🚀 Configuración Correcta para Vercel

### Paso 1: Configuración del Proyecto
1. **Framework Preset:** Other
2. **Root Directory:** `./` (dejar vacío)
3. **Build Command:** `bash build.sh`
4. **Output Directory:** `build/web`
5. **Install Command:** `echo "Dependencies handled by build script"`

### Paso 2: Variables de Entorno
```
API_BASE_URL=https://aquatour-crm-api-123.vercel.app/api
APP_ENV=production
DEBUG=false
ALLOWED_ROLES=superadministrador,administrador,asesor
TOKEN_STORAGE_KEY=aquatour_auth_token
ENABLE_LOCAL_STORAGE=true
```

### Paso 3: Configuración Avanzada (si es necesario)
Si sigues teniendo problemas, usa esta configuración:

**Build Command:**
```bash
curl -sL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz | tar xJ && export PATH="$PATH:`pwd`/flutter/bin" && flutter config --enable-web && flutter pub get && flutter build web --release
```

**Output Directory:** `build/web`

## 🧪 Verificar Deploy

Una vez desplegado, verifica:

1. **Frontend carga:** https://tu-proyecto.vercel.app
2. **Assets cargan:** https://tu-proyecto.vercel.app/assets/
3. **API conecta:** Debería mostrar "Conectado a base de datos" en verde

## 🔄 Si el Deploy Falla

### Opción 1: Deploy Manual
```bash
# En tu máquina local
flutter build web --release

# Sube solo la carpeta build/web a Vercel como sitio estático
```

### Opción 2: Configuración Alternativa
```json
{
  "version": 2,
  "builds": [
    {
      "src": "build/web/**",
      "use": "@vercel/static"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/index.html"
    }
  ]
}
```

### Opción 3: Deploy desde Build Local
1. Hacer build local: `flutter build web --release`
2. Subir solo `build/web/*` a un nuevo proyecto Vercel
3. Framework: Static
4. No build command needed

## 📋 Checklist de Deploy

- [ ] Repositorio en GitHub actualizado
- [ ] build.sh tiene permisos de ejecución
- [ ] vercel.json está en la raíz
- [ ] Variables de entorno configuradas
- [ ] Framework preset: "Other"
- [ ] Build command: `bash build.sh`
- [ ] Output directory: `build/web`

## 🆘 Si Nada Funciona

**Deploy de Emergencia:**
1. Ejecuta localmente: `flutter build web --release`
2. Sube manualmente `build/web` a Netlify o GitHub Pages
3. Configura las variables de entorno allí

**URLs de respaldo:**
- Netlify: https://app.netlify.com/drop
- GitHub Pages: En settings del repositorio

---

**¿Qué error específico estás viendo en Vercel?** 
Comparte el mensaje de error para darte una solución exacta.
