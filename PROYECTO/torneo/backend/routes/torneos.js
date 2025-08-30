// backend/routes/torneos.js
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { check } = require('express-validator');
const { 
  crearTorneo, 
  listarTorneos,
  suspenderTorneo,
  cancelarTorneo,
  reanudarTorneo  // ✅ Importado
} = require('../controllers/torneo');

// POST /api/torneos - RF-001: Crear torneo
router.post('/', auth, [
  check('nombre', 'El nombre es obligatorio').not().isEmpty(),
  check('disciplina', 'La disciplina es obligatoria').isIn(['fútbol', 'baloncesto', 'voleibol', 'tenis']),
  check('formato', 'El formato es obligatorio').isIn(['grupos', 'eliminación directa'])
], crearTorneo);

// GET /api/torneos - Listar todos los torneos
router.get('/', auth, listarTorneos);

// PUT /api/torneos/:id/suspender - RF-007: Suspender torneo
router.put('/:id/suspender', auth, suspenderTorneo);

// PUT /api/torneos/:id/cancelar - RF-008: Cancelar torneo
router.put('/:id/cancelar', auth, cancelarTorneo);

// PUT /api/torneos/:id/reanudar - RF-007: Reanudar torneo
router.put('/:id/reanudar', auth, reanudarTorneo); // ✅ Ruta añadida

module.exports = router;