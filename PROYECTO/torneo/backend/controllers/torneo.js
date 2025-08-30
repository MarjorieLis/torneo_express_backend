// backend/controllers/torneo.js
const Torneo = require('../models/Torneo');

/**
 * POST /api/torneos - RF-001: Crear torneo
 */
exports.crearTorneo = async (req, res) => {
  const {
    nombre,
    disciplina,
    categoria,
    fechaInicio,
    fechaFin,
    maxEquipos,
    minJugadores,
    maxJugadores,
    reglas,
    formato
  } = req.body;

  try {
    // Validación de campos obligatorios
    if (!nombre || !disciplina || !categoria || !fechaInicio || !fechaFin || !maxEquipos || !minJugadores || !maxJugadores || !reglas || !formato) {
      return res.status(400).json({ msg: 'Todos los campos marcados son obligatorios' });
    }

    // Validar categoría
    if (!['masculino', 'femenino', 'mixto'].includes(categoria)) {
      return res.status(400).json({ msg: 'Categoría inválida. Usa: masculino, femenino o mixto' });
    }

    // Verificar si ya existe un torneo con ese nombre
    const torneoExistente = await Torneo.findOne({ nombre });
    if (torneoExistente) {
      return res.status(400).json({
        msg: 'Ya existe un torneo con ese nombre'
      });
    }

    // Validación de fechas
    const nuevaFechaInicio = new Date(fechaInicio);
    const nuevaFechaFin = new Date(fechaFin);

    if (isNaN(nuevaFechaInicio.getTime()) || isNaN(nuevaFechaFin.getTime())) {
      return res.status(400).json({ msg: 'Fechas inválidas' });
    }

    if (nuevaFechaInicio >= nuevaFechaFin) {
      return res.status(400).json({ msg: 'La fecha de inicio debe ser anterior a la de fin' });
    }

    // Verificar solapamiento de fechas
    const torneos = await Torneo.find();
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

    // Validación de jugadores
    if (minJugadores < 1 || maxJugadores < 2 || minJugadores > maxJugadores) {
      return res.status(400).json({ msg: 'Valores de jugadores no válidos' });
    }

    // ✅ Crear nuevo torneo con TODOS los campos
    const nuevoTorneo = new Torneo({
      nombre,
      disciplina,
      categoria, // ✅ Aseguramos que se incluya
      fechaInicio,
      fechaFin,
      maxEquipos,
      minJugadores,
      maxJugadores,
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
    const torneos = await Torneo.find({
      estado: 'activo',
      visibilidad: 'pública'
    })
      .sort({ createdAt: -1 });

    res.json({ torneos });
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

    if (torneo.organizador.toString() !== req.user.id) {
      return res.status(401).json({ msg: 'No autorizado' });
    }

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

    if (torneo.organizador.toString() !== req.user.id) {
      return res.status(401).json({ msg: 'No autorizado' });
    }

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

/**
 * PUT /api/torneos/:id/reanudar - RF-007: Reanudar torneo
 */
exports.reanudarTorneo = async (req, res) => {
  try {
    const torneo = await Torneo.findById(req.params.id);
    if (!torneo) {
      return res.status(404).json({ msg: 'Torneo no encontrado' });
    }

    if (torneo.organizador.toString() !== req.user.id) {
      return res.status(401).json({ msg: 'No autorizado' });
    }

    if (torneo.estado !== 'suspendido') {
      return res.status(400).json({ msg: 'Solo se puede reanudar un torneo suspendido' });
    }

    torneo.estado = 'activo';
    await torneo.save();

    res.json({ msg: 'Torneo reanudado correctamente', torneo });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error en el servidor');
  }
};