// controllers/jugadorController.js

const User = require('../models/User'); // Usa el modelo User (incluye jugadores)

/**
 * Buscar jugador por cédula o correo institucional
 * GET /api/jugadores/buscar?query=123456789
 */
exports.buscarJugadorPorCedulaOCorreo = async (req, res) => {
  try {
    const { query } = req.query;

    // Validar que se haya proporcionado un término de búsqueda
    if (!query || query.trim() === '') {
      return res.status(400).json({
        success: false,
        message: 'Debe proporcionar un término de búsqueda (cédula o correo)'
      });
    }

    // Buscar jugador por cédula o correo
    const user = await User.findOne({
      rol: 'jugador',
      $or: [
        { 'jugadorInfo.cedula': query.trim() }, // Busca por número de cédula
        { email: query.trim() }                // Busca por correo institucional
      ]
    }).select('nombre email jugadorInfo equipoId');

    // Si no se encuentra el jugador
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Jugador no encontrado'
      });
    }

    // Responder con los datos del jugador
    res.json({
      success: true,
      jugador: {
        id: user._id,
        nombre_completo: user.nombre,
        email: user.email,
        cedula: user.jugadorInfo?.cedula || null,
        edad: user.jugadorInfo?.edad || null,
        posicion_principal: user.jugadorInfo?.posicionPrincipal || '',
        posicion_secundaria: user.jugadorInfo?.posicionSecundaria || '',
        numero_camiseta: user.jugadorInfo?.numeroCamiseta || null,
        genero: user.jugadorInfo?.genero || 'masculino',
        telefono: user.jugadorInfo?.telefono || '',
        equipoId: user.equipoId ? user.equipoId.toString() : null
      }
    });

  } catch (err) {
    console.error('❌ Error al buscar jugador:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};

/**
 * ✅ Obtener jugadores disponibles (sin equipo)
 * GET /api/jugadores/disponibles
 */
exports.obtenerJugadoresDisponibles = async (req, res) => {
  try {
    // Buscar jugadores con rol 'jugador' y sin equipo asignado
    const users = await User.find({
      rol: 'jugador',
      equipoId: null
    })
    .select('nombre jugadorInfo')
    .limit(50); // Limitar resultados para mejor rendimiento

    // Mapear a formato limpio para el frontend
    const jugadores = users.map(u => ({
      id: u._id,
      nombre_completo: u.nombre,
      posicion_principal: u.jugadorInfo?.posicionPrincipal || '',
      posicion_secundaria: u.jugadorInfo?.posicionSecundaria || '',
      numero_camiseta: u.jugadorInfo?.numeroCamiseta || null,
      cedula: u.jugadorInfo?.cedula || null,
      email: u.email,
      equipoId: u.equipoId ? u.equipoId.toString() : null
    }));

    res.json({
      success: true,
      jugadores
    });

  } catch (err) {
    console.error('❌ Error al obtener jugadores disponibles:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};