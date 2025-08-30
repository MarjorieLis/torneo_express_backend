// backend/routes/jugadores.js
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const User = require('../models/User');

// GET /api/jugadores - Listar todos los jugadores
router.get('/', auth, async (req, res) => {
  try {
    const jugadores = await User.find({ rol: 'jugador' }).select('name position cedula');
    res.json({ data: jugadores });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error en el servidor');
  }
});

module.exports = router;