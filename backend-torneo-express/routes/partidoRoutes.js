// routes/partidoRoutes.js
const express = require('express');
const router = express.Router();
const partidoController = require('../controllers/partidoController');
const auth = require('../middleware/auth');

router.post('/programar', auth, partidoController.programarPartido);
router.get('/:torneoId/partidos', auth, partidoController.obtenerPartidosPorTorneo);

module.exports = router;