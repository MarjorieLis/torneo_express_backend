// controllers/torneoController.js
const Torneo = require('../models/Torneo');

// RF-001: Crear torneo
exports.crearTorneo = async (req, res) => {
  const { nombre, disciplina, fechaInicio, fechaFin, maxEquipos, reglas, formato } = req.body;

  try {
    // Verificar si ya existe un torneo con ese nombre
    const existe = await Torneo.findOne({ nombre });
    if (existe) {
      return res.status(400).json({
        message: 'Ya existe un torneo con ese nombre'
      });
    }

    const nuevoTorneo = new Torneo({
      nombre,
      disciplina,
      fechaInicio,
      fechaFin,
      maxEquipos,
      reglas,
      formato
    });

    await nuevoTorneo.save();
    res.status(201).json(nuevoTorneo);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error en el servidor');
  }
};

// Obtener todos los torneos
exports.obtenerTorneos = async (req, res) => {
  try {
    const torneos = await Torneo.find();
    res.json(torneos);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error al obtener torneos');
  }
};

// Obtener un torneo por ID
exports.obtenerTorneo = async (req, res) => {
  try {
    const torneo = await Torneo.findById(req.params.id);
    if (!torneo) {
      return res.status(404).json({ message: 'Torneo no encontrado' });
    }
    res.json(torneo);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error al obtener torneo');
  }
};

// RF-006: Editar torneo
exports.editarTorneo = async (req, res) => {
  const { nombre, disciplina, fechaInicio, fechaFin, maxEquipos, reglas, formato } = req.body;

  try {
    let torneo = await Torneo.findById(req.params.id);
    if (!torneo) {
      return res.status(404).json({ message: 'Torneo no encontrado' });
    }

    // RF-006: Solo se pueden editar ciertos campos si el torneo ya comenzó
    const hoy = new Date();
    if (new Date(torneo.fechaInicio) < hoy) {
      // Si ya comenzó, no se puede cambiar nombre ni fechas
      return res.status(400).json({
        message: 'No se puede editar el nombre o fechas de un torneo ya iniciado'
      });
    }

    torneo = await Torneo.findByIdAndUpdate(
      req.params.id,
      { nombre, disciplina, fechaInicio, fechaFin, maxEquipos, reglas, formato },
      { new: true }
    );

    res.json(torneo);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error al editar torneo');
  }
};

// RF-007: Suspender torneo
exports.suspenderTorneo = async (req, res) => {
  try {
    const torneo = await Torneo.findById(req.params.id);
    if (!torneo) {
      return res.status(404).json({ message: 'Torneo no encontrado' });
    }

    torneo.estado = 'suspendido';
    await torneo.save();

    res.json({
      message: 'Torneo suspendido correctamente',
      torneo
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error al suspender torneo');
  }
};

// RF-008: Cancelar torneo
exports.cancelarTorneo = async (req, res) => {
  try {
    const torneo = await Torneo.findById(req.params.id);
    if (!torneo) {
      return res.status(404).json({ message: 'Torneo no encontrado' });
    }

    torneo.estado = 'cancelado';
    await torneo.save();

    res.json({
      message: 'Torneo cancelado correctamente',
      torneo
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error al cancelar torneo');
  }
};

// RF-012: Historial de torneos pasados
exports.obtenerHistorial = async (req, res) => {
  try {
    const torneos = await Torneo.find({
      estado: { $in: ['finalizado', 'cancelado'] }
    }).sort({ fechaInicio: -1 });

    res.json(torneos);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error al obtener historial');
  }
};