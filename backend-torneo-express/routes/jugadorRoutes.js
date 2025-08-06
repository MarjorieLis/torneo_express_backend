// routes/jugadorRoutes.js
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { buscarJugadorPorCedulaOCorreo, obtenerJugadoresDisponibles } = require('../controllers/jugadorController');

// ✅ Ruta para buscar jugador
router.get('/buscar', auth, buscarJugadorPorCedulaOCorreo);
router.get('/disponibles', auth, obtenerJugadoresDisponibles);

module.exports = router;