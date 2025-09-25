const mysql = require('mysql2/promise');
require('dotenv').config();

// Configuración de la base de datos
const dbConfig = {
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  acquireTimeout: 60000,
  timeout: 60000,
  reconnect: true,
  ssl: {
    rejectUnauthorized: false
  }
};

// Crear pool de conexiones
const pool = mysql.createPool(dbConfig);

// Función para probar la conexión
async function testConnection() {
  try {
    const connection = await pool.getConnection();
    console.log('✅ Conexión a MySQL establecida correctamente');
    console.log(`📊 Base de datos: ${process.env.DB_NAME}`);
    console.log(`🏠 Host: ${process.env.DB_HOST}`);
    connection.release();
    return true;
  } catch (error) {
    console.error('❌ Error conectando a MySQL:', error.message);
    return false;
  }
}

// Función para ejecutar queries
async function executeQuery(query, params = []) {
  try {
    const [results] = await pool.execute(query, params);
    return results;
  } catch (error) {
    console.error('❌ Error ejecutando query:', error.message);
    throw error;
  }
}

// Función para obtener una conexión del pool
async function getConnection() {
  try {
    return await pool.getConnection();
  } catch (error) {
    console.error('❌ Error obteniendo conexión:', error.message);
    throw error;
  }
}

module.exports = {
  pool,
  testConnection,
  executeQuery,
  getConnection
};
