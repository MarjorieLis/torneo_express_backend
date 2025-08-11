// routes/equipoRoutes.js
const express = require('express');
const router = express.Router();
const { crearEquipo, obtenerEquiposPendientes } = require('../controllers/equipoController');

router.post('/', crearEquipo);
router.get('/pendientes', obtenerEquiposPendientes);

module.exports = router;