// routes/equipoRoutes.js
const express = require('express');
const router = express.Router();
const { crearEquipo } = require('../controllers/equipoController');

// POST /api/equipos
router.post('/', crearEquipo);

module.exports = router;