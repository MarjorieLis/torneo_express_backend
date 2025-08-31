// backend/controllers/equipo.js
const Equipo = require('../models/Equipo');
const Torneo = require('../models/Torneo');

// Reglas por disciplina
const reglasDisciplina = {
  'fútbol': { min: 11, max: 18 },
  'baloncesto': { min: 5, max: 12 },
  'voleibol': { min: 6, max: 12 },
  'tenis': { min: 1, max: 2 }
};

/**
 * POST /api/equipos - RF-002: Registrar equipo
 */
exports.crearEquipo = async (req, res) => {
  const { nombre, disciplina, capitán, cedulaCapitan, jugadores, torneoId } = req.body;

  try {
    // ✅ Validaciones básicas
    if (!nombre || !disciplina || !capitán || !cedulaCapitan) {
      return res.status(400).json({
        msg: 'Todos los campos marcados son obligatorios'
      });
    }

    if (!capitán.nombre || !capitán.cedula) {
      return res.status(400).json({
        msg: 'El capitán debe tener nombre y cédula'
      });
    }

    if (cedulaCapitan !== capitán.cedula) {
      return res.status(400).json({
        msg: 'La cédula del capitán no coincide con la ingresada'
      });
    }

    // ✅ Validar reglas por disciplina
    const reglas = reglasDisciplina[disciplina];
    if (!reglas) {
      return res.status(400).json({ msg: 'Disciplina no válida' });
    }

    const totalJugadores = 1 + (Array.isArray(jugadores) ? jugadores.length : 0);
    if (totalJugadores < reglas.min) {
      return res.status(400).json({
        msg: `Se requieren al menos ${reglas.min} jugadores para ${disciplina}`
      });
    }
    if (totalJugadores > reglas.max) {
      return res.status(400).json({
        msg: `Máximo permitido: ${reglas.max} jugadores para ${disciplina}`
      });
    }

    // ✅ Validar que el capitán esté en la lista de jugadores
    const capitánEnLista = jugadores?.some(j => j.cedula === capitán.cedula);
    if (!capitánEnLista) {
      return res.status(400).json({
        msg: 'El capitán debe estar en la lista de jugadores'
      });
    }

    // ✅ Verificar si ya existe un equipo con ese nombre
    const equipoExistente = await Equipo.findOne({ nombre });
    if (equipoExistente) {
      return res.status(400).json({
        msg: 'Ya existe un equipo con ese nombre'
      });
    }

    // ✅ Verificar si el capitán ya está inscrito en otro equipo
    const capitánInscrito = await Equipo.findOne({
      'capitán.cedula': capitán.cedula,
      estado: 'pendiente'
    });
    if (capitánInscrito) {
      return res.status(400).json({
        msg: `El jugador con cédula ${capitán.cedula} ya está inscrito como capitán en otro equipo`
      });
    }

    // ✅ Verificar si algún jugador ya está inscrito
    if (Array.isArray(jugadores)) {
      for (const jugador of jugadores) {
        if (!jugador.nombre || !jugador.cedula) {
          return res.status(400).json({
            msg: 'Cada jugador debe tener nombre y cédula'
          });
        }

        const jugadorInscrito = await Equipo.findOne({
          'jugadores.cedula': jugador.cedula,
          estado: 'pendiente'
        });
        if (jugadorInscrito) {
          return res.status(400).json({
            msg: `El jugador ${jugador.nombre} (cedula: ${jugador.cedula}) ya está inscrito en otro equipo`
          });
        }
      }
    }

    // ✅ Crear nuevo equipo
    const nuevoEquipo = new Equipo({
      nombre,
      disciplina,
      torneoId,
      capitán,
      cedulaCapitan,
      jugadores: jugadores || [],
      estado: 'pendiente'
    });

    await nuevoEquipo.save();

    res.status(201).json({
      msg: 'Equipo registrado, pendiente de aprobación',
      equipo: nuevoEquipo
    });
  } catch (err) {
    console.error('❌ Error en POST /api/equipos:', err.message);
    res.status(500).send('Error en el servidor');
  }
};

/**
 * GET /api/equipos - Listar equipos para organizador
 */
exports.listarEquipos = async (req, res) => {
  try {
    const equipos = await Equipo.find().sort({ createdAt: -1 }).populate('torneo', 'nombre');
    res.json({ equipos });
  } catch (err) {
    console.error('❌ Error en GET /api/equipos:', err.message);
    res.status(500).send('Error en el servidor');
  }
};

/**
 * PUT /api/equipos/:id/aprobar - RF-002: Aprobar equipo
 */
exports.aprobarEquipo = async (req, res) => {
  try {
    const equipo = await Equipo.findById(req.params.id);
    if (!equipo) {
      return res.status(404).json({ msg: 'Equipo no encontrado' });
    }

    if (equipo.estado !== 'pendiente') {
      return res.status(400).json({ msg: 'Solo se pueden aprobar equipos pendientes' });
    }

    equipo.estado = 'aprobado';
    await equipo.save();

    // Asignar automáticamente al torneo si hay cupo
    const torneo = await Torneo.findOne({ 
      disciplina: equipo.disciplina, 
      estado: 'activo' 
    });

    if (torneo) {
      const equiposAprobados = await Equipo.countDocuments({ 
        torneo: torneo._id, 
        estado: 'aprobado' 
      });

      if (equiposAprobados < torneo.maxEquipos) {
        equipo.torneo = torneo._id;
        await equipo.save();
      }
    }

    res.json({ 
      msg: 'Equipo aprobado y asignado al torneo', 
      equipo 
    });
  } catch (err) {
    console.error('❌ Error en PUT /api/equipos/:id/aprobar:', err.message);
    res.status(500).send('Error en el servidor');
  }
};

/**
 * PUT /api/equipos/:id/rechazar - RF-002: Rechazar equipo
 */
exports.rechazarEquipo = async (req, res) => {
  try {
    const equipo = await Equipo.findById(req.params.id);
    if (!equipo) {
      return res.status(404).json({ msg: 'Equipo no encontrado' });
    }

    if (equipo.estado !== 'pendiente') {
      return res.status(400).json({ msg: 'Solo se pueden rechazar equipos pendientes' });
    }

    equipo.estado = 'rechazado';
    await equipo.save();

    res.json({ 
      msg: 'Equipo rechazado', 
      equipo 
    });
  } catch (err) {
    console.error('❌ Error en PUT /api/equipos/:id/rechazar:', err.message);
    res.status(500).send('Error en el servidor');
  }
};