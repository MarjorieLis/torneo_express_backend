const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors({
  origin: ['http://localhost:3000', 'https://frontend-torneo-express.com'],
  credentials: true,
}));
app.use(express.json());

// Conexión a MongoDB
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('Conectado a MongoDB'))
.catch((err) => console.log('Error al conectar a MongoDB:', err));

// Rutas
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/torneos', require('./routes/torneoRoutes'));
app.use('/api/partidos', require('./routes/partidoRoutes'));

// Ruta de prueba
app.get('/', (req, res) => {
  res.send('Torneo Express API - Backend');
});

// Puerto
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://0.0.0.0:${PORT}`);
});
