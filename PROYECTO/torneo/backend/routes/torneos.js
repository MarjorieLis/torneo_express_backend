// backend/routes/torneos.js
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { check, body } = require('express-validator'); // ✅ Importar 'body'
const { 
  crearTorneo, 
  listarTorneos,
  suspenderTorneo,
  cancelarTorneo,
  reanudarTorneo
} = require('../controllers/torneo');

/**
 * POST /api/torneos - RF-001: Crear torneo
 */
router.post('/', auth, [
  check('nombre', 'El nombre es obligatorio').not().isEmpty(),
  check('disciplina', 'La disciplina es obligatoria').isIn(['fútbol', 'baloncesto', 'voleibol', 'tenis']),
  check('formato', 'El formato es obligatorio').isIn(['grupos', 'eliminación directa', 'mixto']),
  check('categoria', 'La categoría es obligatoria').isIn(['masculino', 'femenino', 'mixto']), // ✅ Validar categoría
  check('maxEquipos', 'El número máximo de equipos es obligatorio').isInt({ min: 2 }),
  check('reglas', 'Las reglas son obligatorias').not().isEmpty(),
  body('minJugadores', 'Mínimo de jugadores por equipo es obligatorio').isInt({ min: 1 }),
  body('maxJugadores', 'Máximo de jugadores por equipo es obligatorio').isInt({ min: 2 })
], crearTorneo);

/**
 * GET /api/torneos - Listar todos los torneos
 */
router.get('/', auth, listarTorneos);

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