const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const { executeQuery } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Función para generar tokens
const generateTokens = (userId, email) => {
  const accessToken = jwt.sign(
    { userId, email },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '1h' }
  );

  const refreshToken = jwt.sign(
    { userId },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d' }
  );

  return { accessToken, refreshToken };
};

// Función para guardar refresh token
const saveRefreshToken = async (userId, refreshToken) => {
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 7); // 7 días

  await executeQuery(
    'INSERT INTO refresh_tokens (user_id, token, expires_at) VALUES (?, ?, ?)',
    [userId, refreshToken, expiresAt]
  );
};

// Función para limpiar tokens expirados
const cleanExpiredTokens = async () => {
  await executeQuery(
    'DELETE FROM refresh_tokens WHERE expires_at < NOW()'
  );
};

// POST /api/auth/login
router.post('/login', [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Email válido es requerido'),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Contraseña debe tener al menos 6 caracteres')
], async (req, res) => {
  try {
    // Validar entrada
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Datos de entrada inválidos',
        details: errors.array()
      });
    }

    const { email, password } = req.body;

    // Buscar usuario con información de rol
    const users = await executeQuery(`
      SELECT u.*, r.rol as rol_nombre 
      FROM Usuario u 
      INNER JOIN Rol r ON u.id_rol = r.id_rol 
      WHERE u.correo = ?
    `, [email]);

    if (users.length === 0) {
      return res.status(401).json({
        error: 'Credenciales incorrectas'
      });
    }

    const user = users[0];

    // Verificar contraseña
    const isValidPassword = await bcrypt.compare(password, user.contrasena);
    if (!isValidPassword) {
      return res.status(401).json({
        error: 'Credenciales incorrectas'
      });
    }

    // Verificar que el rol esté permitido para login
    const allowedRoles = (process.env.ALLOWED_LOGIN_ROLES || 'superadministrador,administrador,asesor').split(',');
    const userRole = user.rol_nombre.toLowerCase();
    
    if (!allowedRoles.includes(userRole)) {
      return res.status(403).json({
        error: 'Acceso denegado. Solo personal administrativo puede acceder al sistema.',
        code: 'ROLE_NOT_AUTHORIZED',
        allowed_roles: allowedRoles,
        user_role: userRole
      });
    }

    // Limpiar tokens expirados
    await cleanExpiredTokens();

    // Generar tokens
    const { accessToken, refreshToken } = generateTokens(user.id_usuario, user.correo);

    // Guardar refresh token
    await saveRefreshToken(user.id_usuario, refreshToken);

    // Formatear usuario para compatibilidad con Flutter
    const userFormatted = {
      id_usuario: user.id_usuario,
      nombre: user.nombre,
      apellido: user.apellido,
      email: user.correo, // Mapear correo a email para compatibilidad
      rol: user.rol_nombre.toLowerCase(), // Convertir a minúsculas para compatibilidad
      tipo_documento: user.tipo_documento,
      num_documento: user.num_documento,
      fecha_nacimiento: user.fecha_nacimiento,
      lugar_nacimiento: user.lugar_nacimiento,
      genero: user.genero,
      telefono: user.telefono?.toString(),
      direccion: user.direccion,
      ciudad_residencia: user.ciudad_residencia,
      pais_residencia: user.pais_residencia,
      activo: true, // Asumimos que está activo si puede hacer login
      created_at: user.fecha_registro,
      updated_at: user.fecha_registro
    };

    res.json({
      access_token: accessToken,
      refresh_token: refreshToken,
      user: userFormatted
    });

  } catch (error) {
    console.error('Error en login:', error);
    res.status(500).json({
      error: 'Error interno del servidor'
    });
  }
});

// POST /api/auth/refresh
router.post('/refresh', [
  body('refresh_token')
    .notEmpty()
    .withMessage('Refresh token es requerido')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Refresh token es requerido',
        details: errors.array()
      });
    }

    const { refresh_token } = req.body;

    // Verificar refresh token
    const decoded = jwt.verify(refresh_token, process.env.JWT_REFRESH_SECRET);

    // Verificar que el token existe en la base de datos y no ha expirado
    const tokens = await executeQuery(
      'SELECT * FROM refresh_tokens WHERE token = ? AND user_id = ? AND expires_at > NOW()',
      [refresh_token, decoded.userId]
    );

    if (tokens.length === 0) {
      return res.status(401).json({
        error: 'Refresh token inválido o expirado'
      });
    }

    // Buscar usuario
    const users = await executeQuery(
      'SELECT * FROM usuarios WHERE id_usuario = ? AND activo = true',
      [decoded.userId]
    );

    if (users.length === 0) {
      return res.status(401).json({
        error: 'Usuario no encontrado'
      });
    }

    const user = users[0];

    // Generar nuevos tokens
    const { accessToken, refreshToken: newRefreshToken } = generateTokens(user.id_usuario, user.email);

    // Eliminar el refresh token anterior
    await executeQuery(
      'DELETE FROM refresh_tokens WHERE token = ?',
      [refresh_token]
    );

    // Guardar nuevo refresh token
    await saveRefreshToken(user.id_usuario, newRefreshToken);

    // Remover contraseña de la respuesta
    const { contrasena, ...userWithoutPassword } = user;

    res.json({
      access_token: accessToken,
      refresh_token: newRefreshToken,
      user: userWithoutPassword
    });

  } catch (error) {
    if (error.name === 'TokenExpiredError' || error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        error: 'Refresh token inválido'
      });
    }

    console.error('Error en refresh:', error);
    res.status(500).json({
      error: 'Error interno del servidor'
    });
  }
});

// POST /api/auth/logout
router.post('/logout', authenticateToken, async (req, res) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    // Eliminar todos los refresh tokens del usuario
    await executeQuery(
      'DELETE FROM refresh_tokens WHERE user_id = ?',
      [req.user.id_usuario]
    );

    res.json({
      message: 'Sesión cerrada exitosamente'
    });

  } catch (error) {
    console.error('Error en logout:', error);
    res.status(500).json({
      error: 'Error interno del servidor'
    });
  }
});

// GET /api/auth/verify
router.get('/verify', authenticateToken, async (req, res) => {
  try {
    // Remover contraseña de la respuesta
    const { contrasena, ...userWithoutPassword } = req.user;

    res.json({
      user: userWithoutPassword
    });

  } catch (error) {
    console.error('Error en verify:', error);
    res.status(500).json({
      error: 'Error interno del servidor'
    });
  }
});

module.exports = router;
