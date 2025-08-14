// controllers/partidoController.js
const Partido = require('../models/Partido');
const Torneo = require('../models/Torneo');
const Equipo = require('../models/Equipo');

/**
 * Programar un partido
 */
exports.programarPartido = async (req, res) => {
  try {
    const { tipoProgramacion, torneoId } = req.body;

    // ✅ Validar que torneoId sea un ObjectId válido
    if (!/^[0-9a-fA-F]{24}$/.test(torneoId)) {
      return res.status(400).json({
        success: false,
        message: 'ID de torneo inválido'
      });
    }

    const torneo = await Torneo.findById(torneoId);
    if (!torneo) {
      return res.status(400).json({
        success: false,
        message: 'Torneo no encontrado'
      });
    }

    if (tipoProgramacion === 'automatica') {
      const partidosGenerados = await generarPartidosAutomaticos(torneo);

      if (!partidosGenerados || partidosGenerados.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'No se pudieron generar partidos automáticos'
        });
      }

      const partidosGuardados = await Partido.insertMany(partidosGenerados);

      return res.json({
        success: true,
        message: 'Partidos programados automáticamente',
        partidos: partidosGuardados.map(p => p.toJSON())
      });
    } else {
      const { fecha, hora, lugar, equipoLocalId, equipoVisitanteId, capitanId, titulares, suplentes } = req.body;

      // ✅ Validar IDs de equipos
      if (!/^[0-9a-fA-F]{24}$/.test(equipoLocalId) || !/^[0-9a-fA-F]{24}$/.test(equipoVisitanteId)) {
        return res.status(400).json({
          success: false,
          message: 'ID(s) de equipo(s) inválido(s)'
        });
      }

      const equipoLocal = await Equipo.findById(equipoLocalId);
      const equipoVisitante = await Equipo.findById(equipoVisitanteId);

      if (!equipoLocal || !equipoVisitante) {
        return res.status(400).json({
          success: false,
          message: 'Equipo(s) no encontrado(s)'
        });
      }

      const partido = new Partido({
        tipoProgramacion,
        fecha,
        hora,
        lugar,
        equipoLocal: equipoLocalId,
        equipoVisitante: equipoVisitanteId,
        capitan: capitanId,
        titulares,
        suplentes
      });

      await partido.save();

      return res.json({
        success: true,
        message: 'Partido programado exitosamente',
        partido: partido.toJSON()
      });
    }
  } catch (err) {
    console.error('❌ Error al programar partido:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};

/**
 * Generar partidos automáticamente
 */
async function generarPartidosAutomaticos(torneo) {
  try {
    const equipos = await Equipo.find({ torneoId: torneo._id });

    if (!equipos || equipos.length < 2) {
      throw new Error('Se necesitan al menos 2 equipos para generar partidos');
    }

    const partidos = [];

    for (let i = 0; i < equipos.length; i++) {
      for (let j = i + 1; j < equipos.length; j++) {
        partidos.push({
          tipoProgramacion: 'automatica',
          equipoLocal: equipos[i]._id.toString(),
          equipoVisitante: equipos[j]._id.toString(),
          lugar: torneo.lugar || 'Sin lugar',
          fecha: torneo.fechaInicio,
          hora: '14:00',
        });
      }
    }

    return partidos;
  } catch (err) {
    console.error('❌ Error al generar partidos automáticos:', err.message);
    throw err;
  }
}

/**
 * Obtener partidos por torneo
 */
exports.obtenerPartidosPorTorneo = async (req, res) => {
  try {
    const { torneoId } = req.params;

    if (!/^[0-9a-fA-F]{24}$/.test(torneoId)) {
      return res.status(400).json({
        success: false,
        message: 'ID de torneo inválido'
      });
    }

    const partidos = await Partido.find({ torneoId })
      .populate('equipoLocal', 'nombre')
      .populate('equipoVisitante', 'nombre')
      .sort({ fecha: 1 });

    res.json({
      success: true,
      partidos: partidos.map(p => ({
        id: p._id,
        equipoLocal: p.equipoLocal.nombre,
        equipoVisitante: p.equipoVisitante.nombre,
        fecha: p.fecha,
        hora: p.hora,
        lugar: p.lugar,
        estado: p.estado,
      }))
    });
  } catch (err) {
    console.error('❌ Error al obtener partidos por torneo:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};