// backend/routes/torneos.js
const express = require('express');
const router = express.Router();
const { body, validationResult, check } = require('express-validator');
const auth = require('../middleware/auth');
const Torneo = require('../models/Torneo');

/**
 * POST /api/torneos - RF-001: Crear torneo
 */
router.post(
  '/',
  [
    auth,
    // Validación de campos
    body('nombre', 'El nombre del torneo es obligatorio').not().isEmpty().trim(),
    body('disciplina', 'La disciplina es obligatoria').not().isEmpty(),
    body('fechaInicio', 'La fecha de inicio es obligatoria').isISO8601().toDate(),
    body('fechaFin', 'La fecha de fin es obligatoria').isISO8601().toDate(),
    body('maxEquipos', 'El número máximo de equipos es obligatorio').isInt({ min: 2 }),
    body('reglas', 'Las reglas son obligatorias').not().isEmpty(),
    check('formato', 'El formato es obligatorio').isIn(['grupos', 'eliminación directa', 'mixto'])
  ],
  async (req, res) => {
    // Verificar errores de validación
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { nombre, disciplina, fechaInicio, fechaFin, maxEquipos, reglas, formato } = req.body;

    try {
      // Verificar si el torneo ya existe
      let torneo = await Torneo.findOne({ nombre });
      if (torneo) {
        return res.status(400).json({ msg: 'Ya existe un torneo con ese nombre' });
      }

      // Crear nuevo torneo
      torneo = new Torneo({
        nombre,
        disciplina,
        fechaInicio: new Date(fechaInicio),
        fechaFin: new Date(fechaFin),
        maxEquipos,
        reglas,
        formato,
        organizador: req.user.id
      });

      await torneo.save();

      res.status(201).json(torneo);
    } catch (err) {
      console.error(err.message);
      res.status(500).send('Error en el servidor');
    }
  }
);

/**
 * GET /api/torneos - Listar todos los torneos
 */
router.get('/', async (req, res) => {
  try {
    const torneos = await Torneo.find().populate('organizador', 'name email');
    res.json(torneos);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error en el servidor');
  }
});

module.exports = router;