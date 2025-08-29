const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const auth = require('../middleware/auth');
const { crearTorneo, listarTorneos } = require('../controllers/torneo');

router.post('/', auth, [
  body('nombre').not().isEmpty(),
  body('disciplina').not().isEmpty(),
  body('fechaInicio').isISO8601(),
  body('fechaFin').isISO8601(),
  body('maxEquipos').isInt({ min: 2 }),
  body('reglas').not().isEmpty(),
  body('formato').isIn(['grupos', 'eliminación directa'])
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  await crearTorneo(req, res);
});

router.get('/', auth, listarTorneos);

module.exports = router;