const Torneo = require('../models/Torneo');

exports.crearTorneo = async (req, res) => {
  const { nombre, disciplina, fechaInicio, fechaFin, maxEquipos, reglas, formato } = req.body;

  try {
    // Validar que el nombre no se repita
    const existe = await Torneo.findOne({ nombre });
    if (existe) {
      return res.status(400).json({
        success: false,
        message: 'Ya existe un torneo con ese nombre'
      });
    }

    // Validar fechas
    const inicio = new Date(fechaInicio);
    const fin = new Date(fechaFin);
    if (inicio >= fin) {
      return res.status(400).json({
        success: false,
        message: 'La fecha de inicio debe ser anterior a la de fin'
      });
    }

    // Crear nuevo torneo con creador (desde req.user.id)
    const nuevoTorneo = new Torneo({
      nombre,
      disciplina,
      fechaInicio: inicio,
      fechaFin: fin,
      maxEquipos,
      reglas,
      formato,
      creador: req.user.id // debe venir del middleware
    });

    await nuevoTorneo.save();

    res.status(201).json({
      success: true,
      torneo: nuevoTorneo
    });

  } catch (err) {
    console.error(err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};

// ✅ NUEVA FUNCIÓN: Obtener todos los torneos del organizador autenticado
exports.obtenerTorneos = async (req, res) => {
  try {
    // Buscar solo los torneos donde el campo 'creador' coincida con el ID del usuario autenticado
    const torneos = await Torneo.find({ creador: req.user.id }).sort({ createdAt: -1 });

    res.json({
      success: true,
      torneos: torneos
    });
  } catch (err) {
    console.error('Error al obtener torneos:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};

exports.suspenderTorneo = async (req, res) => {
  try {
    const torneo = await Torneo.findById(req.params.id);
    if (!torneo) {
      return res.status(404).json({ message: 'Torneo no encontrado' });
    }

    torneo.estado = 'suspendido';
    await torneo.save();

    res.json({
      success: true,
      message: 'Torneo suspendido correctamente',
      torneo
    });
  } catch (err) {
    res.status(500).json({ message: 'Error al suspender torneo' });
  }
};

exports.cancelarTorneo = async (req, res) => {
  try {
    const torneo = await Torneo.findById(req.params.id);
    if (!torneo) {
      return res.status(404).json({ message: 'Torneo no encontrado' });
    }

    torneo.estado = 'cancelado';
    await torneo.save();

    res.json({
      success: true,
      message: 'Torneo cancelado correctamente',
      torneo
    });
  } catch (err) {
    res.status(500).json({ message: 'Error al cancelar torneo' });
  }
};