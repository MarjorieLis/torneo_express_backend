// backend/controllers/torneo.js
const Torneo = require('../models/Torneo');

/**
 * POST /api/torneos - RF-001: Crear torneo
 */
exports.crearTorneo = async (req, res) => {
  const {
    nombre,
    disciplina,
    fechaInicio,
    fechaFin,
    maxEquipos,
    reglas,
    formato
  } = req.body;

  try {
    // Verificar si ya existe un torneo con ese nombre
    const torneoExistente = await Torneo.findOne({ nombre });
    if (torneoExistente) {
      return res.status(400).json({
        msg: 'Ya existe un torneo con ese nombre'
      });
    }

    // Verificar solapamiento de fechas
    const torneos = await Torneo.find();
    const nuevaFechaInicio = new Date(fechaInicio);
    const nuevaFechaFin = new Date(fechaFin);

    const torneoSolapado = torneos.some(t => {
      const tInicio = new Date(t.fechaInicio);
      const tFin = new Date(t.fechaFin);
      return (
        (nuevaFechaInicio >= tInicio && nuevaFechaInicio <= tFin) ||
        (nuevaFechaFin >= tInicio && nuevaFechaFin <= tFin) ||
        (nuevaFechaInicio <= tInicio && nuevaFechaFin >= tFin)
      );
    });

    if (torneoSolapado) {
      return res.status(400).json({
        msg: 'Las fechas seleccionadas ya están ocupadas por otros torneos'
      });
    }

    // Crear nuevo torneo
    const nuevoTorneo = new Torneo({
      nombre,
      disciplina,
      fechaInicio,
      fechaFin,
      maxEquipos,
      reglas,
      formato,
      estado: 'activo',
      organizador: req.user.id
    });

    await nuevoTorneo.save();

    res.status(201).json({
      msg: 'Torneo creado con éxito',
      torneo: nuevoTorneo
    });
  } catch (err) {
    console.error('Error al crear torneo:', err.message);
    res.status(500).send('Error en el servidor');
  }
};

/**
 * GET /api/torneos - Listar todos los torneos
 */
exports.listarTorneos = async (req, res) => {
  try {
    const torneos = await Torneo.find().populate('organizador', 'name email');
    res.json(torneos); // ✅ Estructura esperada por el frontend
  } catch (err) {
    console.error('Error al listar torneos:', err.message);
    res.status(500).send('Error en el servidor');
  }
};