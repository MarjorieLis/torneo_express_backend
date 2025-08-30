// backend/routes/equipos.js
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { check } = require('express-validator');
const { 
  crearEquipo,
  listarEquipos,
  aprobarEquipo,
  rechazarEquipo
} = require('../controllers/equipo');

// POST /api/equipos - RF-002: Registro de equipo
router.post('/', auth, [
  check('nombre', 'El nombre es obligatorio').not().isEmpty(),
  check('cedulaCapitan', 'La cédula del capitán es obligatoria').not().isEmpty(),
  check('disciplina', 'La disciplina es obligatoria').isIn(['fútbol', 'baloncesto', 'voleibol', 'tenis'])
], crearEquipo);

// GET /api/equipos - Listar todos los equipos (organizador)
router.get('/', auth, listarEquipos);

// PUT /api/equipos/:id/aprobar - RF-002: Aprobar equipo
router.put('/:id/aprobar', auth, aprobarEquipo);

// PUT /api/equipos/:id/rechazar - RF-002: Rechazar equipo
router.put('/:id/rechazar', auth, rechazarEquipo);

module.exports = router;