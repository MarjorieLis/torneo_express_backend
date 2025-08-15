// routes/equipoRoutes.js
const express = require('express');
const router = express.Router();
const verificarToken = require('../middleware/auth');
const {
  crearEquipo,
  obtenerEquiposPendientes,
  aprobarEquipo,
  rechazarEquipo,
  obtenerEquiposAprobados,
  obtenerEquiposPorTorneo,
  asignarJugadores
} = require('../controllers/equipoController');

// ✅ Crear un nuevo equipo
router.post('/', verificarToken, crearEquipo);

// ✅ Obtener equipos pendientes
router.get('/pendientes', verificarToken, obtenerEquiposPendientes);

// ✅ Obtener equipos aprobados
router.get('/aprobados', verificarToken, obtenerEquiposAprobados);

// ✅ Aprobar equipo
router.put('/aprobado/:id', verificarToken, aprobarEquipo);

// ✅ Rechazar equipo
router.put('/rechazado/:id', verificarToken, rechazarEquipo);

// ✅ Obtener equipos por torneo
router.get('/torneo/:torneoId', verificarToken, obtenerEquiposPorTorneo);

// ✅ ✅ RUTA CLAVE: Asignar jugadores a un equipo por ID válido
router.put('/:id/jugadores', verificarToken, asignarJugadores);

module.exports = router;