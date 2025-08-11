// routes/jugadorRoutes.js
const express = require('express');
const router = express.Router();
const { buscarJugadorPorCedulaOCorreo, obtenerJugadoresDisponibles } = require('../controllers/jugadorController');

// GET /api/jugadores/buscar?query=123456789
router.get('/buscar', buscarJugadorPorCedulaOCorreo);

// GET /api/jugadores/disponibles
router.get('/disponibles', obtenerJugadoresDisponibles);

module.exports = router;