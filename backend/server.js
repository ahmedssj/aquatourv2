const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const { testConnection } = require('./config/database');
const { setupDatabase } = require('./setup-database');

// Importar rutas
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const contactRoutes = require('./routes/contacts');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware de seguridad
app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" }
}));

// Configurar CORS
const corsOptions = {
  origin: function (origin, callback) {
    // Permitir requests sin origin (como aplicaciones móviles)
    if (!origin) return callback(null, true);
    
    const allowedOrigins = process.env.CORS_ORIGIN 
      ? process.env.CORS_ORIGIN.split(',')
      : ['http://localhost:3000', 'http://localhost:8080'];
    
    if (allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error('No permitido por CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
};

app.use(cors(corsOptions));

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutos
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100, // límite de requests por ventana
  message: {
    error: 'Demasiadas solicitudes desde esta IP, intenta de nuevo más tarde.',
    code: 'RATE_LIMIT_EXCEEDED'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

app.use(limiter);

// Middleware para parsing JSON
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Middleware de logging
app.use((req, res, next) => {
  const timestamp = new Date().toISOString();
  console.log(`${timestamp} - ${req.method} ${req.path} - IP: ${req.ip}`);
  next();
});

// Rutas de salud y información
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    uptime: process.uptime()
  });
});

app.get('/api/info', (req, res) => {
  res.json({
    name: 'AquaTour CRM API',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    database: 'MySQL en Clever Cloud',
    features: [
      'Autenticación JWT',
      'Gestión de usuarios',
      'Gestión de contactos',
      'Rate limiting',
      'CORS configurado'
    ]
  });
});

// Rutas de la API
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/contacts', contactRoutes);

// Ruta raíz
app.get('/', (req, res) => {
  res.json({
    message: '🌊 Bienvenido a AquaTour CRM API',
    version: '1.0.0',
    documentation: '/api/info',
    health: '/api/health',
    endpoints: {
      auth: '/api/auth',
      users: '/api/users',
      contacts: '/api/contacts'
    }
  });
});

// Middleware para rutas no encontradas
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Endpoint no encontrado',
    path: req.originalUrl,
    method: req.method,
    available_endpoints: [
      'GET /',
      'GET /api/health',
      'GET /api/info',
      'POST /api/auth/login',
      'POST /api/auth/refresh',
      'POST /api/auth/logout',
      'GET /api/auth/verify',
      'GET /api/users',
      'GET /api/users/:id',
      'POST /api/users',
      'PUT /api/users/:id',
      'DELETE /api/users/:id',
      'GET /api/contacts',
      'GET /api/contacts/:id',
      'POST /api/contacts',
      'PUT /api/contacts/:id',
      'DELETE /api/contacts/:id'
    ]
  });
});

// Middleware global de manejo de errores
app.use((error, req, res, next) => {
  console.error('Error no manejado:', error);
  
  // Error de CORS
  if (error.message === 'No permitido por CORS') {
    return res.status(403).json({
      error: 'CORS: Origen no permitido',
      code: 'CORS_ERROR'
    });
  }
  
  // Error de JSON malformado
  if (error instanceof SyntaxError && error.status === 400 && 'body' in error) {
    return res.status(400).json({
      error: 'JSON malformado en el cuerpo de la solicitud',
      code: 'INVALID_JSON'
    });
  }
  
  res.status(500).json({
    error: 'Error interno del servidor',
    code: 'INTERNAL_SERVER_ERROR',
    ...(process.env.NODE_ENV === 'development' && { details: error.message })
  });
});

// Función para inicializar el servidor
async function startServer() {
  try {
    console.log('🚀 Iniciando AquaTour CRM API...');
    
    // Probar conexión a la base de datos
    console.log('📊 Probando conexión a la base de datos...');
    const isConnected = await testConnection();
    
    if (!isConnected) {
      throw new Error('No se pudo conectar a la base de datos');
    }
    
    // Configurar base de datos
    console.log('⚙️ Configurando base de datos...');
    await setupDatabase();
    
    // Iniciar servidor
    app.listen(PORT, () => {
      console.log('');
      console.log('✅ ¡Servidor iniciado exitosamente!');
      console.log(`🌐 URL: http://localhost:${PORT}`);
      console.log(`📊 Base de datos: MySQL en Clever Cloud`);
      console.log(`🔒 Entorno: ${process.env.NODE_ENV || 'development'}`);
      console.log('');
      console.log('📋 Endpoints disponibles:');
      console.log('  - GET  /                    (Información general)');
      console.log('  - GET  /api/health          (Estado del servidor)');
      console.log('  - GET  /api/info            (Información de la API)');
      console.log('  - POST /api/auth/login      (Iniciar sesión)');
      console.log('  - POST /api/auth/refresh    (Refrescar token)');
      console.log('  - POST /api/auth/logout     (Cerrar sesión)');
      console.log('  - GET  /api/auth/verify     (Verificar token)');
      console.log('  - GET  /api/users           (Listar usuarios)');
      console.log('  - GET  /api/contacts        (Listar contactos)');
      console.log('');
      console.log('👥 Usuarios de prueba:');
      console.log('  - Super Admin: superadmin@aquatour.com / superadmin123');
      console.log('  - Admin: davidg@aquatour.com / Osquitar07');
      console.log('  - Empleado: empleado@aquatour.com / empleado123');
      console.log('');
    });
    
  } catch (error) {
    console.error('❌ Error iniciando servidor:', error);
    process.exit(1);
  }
}

// Manejo de señales de terminación
process.on('SIGTERM', () => {
  console.log('📴 Recibida señal SIGTERM, cerrando servidor...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('📴 Recibida señal SIGINT, cerrando servidor...');
  process.exit(0);
});

// Manejo de errores no capturados
process.on('uncaughtException', (error) => {
  console.error('❌ Error no capturado:', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Promesa rechazada no manejada:', reason);
  process.exit(1);
});

// Iniciar servidor
startServer();
