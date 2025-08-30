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
    const torneos = await Torneo.find({ organizador: req.user.id })
      .sort({ createdAt: -1 });
    res.json({ data: torneos });
  } catch (err) {
    console.error('Error al listar torneos:', err.message);
    res.status(500).send('Error en el servidor');
  }
};

/**
 * PUT /api/torneos/:id/suspender - RF-007: Suspender torneo
 */
exports.suspenderTorneo = async (req, res) => {
  try {
    const torneo = await Torneo.findById(req.params.id);
    if (!torneo) {
      return res.status(404).json({ msg: 'Torneo no encontrado' });
    }

    // Verificar que el organizador sea el dueño
    if (torneo.organizador.toString() !== req.user.id) {
      return res.status(401).json({ msg: 'No autorizado' });
    }

    // No se puede suspender si ya está cancelado o finalizado
    if (['cancelado', 'finalizado'].includes(torneo.estado)) {
      return res.status(400).json({ msg: 'No se puede suspender un torneo cancelado o finalizado' });
    }

    torneo.estado = 'suspendido';
    await torneo.save();

    res.json({ msg: 'Torneo suspendido correctamente', torneo });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error en el servidor');
  }
};

/**
 * PUT /api/torneos/:id/cancelar - RF-008: Cancelar torneo
 */
exports.cancelarTorneo = async (req, res) => {
  try {
    const torneo = await Torneo.findById(req.params.id);
    if (!torneo) {
      return res.status(404).json({ msg: 'Torneo no encontrado' });
    }

    // Verificar que el organizador sea el dueño
    if (torneo.organizador.toString() !== req.user.id) {
      return res.status(401).json({ msg: 'No autorizado' });
    }

    // No se puede cancelar si ya está finalizado
    if (torneo.estado === 'finalizado') {
      return res.status(400).json({ msg: 'No se puede cancelar un torneo finalizado' });
    }

    torneo.estado = 'cancelado';
    await torneo.save();

    res.json({ msg: 'Torneo cancelado correctamente', torneo });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error en el servidor');
  }
};