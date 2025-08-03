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
