// controllers/equipoController.js
const Equipo = require('../models/Equipo');

/**
 * Crear un nuevo equipo
 */
exports.crearEquipo = async (req, res) => {
  try {
    const { nombre, torneoId, capitanId, capitanNombre, capitanTelefono, jugadorIds } = req.body;

    if (!nombre || !torneoId || !capitanId || !capitanNombre || !capitanTelefono || !jugadorIds || jugadorIds.length < 2) {
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
      jugadorIds,
      estado: 'pendiente',
      fechaRegistro: new Date()
    });

    await equipo.save();

    res.status(201).json({
      success: true,
      equipo: {
        id: equipo._id,
        nombre: equipo.nombre,
        capitanNombre: equipo.capitanNombre,
        estado: equipo.estado
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

/**
 * Obtener equipos pendientes de aprobación
 */
exports.obtenerEquiposPendientes = async (req, res) => {
  try {
    console.log('✅ [obtenerEquiposPendientes] Buscando equipos con estado "pendiente"...');

    const equipos = await Equipo.find({ estado: 'pendiente' })
      .select('nombre capitanNombre estado fechaRegistro');

    console.log(`✅ [obtenerEquiposPendientes] Encontrados ${equipos.length} equipos`);

    res.json({
      success: true,
      equipos: equipos.map(e => ({
        id: e._id,
        nombre: e.nombre,
        capitanNombre: e.capitanNombre,
        estado: e.estado,
        fechaRegistro: e.fechaRegistro
      }))
    });
  } catch (err) {
    console.error('❌ [obtenerEquiposPendientes] Error:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};