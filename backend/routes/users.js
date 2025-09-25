const express = require('express');
const bcrypt = require('bcryptjs');
const { body, validationResult } = require('express-validator');
const { executeQuery } = require('../config/database');
const { authenticateToken, requireAdmin, requireSuperAdmin } = require('../middleware/auth');

const router = express.Router();

// GET /api/users - Obtener todos los usuarios (solo admins)
router.get('/', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const users = await executeQuery(`
      SELECT 
        id_usuario, nombre, apellido, email, rol, tipo_documento, 
        num_documento, fecha_nacimiento, genero, telefono, direccion,
        ciudad_residencia, pais_residencia, activo, created_at, updated_at
      FROM usuarios 
      ORDER BY created_at DESC
    `);

    res.json({
      users: users
    });

  } catch (error) {
    console.error('Error obteniendo usuarios:', error);
    res.status(500).json({
      error: 'Error interno del servidor'
    });
  }
});

// GET /api/users/:id - Obtener usuario por ID
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = parseInt(id);

    // Solo admins pueden ver otros usuarios, empleados solo pueden verse a sí mismos
    if (req.user.rol === 'empleado' && req.user.id_usuario !== userId) {
      return res.status(403).json({
        error: 'No tienes permisos para ver este usuario'
      });
    }

    const users = await executeQuery(`
      SELECT 
        id_usuario, nombre, apellido, email, rol, tipo_documento, 
        num_documento, fecha_nacimiento, genero, telefono, direccion,
        ciudad_residencia, pais_residencia, activo, created_at, updated_at
      FROM usuarios 
      WHERE id_usuario = ?
    `, [userId]);

    if (users.length === 0) {
      return res.status(404).json({
        error: 'Usuario no encontrado'
      });
    }

    res.json({
      user: users[0]
    });

  } catch (error) {
    console.error('Error obteniendo usuario:', error);
    res.status(500).json({
      error: 'Error interno del servidor'
    });
  }
});

// POST /api/users - Crear nuevo usuario (solo admins)
router.post('/', authenticateToken, requireAdmin, [
  body('nombre').trim().isLength({ min: 2 }).withMessage('Nombre debe tener al menos 2 caracteres'),
  body('apellido').trim().isLength({ min: 2 }).withMessage('Apellido debe tener al menos 2 caracteres'),
  body('email').isEmail().normalizeEmail().withMessage('Email válido es requerido'),
  body('rol').isIn(['empleado', 'administrador', 'superadministrador']).withMessage('Rol inválido'),
  body('tipo_documento').trim().notEmpty().withMessage('Tipo de documento es requerido'),
  body('num_documento').trim().notEmpty().withMessage('Número de documento es requerido'),
  body('fecha_nacimiento').isISO8601().withMessage('Fecha de nacimiento válida es requerida'),
  body('genero').trim().notEmpty().withMessage('Género es requerido'),
  body('telefono').trim().notEmpty().withMessage('Teléfono es requerido'),
  body('direccion').trim().notEmpty().withMessage('Dirección es requerida'),
  body('ciudad_residencia').trim().notEmpty().withMessage('Ciudad de residencia es requerida'),
  body('pais_residencia').trim().notEmpty().withMessage('País de residencia es requerido'),
  body('contrasena').isLength({ min: 6 }).withMessage('Contraseña debe tener al menos 6 caracteres')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Datos de entrada inválidos',
        details: errors.array()
      });
    }

    const {
      nombre, apellido, email, rol, tipo_documento, num_documento,
      fecha_nacimiento, genero, telefono, direccion, ciudad_residencia,
      pais_residencia, contrasena
    } = req.body;

    // Solo super admins pueden crear otros super admins
    if (rol === 'superadministrador' && req.user.rol !== 'superadministrador') {
      return res.status(403).json({
        error: 'Solo super administradores pueden crear otros super administradores'
      });
    }

    // Verificar si el email ya existe
    const existingUsers = await executeQuery(
      'SELECT id_usuario FROM usuarios WHERE email = ?',
      [email]
    );

    if (existingUsers.length > 0) {
      return res.status(409).json({
        error: 'El email ya está registrado'
      });
    }

    // Hash de la contraseña
    const hashedPassword = await bcrypt.hash(contrasena, 12);

    // Insertar usuario
    const result = await executeQuery(`
      INSERT INTO usuarios (
        nombre, apellido, email, rol, tipo_documento, num_documento,
        fecha_nacimiento, genero, telefono, direccion, ciudad_residencia,
        pais_residencia, contrasena, activo
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, true)
    `, [
      nombre, apellido, email, rol, tipo_documento, num_documento,
      fecha_nacimiento, genero, telefono, direccion, ciudad_residencia,
      pais_residencia, hashedPassword
    ]);

    // Obtener el usuario creado
    const newUsers = await executeQuery(`
      SELECT 
        id_usuario, nombre, apellido, email, rol, tipo_documento, 
        num_documento, fecha_nacimiento, genero, telefono, direccion,
        ciudad_residencia, pais_residencia, activo, created_at, updated_at
      FROM usuarios 
      WHERE id_usuario = ?
    `, [result.insertId]);

    res.status(201).json({
      user: newUsers[0]
    });

  } catch (error) {
    console.error('Error creando usuario:', error);
    res.status(500).json({
      error: 'Error interno del servidor'
    });
  }
});

