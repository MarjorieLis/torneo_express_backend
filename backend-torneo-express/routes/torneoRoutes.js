const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');  // ruta correcta


const {
  crearTorneo,
  obtenerTorneos,
  obtenerTorneo,
  editarTorneo,
  suspenderTorneo,
  cancelarTorneo,
  obtenerHistorial
} = require('../controllers/torneoController');

// Rutas protegidas
router.post('/', auth, crearTorneo);
//router.get('/', auth, obtenerTorneos);
//router.get('/historial', auth, obtenerHistorial);  // Debe ir antes que '/:id'
//router.get('/:id', auth, obtenerTorneo);
//router.put('/:id', auth, editarTorneo);
//router.put('/:id/suspender', auth, suspenderTorneo);
//router.put('/:id/cancelar', auth, cancelarTorneo);

module.exports = router;
