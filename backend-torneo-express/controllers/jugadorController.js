// controllers/jugadorController.js
const User = require('../models/User'); // Usa User, no Jugador

/**
 * Buscar jugador por cédula o correo institucional
 */
exports.buscarJugadorPorCedulaOCorreo = async (req, res) => {
  try {
    const { query } = req.query;
    if (!query) {
      return res.status(400).json({
        success: false,
        message: 'Debe proporcionar un término de búsqueda (cédula o correo)'
      });
    }

    // ✅ Busca en jugadorInfo.cedula y en email
    const user = await User.findOne({
      rol: 'jugador',
      $or: [
        { 'jugadorInfo.cedula': query }, // Busca por cédula
        { email: query }               // Busca por correo
      ]
    }).select('nombre email jugadorInfo equipoId');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Jugador no encontrado'
      });
    }

    res.json({
      success: true,
      jugador: {
        id: user._id,
        nombre_completo: user.nombre,
        email: user.email,
        cedula: user.jugadorInfo?.cedula,
        edad: user.jugadorInfo?.edad,
        posicion_principal: user.jugadorInfo?.posicionPrincipal,
        posicion_secundaria: user.jugadorInfo?.posicionSecundaria,
        numero_camiseta: user.jugadorInfo?.numeroCamiseta,
        genero: user.jugadorInfo?.genero,
        telefono: user.jugadorInfo?.telefono,
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
 */
exports.obtenerJugadoresDisponibles = async (req, res) => {
  try {
    const users = await User.find({
      rol: 'jugador',
      'equipoId': null
    })
    .select('nombre jugadorInfo')
    .limit(50);

    res.json({
      success: true,
      jugadores: users.map(u => ({
        id: u._id,
        nombre_completo: u.nombre,
        posicion_principal: u.jugadorInfo?.posicionPrincipal,
        posicion_secundaria: u.jugadorInfo?.posicionSecundaria,
        numero_camiseta: u.jugadorInfo?.numeroCamiseta,
        cedula: u.jugadorInfo?.cedula,
        email: u.email,
        equipoId: u.equipoId ? u.equipoId.toString() : null
      }))
    });
  } catch (err) {
    console.error('❌ Error al obtener jugadores disponibles:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};