const { executeQuery, testConnection } = require('./config/database');
const bcrypt = require('bcryptjs');

async function setupDatabase() {
  console.log('🚀 Iniciando configuración de base de datos...');
  
  try {
    // Probar conexión
    const isConnected = await testConnection();
    if (!isConnected) {
      throw new Error('No se pudo conectar a la base de datos');
    }

    console.log('📋 Verificando estructura de base de datos existente...');
    
    // Verificar si las tablas principales existen
    const tables = await executeQuery(`
      SELECT TABLE_NAME 
      FROM INFORMATION_SCHEMA.TABLES 
      WHERE TABLE_SCHEMA = ? AND TABLE_NAME IN ('Rol', 'Usuario', 'Cliente', 'Empleado')
    `, [process.env.DB_NAME]);

    if (tables.length === 0) {
      console.log('⚠️ Las tablas principales no existen. Asegúrate de haber ejecutado el script de creación de tablas en tu base de datos MySQL.');
      console.log('📋 Tablas requeridas: Rol, Usuario, Cliente, Empleado, Proveedores, Destino, Paquete_Turismo, Reserva, Pago, Cotizaciones');
      return;
    }

    console.log(`✅ Encontradas ${tables.length} tablas principales`);

    // Crear tabla refresh_tokens si no existe (para JWT)
    console.log('📋 Verificando tabla refresh_tokens...');
    await executeQuery(`
      CREATE TABLE IF NOT EXISTS refresh_tokens (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        token VARCHAR(500) NOT NULL,
        expires_at TIMESTAMP NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_token (token),
        INDEX idx_user_id (user_id),
        INDEX idx_expires_at (expires_at)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    // Verificar si existen roles
    const existingRoles = await executeQuery('SELECT COUNT(*) as count FROM Rol');
    
    if (existingRoles[0].count === 0) {
      console.log('👥 Insertando roles del sistema...');
      
      const roles = [
        { rol: 'Superadministrador', descripcion: 'Acceso completo al sistema' },
        { rol: 'Administrador', descripcion: 'Gestión de usuarios y configuración' },
        { rol: 'Asesor', descripcion: 'Gestión de clientes y reservas' },
        { rol: 'Cliente', descripcion: 'Acceso limitado para clientes' }
      ];

      for (const rol of roles) {
        await executeQuery(`
          INSERT INTO Rol (rol, descripcion) VALUES (?, ?)
        `, [rol.rol, rol.descripcion]);
      }
    }

    // Obtener IDs de roles
    const rolesData = await executeQuery('SELECT id_rol, rol FROM Rol');
    const roleMap = {};
    rolesData.forEach(r => {
      roleMap[r.rol] = r.id_rol;
    });

    // Verificar si ya existen usuarios
    const existingUsers = await executeQuery('SELECT COUNT(*) as count FROM Usuario');
    
    if (existingUsers[0].count === 0) {
      console.log('👥 Insertando usuarios de ejemplo...');
      
      // Hash de contraseñas
      const superAdminPassword = await bcrypt.hash('superadmin123', 12);
      const adminPassword = await bcrypt.hash('Osquitar07', 12);
      const asesorPassword = await bcrypt.hash('asesor123', 12);

      // Insertar usuarios de ejemplo
      const usuarios = [
        {
          nombre: 'Super',
          apellido: 'Admin',
          tipo_documento: 'Cedula Ciudadania',
          num_documento: '00000000',
          fecha_nacimiento: '1980-01-01',
          lugar_nacimiento: 'Bogotá',
          genero: 'M',
          telefono: 573000000000,
          correo: 'superadmin@aquatour.com',
          direccion: 'Oficina Principal',
          ciudad_residencia: 'Bogotá',
          pais_residencia: 'Colombia',
          contrasena: superAdminPassword,
          id_rol: roleMap['Superadministrador']
        },
        {
          nombre: 'David',
          apellido: 'Gonzalez',
          tipo_documento: 'Cedula Ciudadania',
          num_documento: '1017924927',
          fecha_nacimiento: '2005-09-07',
          lugar_nacimiento: 'Medellín',
          genero: 'M',
          telefono: 573233053830,
          correo: 'davidg@aquatour.com',
          direccion: 'Carrera 85f #58a - 51',
          ciudad_residencia: 'Medellín',
          pais_residencia: 'Colombia',
          contrasena: adminPassword,
          id_rol: roleMap['Administrador']
        },
        {
          nombre: 'Luis',
          apellido: 'Martínez',
          tipo_documento: 'Cedula Ciudadania',
          num_documento: '87654321',
          fecha_nacimiento: '1985-08-22',
          lugar_nacimiento: 'Medellín',
          genero: 'M',
          telefono: 573109876543,
          correo: 'asesor@aquatour.com',
          direccion: 'Carrera 45 #12-34',
          ciudad_residencia: 'Medellín',
          pais_residencia: 'Colombia',
          contrasena: asesorPassword,
          id_rol: roleMap['Asesor']
        }
      ];

      for (const usuario of usuarios) {
        const result = await executeQuery(`
          INSERT INTO Usuario (
            nombre, apellido, tipo_documento, num_documento, fecha_nacimiento,
            lugar_nacimiento, genero, telefono, correo, direccion, ciudad_residencia,
            pais_residencia, contrasena, id_rol
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `, [
          usuario.nombre, usuario.apellido, usuario.tipo_documento, usuario.num_documento,
          usuario.fecha_nacimiento, usuario.lugar_nacimiento, usuario.genero, usuario.telefono,
          usuario.correo, usuario.direccion, usuario.ciudad_residencia, usuario.pais_residencia,
          usuario.contrasena, usuario.id_rol
        ]);

        // Crear empleado para usuarios administrativos
        if (usuario.id_rol === roleMap['Superadministrador'] || usuario.id_rol === roleMap['Administrador'] || usuario.id_rol === roleMap['Asesor']) {
          await executeQuery(`
            INSERT INTO Empleado (id_usuario, cargo, fecha_contratacion, area_asignada)
            VALUES (?, ?, CURDATE(), ?)
          `, [
            result.insertId,
            usuario.id_rol === roleMap['Superadministrador'] ? 'Superadministrador' :
            usuario.id_rol === roleMap['Administrador'] ? 'Administrador' : 'Asesor de Ventas',
            usuario.id_rol === roleMap['Superadministrador'] ? 'Dirección General' :
            usuario.id_rol === roleMap['Administrador'] ? 'Administración' : 'Ventas'
          ]);
        }
      }
    }

    // Verificar si existen proveedores de ejemplo
    const existingProviders = await executeQuery('SELECT COUNT(*) as count FROM Proveedores');
    
    if (existingProviders[0].count === 0) {
      console.log('🏢 Insertando proveedores de ejemplo...');
      
      const proveedores = [
        {
          nombre: 'Hotel Paradise Resort',
          tipo_proveedor: 'Hospedaje',
          telefono: 573001234567,
          correo: 'reservas@paradiseresort.com',
          estado: 'Activo'
        },
        {
          nombre: 'Aerolíneas del Caribe',
          tipo_proveedor: 'Transporte Aéreo',
          telefono: 573007654321,
          correo: 'ventas@aerocaribe.com',
          estado: 'Activo'
        },
        {
          nombre: 'Tours Aventura',
          tipo_proveedor: 'Actividades',
          telefono: 573009876543,
          correo: 'info@toursaventura.com',
          estado: 'Activo'
        }
      ];

      for (const proveedor of proveedores) {
        await executeQuery(`
          INSERT INTO Proveedores (nombre, tipo_proveedor, telefono, correo, estado)
          VALUES (?, ?, ?, ?, ?)
        `, [proveedor.nombre, proveedor.tipo_proveedor, proveedor.telefono, proveedor.correo, proveedor.estado]);
      }
    }

    console.log('✅ Base de datos configurada exitosamente!');
    console.log('\n📋 Usuarios creados:');
    console.log('- Super Admin: superadmin@aquatour.com / superadmin123');
    console.log('- Admin: davidg@aquatour.com / Osquitar07');
    console.log('- Asesor: asesor@aquatour.com / asesor123');
    console.log('\n📊 Estructura de base de datos verificada y datos de ejemplo insertados');
    
  } catch (error) {
    console.error('❌ Error configurando base de datos:', error);
    process.exit(1);
  }
}

// Ejecutar si se llama directamente
if (require.main === module) {
  setupDatabase().then(() => {
    console.log('🎉 Configuración completada!');
    process.exit(0);
  });
}

module.exports = { setupDatabase };
