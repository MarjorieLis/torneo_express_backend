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
      .populate('torneoId', 'nombre')
      .populate('capitanId', 'nombre telefono')
      .populate('jugadorIds', 'nombre')
      .select('nombre capitanNombre capitanTelefono torneoId jugadorIds estado fechaRegistro')
      .sort({ fechaRegistro: -1 });

    console.log(`✅ [obtenerEquiposPendientes] Encontrados ${equipos.length} equipos`);

    res.json({
      success: true,
      equipos: equipos.map(e => ({
        id: e._id,
        nombre: e.nombre,
        torneo: {
          id: e.torneoId._id,
          nombre: e.torneoId.nombre
        },
        capitan: {
          nombre: e.capitanNombre,
          telefono: e.capitanTelefono
        },
        jugadores: e.jugadorIds.map(j => ({ nombre: j.nombre })),
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

/**
 * Aprobar un equipo
 */
exports.aprobarEquipo = async (req, res) => {
  try {
    const { id } = req.params;

    console.log(`[aprobarEquipo] Intentando actualizar equipo con ID: ${id}`);

    const equipo = await Equipo.findByIdAndUpdate(
      id,
      { estado: 'aprobado' },
      { new: true }
    );

    console.log(`[aprobarEquipo] Estado actualizado: ${equipo ? equipo.estado : 'No se encontró equipo'}`);

    if (!equipo) {
      return res.status(404).json({
        success: false,
        message: 'Equipo no encontrado'
      });
    }

    res.json({
      success: true,
      message: 'Equipo aprobado exitosamente',
      equipo: {
        id: equipo._id,
        nombre: equipo.nombre,
        estado: equipo.estado
      }
    });
  } catch (err) {
    console.error('❌ Error al aprobar equipo:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};

/**
 * Rechazar equipo
 */
exports.rechazarEquipo = async (req, res) => {
  try {
    const { id } = req.params;

    const equipo = await Equipo.findByIdAndUpdate(
      id,
      { estado: 'rechazado' },
      { new: true }
    );

    if (!equipo) {
      return res.status(404).json({
        success: false,
        message: 'Equipo no encontrado'
      });
    }

    res.json({
      success: true,
      message: 'Equipo rechazado exitosamente'
    });
  } catch (err) {
    console.error('❌ Error al rechazar equipo:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};

/**
 * Obtener equipos aprobados
 */
exports.obtenerEquiposAprobados = async (req, res) => {
  try {
    console.log('✅ [obtenerEquiposAprobados] Buscando equipos con estado "aprobado"...');

    const equipos = await Equipo.find({ estado: 'aprobado' })
      .populate('torneoId', 'nombre')
      .populate('capitanId', 'nombre telefono')
      .populate('jugadorIds', 'nombre')
      .select('nombre capitanNombre capitanTelefono torneoId jugadorIds estado fechaRegistro')
      .sort({ fechaRegistro: -1 });

    console.log(`✅ [obtenerEquiposAprobados] Encontrados ${equipos.length} equipos`);

    res.json({
      success: true,
      equipos: equipos.map(e => ({
        id: e._id,
        nombre: e.nombre,
        torneo: {
          id: e.torneoId._id,
          nombre: e.torneoId.nombre
        },
        capitan: {
          nombre: e.capitanNombre,
          telefono: e.capitanTelefono
        },
        jugadores: e.jugadorIds.map(j => ({ nombre: j.nombre })),
        estado: e.estado,
        fechaRegistro: e.fechaRegistro
      }))
    });
  } catch (err) {
    console.error('❌ [obtenerEquiposAprobados] Error:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};

/**
 * Obtener equipos por torneo
 */
exports.obtenerEquiposPorTorneo = async (req, res) => {
  try {
    const { torneoId } = req.params;

    const equipos = await Equipo.find({ torneoId })
      .select('nombre capitanNombre estado');

    res.json({
      success: true,
      equipos: equipos.map(e => ({
        id: e._id,
        nombre: e.nombre,
        capitanNombre: e.capitanNombre,
        estado: e.estado
      }))
    });
  } catch (err) {
    console.error('❌ Error al obtener equipos por torneo:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};