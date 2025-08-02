// routes/torneoRoutes.js
const express = require('express');
const router = express.Router();
const {
  crearTorneo,
  obtenerTorneos,
  obtenerTorneo,
  editarTorneo,
  suspenderTorneo,
  cancelarTorneo,
  obtenerHistorial
} = require('../controllers/torneoController');

// Rutas para torneos
router.post('/', crearTorneo);
router.get('/', obtenerTorneos);
router.get('/:id', obtenerTorneo);
router.put('/:id', editarTorneo);
router.put('/:id/suspender', suspenderTorneo);
router.put('/:id/cancelar', cancelarTorneo);
router.get('/historial', obtenerHistorial);

module.exports = router;