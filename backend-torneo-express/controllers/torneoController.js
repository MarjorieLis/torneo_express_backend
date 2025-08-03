const Torneo = require('../models/Torneo');

// Crear nuevo torneo
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

    // Crear nuevo torneo
    const nuevoTorneo = new Torneo({
      nombre,
      disciplina,
      fechaInicio: inicio,
      fechaFin: fin,
      maxEquipos,
      reglas,
      formato,
      creador: req.user.id // viene del middleware de autenticación
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

// Obtener torneos del organizador autenticado
exports.obtenerTorneos = async (req, res) => {
  try {
    const torneos = await Torneo.find({ creador: req.user.id }).sort({ createdAt: -1 });

    res.json({
      success: true,
      torneos
    });
  } catch (err) {
    console.error('Error al obtener torneos:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};

// Suspender torneo
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
    console.error(err.message);
    res.status(500).json({ message: 'Error al suspender torneo' });
  }
};

// Cancelar torneo
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
    console.error(err.message);
    res.status(500).json({ message: 'Error al cancelar torneo' });
  }
};

// Editar torneo (RF-006)
exports.editarTorneo = async (req, res) => {
  const { nombre, disciplina, fechaInicio, fechaFin, maxEquipos, reglas, formato } = req.body;

  try {
    let torneo = await Torneo.findById(req.params.id);
    if (!torneo) {
      return res.status(404).json({ message: 'Torneo no encontrado' });
    }

    // Verificar que el usuario actual sea el creador
    if (torneo.creador.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'No tienes permiso para editar este torneo'
      });
    }

    const hoy = new Date();
    if (new Date(torneo.fechaInicio) < hoy) {
      return res.status(400).json({
        success: false,
        message: 'No se puede editar el nombre o fechas de un torneo ya iniciado'
      });
    }

    // Actualizar campos permitidos
    torneo.nombre = nombre;
    torneo.disciplina = disciplina;
    torneo.fechaInicio = new Date(fechaInicio);
    torneo.fechaFin = new Date(fechaFin);
    torneo.maxEquipos = maxEquipos;
    torneo.reglas = reglas;
    torneo.formato = formato;

    await torneo.save();

    res.json({
      success: true,
      message: 'Torneo actualizado correctamente',
      torneo
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({
      success: false,
      message: 'Error al editar torneo'
    });
  }
};
