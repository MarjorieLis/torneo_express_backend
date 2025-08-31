// backend/routes/equipos.js
const express = require('express');
const router = express.Router();

// ✅ Importa los modelos
const Equipo = require('../models/Equipo');
const Torneo = require('../models/Torneo');

/**
 * POST /api/equipos - RF-002: Registrar equipo
 */
router.post('/', async (req, res) => {
  const { nombre, disciplina, capitán, cedulaCapitan, jugadores, torneoId } = req.body;

  try {
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

    // ✅ Incrementar equiposRegistrados
    if (torneoId) {
      await Torneo.findByIdAndUpdate(torneoId, {
        $inc: { equiposRegistrados: 1 }
      });
    }

    res.status(201).json({
      msg: 'Equipo registrado, pendiente de aprobación',
      equipo: nuevoEquipo
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error en el servidor');
  }
});

/**
 * GET /api/equipos - Listar todos los equipos
 */
router.get('/', async (req, res) => {
  try {
    const equipos = await Equipo.find().populate('torneo', 'nombre');
    res.json({ equipos });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error en el servidor');
  }
});

/**
 * PUT /api/equipos/:id/aprobar - RF-002: Aprobar equipo
 */
router.put('/:id/aprobar', async (req, res) => {
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

    res.json({ msg: 'Equipo aprobado', equipo });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error en el servidor');
  }
});

/**
 * PUT /api/equipos/:id/rechazar - RF-002: Rechazar equipo
 */
router.put('/:id/rechazar', async (req, res) => {
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

    res.json({ msg: 'Equipo rechazado', equipo });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error en el servidor');
  }
});

/**
 * GET /api/equipos/jugador/:cedula/torneos
 * Obtener torneos en los que está inscrito un jugador (por cédula)
 */
router.get('/jugador/:cedula/torneos', async (req, res) => {
  try {
    const { cedula } = req.params;
    console.log('🔍 Buscando torneos para jugador con cédula:', cedula);

    // Busca equipos donde el jugador sea capitán o esté en la lista
    const equipos = await Equipo.find({
      $or: [
        { 'capitán.cedula': cedula },
        { 'jugadores.cedula': cedula }
      ],
      estado: 'aprobado'
    }).populate('torneo', 'nombre disciplina categoria estado fechaInicio fechaFin maxEquipos equiposRegistrados');

    if (!equipos || equipos.length === 0) {
      return res.status(404).json({
        msg: 'No estás inscrito en ningún torneo'
      });
    }

    // Extrae torneos únicos
    const torneosMap = new Map();
    equipos.forEach(eq => {
      if (eq.torneo) {
        torneosMap.set(eq.torneo._id.toString(), {
          ...eq.torneo._doc,
          equipo: { nombre: eq.nombre, estado: eq.estado }
        });
      }
    });

    const torneos = Array.from(torneosMap.values());
    console.log('✅ Torneos encontrados:', torneos.length);
    res.json({ torneos });
  } catch (err) {
    console.error('❌ Error en GET /equipos/jugador/:cedula/torneos:', err.message);
    res.status(500).send('Error interno del servidor. Inténtalo más tarde.');
  }
});

module.exports = router;