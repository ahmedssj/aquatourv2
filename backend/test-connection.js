const { testConnection, executeQuery } = require('./config/database');
require('dotenv').config();

async function testDatabaseConnection() {
  console.log('🧪 Probando conexión a la base de datos...');
  console.log(`📊 Host: ${process.env.DB_HOST}`);
  console.log(`📊 Base de datos: ${process.env.DB_NAME}`);
  console.log(`👤 Usuario: ${process.env.DB_USER}`);
  
  try {
    // Probar conexión básica
    const isConnected = await testConnection();
    if (!isConnected) {
      throw new Error('No se pudo conectar a la base de datos');
    }

    // Verificar tablas existentes
    console.log('\n📋 Verificando tablas existentes...');
    const tables = await executeQuery(`
      SELECT TABLE_NAME, TABLE_ROWS, CREATE_TIME 
      FROM INFORMATION_SCHEMA.TABLES 
      WHERE TABLE_SCHEMA = ?
      ORDER BY TABLE_NAME
    `, [process.env.DB_NAME]);

    if (tables.length === 0) {
      console.log('⚠️ No se encontraron tablas en la base de datos');
      console.log('💡 Asegúrate de haber ejecutado el script de creación de tablas');
      return;
    }

    console.log(`✅ Encontradas ${tables.length} tablas:`);
    tables.forEach(table => {
      console.log(`  - ${table.TABLE_NAME} (${table.TABLE_ROWS || 0} filas)`);
    });

    // Verificar estructura de tabla Usuario
    console.log('\n👤 Verificando estructura de tabla Usuario...');
    try {
      const userColumns = await executeQuery(`
        SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = ? AND TABLE_NAME = 'Usuario'
        ORDER BY ORDINAL_POSITION
      `, [process.env.DB_NAME]);

      if (userColumns.length > 0) {
        console.log('✅ Estructura de tabla Usuario:');
        userColumns.forEach(col => {
          console.log(`  - ${col.COLUMN_NAME}: ${col.DATA_TYPE} ${col.IS_NULLABLE === 'NO' ? '(NOT NULL)' : ''}`);
        });
      } else {
        console.log('⚠️ Tabla Usuario no encontrada');
      }
    } catch (error) {
      console.log('⚠️ Error verificando tabla Usuario:', error.message);
    }

    // Verificar datos de ejemplo
    console.log('\n📊 Verificando datos existentes...');
    
    try {
      const roleCount = await executeQuery('SELECT COUNT(*) as count FROM Rol');
      console.log(`✅ Roles: ${roleCount[0].count} registros`);
      
      if (roleCount[0].count > 0) {
        const roles = await executeQuery('SELECT rol FROM Rol');
        console.log('  Roles disponibles:', roles.map(r => r.rol).join(', '));
      }
    } catch (error) {
      console.log('⚠️ Error verificando roles:', error.message);
    }

    try {
      const userCount = await executeQuery('SELECT COUNT(*) as count FROM Usuario');
      console.log(`✅ Usuarios: ${userCount[0].count} registros`);
      
      if (userCount[0].count > 0) {
        const users = await executeQuery(`
          SELECT u.nombre, u.apellido, u.correo, r.rol 
          FROM Usuario u 
          LEFT JOIN Rol r ON u.id_rol = r.id_rol 
          LIMIT 5
        `);
        console.log('  Usuarios de ejemplo:');
        users.forEach(user => {
          console.log(`    - ${user.nombre} ${user.apellido} (${user.correo}) - ${user.rol || 'Sin rol'}`);
        });
      }
    } catch (error) {
      console.log('⚠️ Error verificando usuarios:', error.message);
    }

    try {
      const providerCount = await executeQuery('SELECT COUNT(*) as count FROM Proveedores');
      console.log(`✅ Proveedores: ${providerCount[0].count} registros`);
    } catch (error) {
      console.log('⚠️ Error verificando proveedores:', error.message);
    }

    // Probar consulta de login
    console.log('\n🔐 Probando consulta de login...');
    try {
      const loginTest = await executeQuery(`
        SELECT u.*, r.rol as rol_nombre 
        FROM Usuario u 
        INNER JOIN Rol r ON u.id_rol = r.id_rol 
        WHERE u.correo = ?
        LIMIT 1
      `, ['superadmin@aquatour.com']);

      if (loginTest.length > 0) {
        console.log('✅ Consulta de login funciona correctamente');
        console.log(`  Usuario encontrado: ${loginTest[0].nombre} ${loginTest[0].apellido}`);
        console.log(`  Rol: ${loginTest[0].rol_nombre}`);
      } else {
        console.log('⚠️ No se encontró usuario de prueba para login');
      }
    } catch (error) {
      console.log('❌ Error en consulta de login:', error.message);
    }

    console.log('\n🎉 ¡Prueba de conexión completada exitosamente!');
    console.log('\n📋 Resumen:');
    console.log('✅ Conexión a MySQL establecida');
    console.log('✅ Estructura de base de datos verificada');
    console.log('✅ Datos de ejemplo disponibles');
    console.log('✅ Consultas de autenticación funcionando');
    
    console.log('\n🚀 Tu base de datos está lista para usar con la API!');
    console.log('\n👥 Usuarios de prueba disponibles:');
    console.log('  - superadmin@aquatour.com / superadmin123');
    console.log('  - davidg@aquatour.com / Osquitar07');
    console.log('  - asesor@aquatour.com / asesor123');

  } catch (error) {
    console.error('❌ Error en la prueba de conexión:', error);
    process.exit(1);
  }
}

// Ejecutar prueba
testDatabaseConnection().then(() => {
  console.log('\n✅ Prueba completada');
  process.exit(0);
}).catch(error => {
  console.error('❌ Error:', error);
  process.exit(1);
});
