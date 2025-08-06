// routes/torneoRoutes.js
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');

// ✅ Importa el controlador
const {
  crearTorneo,
  obtenerTorneos,
  obtenerTorneo,
  editarTorneo,
  suspenderTorneo,
  cancelarTorneo,
  programarPartidos,
  obtenerTorneosDisponibles,
  crearEquipo
} = require('../controllers/torneoController');

// 🔍 Depuración: Verifica que cada función sea válida
console.log('crearTorneo:', typeof crearTorneo);
console.log('obtenerTorneos:', typeof obtenerTorneos);
console.log('obtenerTorneo:', typeof obtenerTorneo);
console.log('editarTorneo:', typeof editarTorneo);
console.log('suspenderTorneo:', typeof suspenderTorneo);
console.log('cancelarTorneo:', typeof cancelarTorneo);
console.log('programarPartidos:', typeof programarPartidos);


// Si alguna es undefined, lanza un error
if (typeof programarPartidos !== 'function') {
  throw new Error('❌ programarPartidos no es una función. Revisa torneoController.js');
}

// Rutas protegidas
router.post('/', auth, crearTorneo);
router.get('/', auth, obtenerTorneos);

//Ruta para jugadores: torneos disponibles
router.get('/disponibles', auth, obtenerTorneosDisponibles);
router.post('/equipos', auth, crearEquipo);

router.get('/:id', auth, obtenerTorneo);
router.put('/:id', auth, editarTorneo);
router.put('/:id/suspender', auth, suspenderTorneo);
router.put('/:id/cancelar', auth, cancelarTorneo);
router.post('/partidos/programar', auth, programarPartidos);



module.exports = router;