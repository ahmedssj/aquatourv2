const jwt = require('jsonwebtoken');
const { executeQuery } = require('../config/database');

// Middleware para verificar JWT token
const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({ 
        error: 'Token de acceso requerido',
        code: 'NO_TOKEN'
      });
    }

    // Verificar token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Buscar usuario en la base de datos con información de rol
    const users = await executeQuery(`
      SELECT u.*, r.rol as rol_nombre 
      FROM Usuario u 
      INNER JOIN Rol r ON u.id_rol = r.id_rol 
      WHERE u.id_usuario = ?
    `, [decoded.userId]);

    if (users.length === 0) {
      return res.status(401).json({ 
        error: 'Usuario no encontrado o inactivo',
        code: 'USER_NOT_FOUND'
      });
    }

    // Formatear usuario para compatibilidad
    const user = users[0];
    const userFormatted = {
      ...user,
      email: user.correo,
      rol: user.rol_nombre.toLowerCase(),
      telefono: user.telefono?.toString(),
      activo: true
    };

    // Agregar usuario a la request
    req.user = userFormatted;
    next();
    
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ 
        error: 'Token expirado',
        code: 'TOKEN_EXPIRED'
      });
    } else if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ 
        error: 'Token inválido',
        code: 'INVALID_TOKEN'
      });
    }
    
    console.error('Error en autenticación:', error);
    res.status(500).json({ 
      error: 'Error interno del servidor',
      code: 'INTERNAL_ERROR'
    });
  }
};

// Middleware para verificar roles
const requireRole = (roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ 
        error: 'Usuario no autenticado',
        code: 'NOT_AUTHENTICATED'
      });
    }

    const userRole = req.user.rol;
    const allowedRoles = Array.isArray(roles) ? roles : [roles];

    if (!allowedRoles.includes(userRole)) {
      return res.status(403).json({ 
        error: 'No tienes permisos para realizar esta acción',
        code: 'INSUFFICIENT_PERMISSIONS',
        required_roles: allowedRoles,
        user_role: userRole
      });
    }

    next();
  };
};

// Middleware para verificar si es administrador
const requireAdmin = requireRole(['administrador', 'superadministrador']);

// Middleware para verificar si es super administrador
const requireSuperAdmin = requireRole(['superadministrador']);

// Middleware para verificar si es asesor o superior
const requireAsesor = requireRole(['asesor', 'administrador', 'superadministrador']);

module.exports = {
  authenticateToken,
  requireRole,
  requireAdmin,
  requireSuperAdmin,
  requireAsesor
};
