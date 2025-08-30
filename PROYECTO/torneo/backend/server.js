// backend/server.js
const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const cors = require('cors');
const connectDB = require('./config/db');

dotenv.config();
connectDB();

const app = express();

// Middleware
app.use(cors({
  origin: '*' // ✅ Permite cualquier origen (ajusta en producción)
}));
app.use(express.json());

// Rutas
app.use('/api/auth', require('./routes/auth'));
app.use('/api/torneos', require('./routes/torneos'));
app.use('/api/equipos', require('./routes/equipos'));
app.use('/api/jugadores', require('./routes/jugadores'));
// Ruta de prueba
app.get('/', (req, res) => {
  res.send('API de Torneo UIDE funcionando ✅');
});

// Puerto
const PORT = process.env.PORT || 5000;

// ✅ Iniciar servidor con manejo de errores
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Servidor corriendo en el puerto ${PORT} (0.0.0.0)`);
  console.log(`📡 Accesible desde el emulador como: http://10.0.2.2:${PORT}`);
});

// ✅ Manejo de errores del servidor
server.on('error', (error) => {
  if (error.code === 'EADDRINUSE') {
    console.error(`❌ Puerto ${PORT} ocupado. Cierra otras aplicaciones o cambia el puerto.`);
  } else {
    console.error('❌ Error al iniciar el servidor:', error.message);
  }
});