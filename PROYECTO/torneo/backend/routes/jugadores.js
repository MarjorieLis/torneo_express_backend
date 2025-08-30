// backend/routes/jugadores.js
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const User = require('../models/User');

/**
 * GET /api/jugadores - RF-014: Obtener lista de jugadores
 */
router.get('/', auth, async (req, res) => {
  try {
    console.log('👤 Usuario autenticado:', req.user);
    const jugadores = await User.find({ role: 'jugador' }).select('name position cedula email').lean();
    console.log('✅ Jugadores encontrados:', jugadores.length);
    res.json(jugadores); // 👈 Enviamos directamente el array
  } catch (err) {
    console.error('❌ Error en /api/jugadores:', err.message);
    res.status(500).json({ msg: 'Error en el servidor' });
  }
});

module.exports = router;