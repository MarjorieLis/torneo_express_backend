// backend/routes/torneos.js
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');

const { 
  crearTorneo, 
  listarTorneos,
  suspenderTorneo,
  cancelarTorneo,
  reanudarTorneo,
  obtenerTorneoPorId 
} = require('../controllers/torneo');

/**
 * POST /api/torneos - RF-001: Crear torneo
 */
router.post('/', auth, [
  require('express-validator').check('nombre', 'El nombre es obligatorio').not().isEmpty(),
  require('express-validator').check('disciplina', 'La disciplina es obligatoria').isIn(['fútbol', 'baloncesto', 'voleibol', 'tenis']),
  require('express-validator').check('categoria', 'La categoría es obligatoria').isIn(['masculino', 'femenino', 'mixto']),
  require('express-validator').check('formato', 'El formato es obligatorio').isIn(['grupos', 'eliminación directa', 'mixto']),
  require('express-validator').check('maxEquipos', 'El número máximo de equipos es obligatorio').isInt({ min: 2 }),
  require('express-validator').check('reglas', 'Las reglas son obligatorias').not().isEmpty(),
  require('express-validator').body('minJugadores', 'Mínimo de jugadores por equipo es obligatorio').isInt({ min: 1 }),
  require('express-validator').body('maxJugadores', 'Máximo de jugadores por equipo es obligatorio').isInt({ min: 2 })
], crearTorneo);

/**
 * GET /api/torneos - Listar todos los torneos
 */
router.get('/', auth, listarTorneos);

/**
 * GET /api/torneos/:id - Obtener torneo por ID
 */
router.get('/:id', auth, obtenerTorneoPorId); 

/**
 * PUT /api/torneos/:id/suspender - RF-007: Suspender torneo
 */
router.put('/:id/suspender', auth, suspenderTorneo);

/**
 * PUT /api/torneos/:id/cancelar - RF-008: Cancelar torneo
 */
router.put('/:id/cancelar', auth, cancelarTorneo);

/**
 * PUT /api/torneos/:id/reanudar - RF-007: Reanudar torneo
 */
router.put('/:id/reanudar', auth, reanudarTorneo);

module.exports = router;