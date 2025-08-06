// controllers/jugadorController.js
const Jugador = require('../models/Jugador');

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

    const jugador = await Jugador.findOne({
      $or: [
        { 'datosPersonales.cedula': query },
        { email: query }
      ]
    }).select('nombre_completo email posicion_principal posicion_secundaria numero_camiseta equipoId');

    if (!jugador) {
      return res.status(404).json({
        success: false,
        message: 'Jugador no encontrado'
      });
    }

    res.json({
      success: true,
      jugador: {
        id: jugador._id,
        nombre_completo: jugador.nombre_completo,
        email: jugador.email,
        posicion_principal: jugador.posicion_principal,
        posicion_secundaria: jugador.posicion_secundaria,
        numero_camiseta: jugador.numero_camiseta,
        equipoId: jugador.equipoId ? jugador.equipoId.toString() : null
      }
    });
  } catch (err) {
    console.error('❌ Error al buscar jugador:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }

  exports.obtenerJugadoresDisponibles = async (req, res) => {
  try {
    const jugadores = await Jugador.find({ equipoId: null })
      .select('nombre_completo posicion_principal posicion_secundaria numero_camiseta')
      .limit(50);

    res.json({
      success: true,
      jugadores: jugadores.map(j => ({
        id: j._id,
        nombre_completo: j.nombre_completo,
        posicion_principal: j.posicion_principal,
        posicion_secundaria: j.posicion_secundaria,
        numero_camiseta: j.numero_camiseta,
        equipoId: j.equipoId ? j.equipoId.toString() : null
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
};