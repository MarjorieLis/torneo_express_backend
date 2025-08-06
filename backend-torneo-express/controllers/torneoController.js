const mongoose = require('mongoose');
const Torneo = require('../models/Torneo');
const Partido = require('../models/Partido');

// ✅ Verifica que los modelos se importen correctamente
console.log('Torneo model loaded:', Torneo ? '✅' : '❌');
console.log('Partido model loaded:', Partido ? '✅' : '❌');

// Crear nuevo torneo
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

    const inicio = new Date(fechaInicio);
    const fin = new Date(fechaFin);
    if (inicio >= fin) {
      return res.status(400).json({
        success: false,
        message: 'La fecha de inicio debe ser anterior a la de fin'
      });
    }

    const nuevoTorneo = new Torneo({
      nombre,
      disciplina,
      fechaInicio: inicio,
      fechaFin: fin,
      maxEquipos,
      reglas,
      formato,
      creador: req.user.id
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

// ✅ Obtener torneo por ID (arreglo agregado)
exports.obtenerTorneo = async (req, res) => {
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
        message: 'No tienes permiso para ver este torneo'
      });
    }

    res.json({
      success: true,
      torneo
    });
  } catch (err) {
    console.error('❌ Error al obtener torneo:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error al obtener torneo'
    });
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

// Suspender torneo (RF-007)
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

    if (torneo.estado === 'cancelado') {
      return res.status(400).json({
        success: false,
        message: 'No se puede suspender un torneo cancelado'
      });
    }

    torneo.estado = 'suspendido';
    await torneo.save();

    res.json({
      success: true,
      message: 'Torneo suspendido correctamente',
      torneo
    });
  } catch (err) {
    console.error('❌ Error al suspender torneo:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};

// Cancelar torneo (RF-008)
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

    if (torneo.estado === 'finalizado' || torneo.estado === 'cancelado') {
      return res.status(400).json({
        success: false,
        message: 'Este torneo ya está cancelado o finalizado'
      });
    }

    torneo.estado = 'cancelado';
    await torneo.save();

    res.json({
      success: true,
      message: 'Torneo cancelado correctamente',
      torneo
    });
  } catch (err) {
    console.error('❌ Error al cancelar torneo:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};

// ✅ Nueva función: Programar partidos (RF-004)
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
      partidosCreados = await generarCalendarioAutomatico(torneo, torneo.equipos);
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

// ✅ Lógica de generación automática
const generarCalendarioAutomatico = async (torneo, equipos) => {
  const partidos = [];
  const dias = Math.ceil(equipos.length * (equipos.length - 1) / 2 / 3);
  let fecha = new Date(torneo.fechaInicio);
  let index = 0;

  for (let i = 0; i < equipos.length; i++) {
    for (let j = i + 1; j < equipos.length; j++) {
      const dia = Math.floor(index / 3);
      const hora = (index % 3) * 2 + 18;

      const partido = new Partido({
        torneoId: torneo._id,
        equipoLocal: equipos[i],
        equipoVisitante: equipos[j],
        fecha: new Date(fecha.getTime() + dia * 24 * 60 * 60 * 0),
        hora: { hour: hora, minute: 0 },
        lugar: `Cancha ${index % 3 + 1}`,
        estado: 'programado',
      });

      await partido.save();
      partidos.push(partido);
      index++;
    }
  }

  return partidos;
};

// controllers/torneoController.js

// RF-013: Obtener torneos disponibles para jugadores
exports.obtenerTorneosDisponibles = async (req, res) => {
  try {
    // Buscar torneos activos (no suspendidos ni cancelados)
    const torneos = await Torneo.find({
      estado: { $in: ['activo', 'en curso'] }
    })
    .select('nombre disciplina fechaInicio fechaFin maxEquipos reglas formato estado equipos creador')
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
        equipos: torneo.equipos,
        creador: torneo.creador
      }))
    });
  } catch (err) {
    console.error('Error al obtener torneos disponibles:', err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};