// PUT /api/users/:id - Actualizar usuario
router.put('/:id', authenticateToken, [
  body('nombre').optional().trim().isLength({ min: 2 }).withMessage('Nombre debe tener al menos 2 caracteres'),
  body('apellido').optional().trim().isLength({ min: 2 }).withMessage('Apellido debe tener al menos 2 caracteres'),
  body('email').optional().isEmail().normalizeEmail().withMessage('Email válido es requerido'),
  body('rol').optional().isIn(['empleado', 'administrador', 'superadministrador']).withMessage('Rol inválido'),
  body('tipo_documento').optional().trim().notEmpty().withMessage('Tipo de documento es requerido'),
  body('num_documento').optional().trim().notEmpty().withMessage('Número de documento es requerido'),
  body('fecha_nacimiento').optional().isISO8601().withMessage('Fecha de nacimiento válida es requerida'),
  body('genero').optional().trim().notEmpty().withMessage('Género es requerido'),
  body('telefono').optional().trim().notEmpty().withMessage('Teléfono es requerido'),
  body('direccion').optional().trim().notEmpty().withMessage('Dirección es requerida'),
  body('ciudad_residencia').optional().trim().notEmpty().withMessage('Ciudad de residencia es requerida'),
  body('pais_residencia').optional().trim().notEmpty().withMessage('País de residencia es requerido'),
  body('contrasena').optional().isLength({ min: 6 }).withMessage('Contraseña debe tener al menos 6 caracteres'),
  body('activo').optional().isBoolean().withMessage('Estado activo debe ser verdadero o falso')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Datos de entrada inválidos',
        details: errors.array()
      });
    }

    const { id } = req.params;
    const userId = parseInt(id);

    // Verificar permisos
    const isOwnProfile = req.user.id_usuario === userId;
    const isAdmin = ['administrador', 'superadministrador'].includes(req.user.rol);

    if (!isOwnProfile && !isAdmin) {
      return res.status(403).json({
        error: 'No tienes permisos para actualizar este usuario'
      });
    }

    // Verificar que el usuario existe
    const existingUsers = await executeQuery(
      'SELECT * FROM usuarios WHERE id_usuario = ?',
      [userId]
    );

    if (existingUsers.length === 0) {
      return res.status(404).json({
        error: 'Usuario no encontrado'
      });
    }

    const existingUser = existingUsers[0];
    const updateData = { ...req.body };

    // Solo admins pueden cambiar roles y estado activo
    if (!isAdmin) {
      delete updateData.rol;
      delete updateData.activo;
    }

    // Solo super admins pueden crear/modificar super admins
    if (updateData.rol === 'superadministrador' && req.user.rol !== 'superadministrador') {
      return res.status(403).json({
        error: 'Solo super administradores pueden asignar el rol de super administrador'
      });
    }

    // Si se está cambiando el email, verificar que no exista
    if (updateData.email && updateData.email !== existingUser.email) {
      const emailExists = await executeQuery(
        'SELECT id_usuario FROM usuarios WHERE email = ? AND id_usuario != ?',
        [updateData.email, userId]
      );

      if (emailExists.length > 0) {
        return res.status(409).json({
          error: 'El email ya está registrado'
        });
      }
    }

    // Hash de la nueva contraseña si se proporciona
    if (updateData.contrasena) {
      updateData.contrasena = await bcrypt.hash(updateData.contrasena, 12);
    }

    // Construir query de actualización
    const updateFields = [];
    const updateValues = [];

    for (const [key, value] of Object.entries(updateData)) {
      updateFields.push(`${key} = ?`);
      updateValues.push(value);
    }

    if (updateFields.length === 0) {
      return res.status(400).json({
        error: 'No hay campos para actualizar'
      });
    }

    updateValues.push(userId);

    await executeQuery(`
      UPDATE usuarios 
      SET ${updateFields.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE id_usuario = ?
    `, updateValues);

    // Obtener el usuario actualizado
    const updatedUsers = await executeQuery(`
      SELECT 
        id_usuario, nombre, apellido, email, rol, tipo_documento, 
        num_documento, fecha_nacimiento, genero, telefono, direccion,
        ciudad_residencia, pais_residencia, activo, created_at, updated_at
      FROM usuarios 
      WHERE id_usuario = ?
    `, [userId]);

    res.json({
      user: updatedUsers[0]
    });

  } catch (error) {
    console.error('Error actualizando usuario:', error);
    res.status(500).json({
      error: 'Error interno del servidor'
    });
  }
});

// DELETE /api/users/:id - Eliminar usuario (solo super admins)
router.delete('/:id', authenticateToken, requireSuperAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = parseInt(id);

    // No permitir que se elimine a sí mismo
    if (req.user.id_usuario === userId) {
      return res.status(400).json({
        error: 'No puedes eliminar tu propia cuenta'
      });
    }

    // Verificar que el usuario existe
    const existingUsers = await executeQuery(
      'SELECT id_usuario FROM usuarios WHERE id_usuario = ?',
      [userId]
    );

    if (existingUsers.length === 0) {
      return res.status(404).json({
        error: 'Usuario no encontrado'
      });
    }

    // Eliminar usuario (esto también eliminará los refresh tokens por CASCADE)
    await executeQuery(
      'DELETE FROM usuarios WHERE id_usuario = ?',
      [userId]
    );

    res.json({
      message: 'Usuario eliminado exitosamente'
    });

  } catch (error) {
    console.error('Error eliminando usuario:', error);
    res.status(500).json({
      error: 'Error interno del servidor'
    });
  }
});

module.exports = router;
