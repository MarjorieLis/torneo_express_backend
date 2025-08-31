// backend/routes/equipos.js
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');

// ✅ Importa los controladores
const {
  crearEquipo,
  listarEquipos,
  aprobarEquipo,
  rechazarEquipo
} = require('../controllers/equipo');

/**
 * POST /api/equipos - RF-002: Registrar equipo
 */
router.post('/', auth, crearEquipo);

/**
 * GET /api/equipos - Listar todos los equipos
 */
router.get('/', auth, listarEquipos);

/**
 * PUT /api/equipos/:id/aprobar - RF-002: Aprobar equipo
 */
router.put('/:id/aprobar', auth, aprobarEquipo);

/**
 * PUT /api/equipos/:id/rechazar - RF-002: Rechazar equipo
 */
router.put('/:id/rechazar', auth, rechazarEquipo);

// ✅ Exportar el router
module.exports = router;