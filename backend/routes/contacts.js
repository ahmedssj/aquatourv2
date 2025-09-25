const express = require('express');
const { body, validationResult } = require('express-validator');
const { executeQuery } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// GET /api/contacts - Obtener todos los contactos
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { page = 1, limit = 50, search = '' } = req.query;
    const offset = (parseInt(page) - 1) * parseInt(limit);

    let query = 'SELECT * FROM contactos';
    let countQuery = 'SELECT COUNT(*) as total FROM contactos';
    const queryParams = [];
    const countParams = [];

    // Agregar búsqueda si se proporciona
    if (search.trim()) {
      const searchTerm = `%${search.trim()}%`;
      query += ' WHERE name LIKE ? OR email LIKE ? OR company LIKE ?';
      countQuery += ' WHERE name LIKE ? OR email LIKE ? OR company LIKE ?';
      queryParams.push(searchTerm, searchTerm, searchTerm);
      countParams.push(searchTerm, searchTerm, searchTerm);
    }

    // Agregar ordenamiento y paginación
    query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    queryParams.push(parseInt(limit), offset);

    // Ejecutar consultas
    const [contacts, totalResult] = await Promise.all([
      executeQuery(query, queryParams),
      executeQuery(countQuery, countParams)
    ]);

    const total = totalResult[0].total;
    const totalPages = Math.ceil(total / parseInt(limit));

    res.json({
      contacts: contacts,
      pagination: {
        current_page: parseInt(page),
        total_pages: totalPages,
        total_items: total,
        items_per_page: parseInt(limit)
      }
    });

  } catch (error) {
    console.error('Error obteniendo contactos:', error);
    res.status(500).json({
      error: 'Error interno del servidor'
    });
  }
});

// GET /api/contacts/:id - Obtener contacto por ID
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const contactId = parseInt(id);

    const contacts = await executeQuery(
      'SELECT * FROM contactos WHERE id = ?',
      [contactId]
    );

    if (contacts.length === 0) {
      return res.status(404).json({
        error: 'Contacto no encontrado'
      });
    }

    res.json({
      contact: contacts[0]
    });

  } catch (error) {
    console.error('Error obteniendo contacto:', error);
    res.status(500).json({
      error: 'Error interno del servidor'
    });
  }
});

// POST /api/contacts - Crear nuevo contacto
router.post('/', authenticateToken, [
  body('name').trim().isLength({ min: 2 }).withMessage('Nombre debe tener al menos 2 caracteres'),
  body('email').isEmail().normalizeEmail().withMessage('Email válido es requerido'),
  body('phone').optional().trim().isLength({ min: 7 }).withMessage('Teléfono debe tener al menos 7 caracteres'),
  body('company').optional().trim().isLength({ min: 2 }).withMessage('Empresa debe tener al menos 2 caracteres')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Datos de entrada inválidos',
        details: errors.array()
      });
    }

    const { name, email, phone, company } = req.body;

    // Verificar si el email ya existe
    const existingContacts = await executeQuery(
      'SELECT id FROM contactos WHERE email = ?',
      [email]
    );

    if (existingContacts.length > 0) {
      return res.status(409).json({
        error: 'Ya existe un contacto con este email'
      });
    }

    // Insertar contacto
    const result = await executeQuery(`
      INSERT INTO contactos (name, email, phone, company)
      VALUES (?, ?, ?, ?)
    `, [name, email, phone || null, company || null]);

    // Obtener el contacto creado
    const newContacts = await executeQuery(
      'SELECT * FROM contactos WHERE id = ?',
      [result.insertId]
    );

    res.status(201).json({
      contact: newContacts[0]
    });

  } catch (error) {
    console.error('Error creando contacto:', error);
    res.status(500).json({
      error: 'Error interno del servidor'
    });
  }
});

// PUT /api/contacts/:id - Actualizar contacto
router.put('/:id', authenticateToken, [
  body('name').optional().trim().isLength({ min: 2 }).withMessage('Nombre debe tener al menos 2 caracteres'),
  body('email').optional().isEmail().normalizeEmail().withMessage('Email válido es requerido'),
  body('phone').optional().trim().isLength({ min: 7 }).withMessage('Teléfono debe tener al menos 7 caracteres'),
  body('company').optional().trim().isLength({ min: 2 }).withMessage('Empresa debe tener al menos 2 caracteres')
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
    const contactId = parseInt(id);

    // Verificar que el contacto existe
    const existingContacts = await executeQuery(
      'SELECT * FROM contactos WHERE id = ?',
      [contactId]
    );

    if (existingContacts.length === 0) {
      return res.status(404).json({
        error: 'Contacto no encontrado'
      });
    }

    const existingContact = existingContacts[0];
    const updateData = { ...req.body };

    // Si se está cambiando el email, verificar que no exista
    if (updateData.email && updateData.email !== existingContact.email) {
      const emailExists = await executeQuery(
        'SELECT id FROM contactos WHERE email = ? AND id != ?',
        [updateData.email, contactId]
      );

      if (emailExists.length > 0) {
        return res.status(409).json({
          error: 'Ya existe un contacto con este email'
        });
      }
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

    updateValues.push(contactId);

    await executeQuery(`
      UPDATE contactos 
      SET ${updateFields.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `, updateValues);

    // Obtener el contacto actualizado
    const updatedContacts = await executeQuery(
      'SELECT * FROM contactos WHERE id = ?',
      [contactId]
    );

    res.json({
      contact: updatedContacts[0]
    });

  } catch (error) {
    console.error('Error actualizando contacto:', error);
    res.status(500).json({
      error: 'Error interno del servidor'
    });
  }
});

// DELETE /api/contacts/:id - Eliminar contacto
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const contactId = parseInt(id);

    // Verificar que el contacto existe
    const existingContacts = await executeQuery(
      'SELECT id FROM contactos WHERE id = ?',
      [contactId]
    );

    if (existingContacts.length === 0) {
      return res.status(404).json({
        error: 'Contacto no encontrado'
      });
    }

    // Eliminar contacto
    await executeQuery(
      'DELETE FROM contactos WHERE id = ?',
      [contactId]
    );

    res.json({
      message: 'Contacto eliminado exitosamente'
    });

  } catch (error) {
    console.error('Error eliminando contacto:', error);
    res.status(500).json({
      error: 'Error interno del servidor'
    });
  }
});

module.exports = router;
