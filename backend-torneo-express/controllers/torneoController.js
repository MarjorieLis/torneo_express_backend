// controllers/torneoController.js
const mongoose = require('mongoose');
const Torneo = require('../models/Torneo');
const Partido = require('../models/Partido');
const Jugador = require('../models/Jugador');
const Equipo = require('../models/Equipo');

// ✅ Verifica que los modelos se importen correctamente
console.log('Torneo model loaded:', Torneo ? '✅' : '❌');
console.log('Partido model loaded:', Partido ? '✅' : '❌');

/**
 * Crear nuevo torneo
 */
exports.crearTorneo = async (req, res) => {
  const { nombre, disciplina, fechaInicio, fechaFin, maxEquipos, reglas, formato } = req.body;
  try {
    const existe = await Torneo.findOne({ nombre });
    if (existe) {
      return res.status(400).json({
        success: false,
        message: 'Ya existe un torneo con ese nombre'
      });
    }

    const torneo = new Torneo({
      nombre,
      disciplina,
      fechaInicio,
      fechaFin,
      maxEquipos,
      reglas,
      formato,
      creador: req.user.id
    });

    await torneo.save();
    res.status(201).json({ success: true, torneo });
  } catch (err) {
    console.error('❌ Error al crear torneo:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};

/**
 * Obtener todos los torneos (solo id y nombre para dropdown)
 */
exports.obtenerTorneos = async (req, res) => {
  try {
    const torneos = await Torneo.find()
      .select('_id nombre') // ✅ Solo devuelve id y nombre
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      torneos: torneos.map(t => ({
        id: t._id,
        nombre: t.nombre
      }))
    });
  } catch (err) {
    console.error('❌ Error al obtener torneos:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};

/**
 * Obtener un torneo por ID
 */
exports.obtenerTorneo = async (req, res) => {
  try {
    const torneo = await Torneo.findById(req.params.id);
    if (!torneo) {
      return res.status(404).json({
        success: false,
        message: 'Torneo no encontrado'
      });
    }
    res.json({ success: true, torneo });
  } catch (err) {
    console.error('❌ Error al obtener torneo:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};

/**
 * Editar torneo
 */
exports.editarTorneo = async (req, res) => {
  try {
    const torneo = await Torneo.findById(req.params.id);
    if (!torneo) {
      return res.status(404).json({
        success: false,
        message: 'Torneo no encontrado'
      });
    }

    if (torneo.creador.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'No tienes permiso para editar este torneo'
      });
    }

    Object.assign(torneo, req.body);
    await torneo.save();

    res.json({ success: true, torneo });
  } catch (err) {
    console.error('❌ Error al editar torneo:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};

/**
 * Suspender torneo
 */
exports.suspenderTorneo = async (req, res) => {
  try {
    const torneo = await Torneo.findById(req.params.id);
    if (!torneo) {
      return res.status(404).json({
        success: false,
        message: 'Torneo no encontrado'
      });
    }

    if (torneo.creador.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'No tienes permiso para suspender este torneo'
      });
    }

    torneo.estado = 'suspendido';
    await torneo.save();

    res.json({ success: true, torneo });
  } catch (err) {
    console.error('❌ Error al suspender torneo:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};

/**
 * Cancelar torneo
 */
exports.cancelarTorneo = async (req, res) => {
  try {
    const torneo = await Torneo.findById(req.params.id);
    if (!torneo) {
      return res.status(404).json({
        success: false,
        message: 'Torneo no encontrado'
      });
    }

    if (torneo.creador.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'No tienes permiso para cancelar este torneo'
      });
    }

    torneo.estado = 'cancelado';
    await torneo.save();

    res.json({ success: true, torneo });
  } catch (err) {
    console.error('❌ Error al cancelar torneo:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};

/**
 * Programar partidos
 */
exports.programarPartidos = async (req, res) => {
  const { torneoId, modo, partidos } = req.body;
  try {
    const torneo = await Torneo.findById(torneoId);
    if (!torneo) {
      return res.status(404).json({
        success: false,
        message: 'Torneo no encontrado'
      });
    }

    if (torneo.creador.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'No tienes permiso para programar partidos en este torneo'
      });
    }

    let partidosCreados = [];
    if (modo === 'automatica') {
      const equipos = torneo.equipos;
      for (let i = 0; i < equipos.length; i++) {
        for (let j = i + 1; j < equipos.length; j++) {
          const partido = new Partido({
            torneoId,
            equipoLocal: equipos[i],
            equipoVisitante: equipos[j],
            fecha: new Date(),
            hora: '10:00',
            lugar: 'Cancha Principal',
            estado: 'programado'
          });
          await partido.save();
          partidosCreados.push(partido);
        }
      }
    } else {
      for (let p of partidos) {
        const partido = new Partido({
          torneoId,
          equipoLocal: p.equipoLocal,
          equipoVisitante: p.equipoVisitante,
          fecha: p.fecha,
          hora: p.hora,
          lugar: p.lugar,
          estado: 'programado',
        });
        await partido.save();
        partidosCreados.push(partido);
      }
    }

    res.json({
      success: true,
      partidos: partidosCreados,
      message: `Partidos ${modo === 'automatica' ? 'generados automáticamente' : 'programados manualmente'}`,
    });
  } catch (err) {
    console.error('❌ Error al programar partidos:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error al programar partidos'
    });
  }
};

/**
 * ✅ Obtener torneos disponibles para inscripción (jugadores)
 */
exports.obtenerTorneosDisponibles = async (req, res) => {
  try {
    const torneos = await Torneo.find({
      estado: 'activo'
    })
    .select('nombre disciplina fechaInicio fechaFin maxEquipos reglas formato estado equipos')
    .sort({ createdAt: -1 });

    res.json({
      success: true,
      torneos: torneos.map(torneo => ({
        id: torneo._id,
        nombre: torneo.nombre,
        disciplina: torneo.disciplina,
        fechaInicio: torneo.fechaInicio,
        fechaFin: torneo.fechaFin,
        maxEquipos: torneo.maxEquipos,
        reglas: torneo.reglas,
        formato: torneo.formato,
        estado: torneo.estado,
        equipos: torneo.equipos.map(e => e.toString())
      }))
    });
  } catch (err) {
    console.error('❌ Error al obtener torneos disponibles:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};

/**
 * ✅ Crear equipo (inscripción)
 */
exports.crearEquipo = async (req, res) => {
  const { nombre, torneoId, capitánId, jugadorIds } = req.body;

  try {
    const torneo = await Torneo.findById(torneoId);
    if (!torneo || torneo.estado !== 'activo') {
      return res.status(400).json({
        success: false,
        message: 'Torneo no válido o no activo'
      });
    }

    const capitán = await Jugador.findById(capitánId);
    if (!capitán || capitán.equipoId) {
      return res.status(400).json({
        success: false,
        message: 'El capitán no puede estar en otro equipo'
      });
    }

    const jugadores = await Jugador.find({ _id: { $in: jugadorIds } });
    const jugadoresEnEquipo = jugadores.filter(j => j.equipoId);
    if (jugadoresEnEquipo.length > 0) {
      const nombres = jugadoresEnEquipo.map(j => j.nombre_completo).join(', ');
      return res.status(400).json({
        success: false,
        message: `Los siguientes jugadores ya pertenecen a un equipo: ${nombres}`
      });
    }

    const equipo = new Equipo({
      nombre,
      torneoId,
      capitánId,
      jugadorIds
    });

    await equipo.save();

    await Jugador.updateMany(
      { _id: { $in: [...jugadorIds, capitánId] } },
      { $set: { equipoId: equipo._id } }
    );

    torneo.equipos.push(equipo._id);
    await torneo.save();

    res.status(201).json({
      success: true,
      message: 'Equipo creado e inscrito correctamente',
      equipo: {
        id: equipo._id,
        nombre: equipo.nombre,
        capitánId: equipo.capitánId,
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