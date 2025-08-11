// controllers/equipoController.js
const Equipo = require('../models/Equipo');

/**
 * Crear un nuevo equipo
 */
exports.crearEquipo = async (req, res) => {
  try {
    const { nombre, torneoId, capitanId, capitanNombre, capitanTelefono, jugadorIds } = req.body;

    // Validar campos obligatorios
    if (!nombre || !torneoId || !capitanId || !capitanNombre || !jugadorIds || jugadorIds.length < 2) {
      return res.status(400).json({
        success: false,
        message: 'Faltan campos requeridos o cantidad mínima de jugadores'
      });
    }

    const equipo = new Equipo({
      nombre,
      torneoId,
      capitanId,
      capitanNombre,
      capitanTelefono,
      jugadorIds
    });

    await equipo.save();

    res.status(201).json({
      success: true,
      equipo: {
        id: equipo._id,
        nombre: equipo.nombre,
        capitanNombre: equipo.capitanNombre,
        jugadorIds: equipo.jugadorIds
      }
    });
  } catch (err) {
    console.error('❌ Error al crear equipo:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};