const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const mongoose = require('mongoose');
const Equipo = require('../models/Equipo');
const Torneo = require('../models/Torneo');

/**
 * POST /api/equipos - RF-002: Registrar equipo
 */
router.post('/', auth, async (req, res) => {
  const { nombre, disciplina, capitán, cedulaCapitan, jugadores, torneoId } = req.body;

  try {
    // ✅ Validar que torneoId sea un ObjectId válido
    if (!mongoose.Types.ObjectId.isValid(torneoId)) {
      return res.status(400).json({ msg: 'ID de torneo inválido' });
    }

    // ✅ Convertir a ObjectId
    const torneoObjectId = new mongoose.Types.ObjectId(torneoId);

    // ✅ Validar nombre único
    const existeEquipo = await Equipo.findOne({ nombre });
    if (existeEquipo) {
      return res.status(400).json({ msg: 'Ya existe un equipo con ese nombre' });
    }

    // ✅ Crear lista de jugadores que incluya al capitán
    let jugadoresConCapitan = [...(jugadores || [])];
    const yaEstaEnLista = jugadoresConCapitan.some(j => j.cedula === cedulaCapitan);
    if (!yaEstaEnLista) {
      jugadoresConCapitan.push({
        nombre: capitán.nombre,
        cedula: cedulaCapitan
      });
    }

    // ✅ Obtener todas las cédulas
    const cedulasNuevas = [
      cedulaCapitan,
      ...jugadoresConCapitan.map(j => j.cedula)
    ].filter(Boolean);

    // ✅ Buscar si alguna cédula ya está en otro equipo
    const equiposExistentes = await Equipo.find({
      torneo: torneoObjectId,
      $or: [
        { 'capitán.cedula': { $in: cedulasNuevas } },
        { 'jugadores.cedula': { $in: cedulasNuevas } }
      ],
      estado: { $in: ['pendiente', 'aprobado'] }
    });

    if (equiposExistentes.length > 0) {
      const nombresDuplicados = [...new Set(
        jugadoresConCapitan
          .filter(j => cedulasNuevas.includes(j.cedula))
          .map(j => j.nombre)
      )];
      return res.status(400).json({
        msg: `Los siguientes jugadores ya están inscritos: ${nombresDuplicados.join(', ')}`
      });
    }

    // ✅ Crear nuevo equipo con torneo como ObjectId
    const nuevoEquipo = new Equipo({
      nombre,
      disciplina,
      torneo: torneoObjectId,
      capitán,
      cedulaCapitan,
      jugadores: jugadoresConCapitan,
      estado: 'pendiente'
    });

    await nuevoEquipo.save();

    // ✅ Incrementar equiposRegistrados
    if (torneoId) {
      await Torneo.findByIdAndUpdate(torneoId, {
        $inc: { equiposRegistrados: 1 }
      }, { new: true });
    }

    res.status(201).json({
      msg: 'Equipo registrado, pendiente de aprobación',
      equipo: nuevoEquipo
    });
  } catch (err) {
    console.error('❌ Error al crear equipo:', err.message);
    res.status(500).send('Error en el servidor');
  }
});

/**
 * PUT /api/equipos/:id/aprobar - RF-002: Aprobar equipo
 */
router.put('/:id/aprobar', auth, async (req, res) => {
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

    // ✅ Incrementar equiposRegistrados
    if (equipo.torneo) {
      await Torneo.findByIdAndUpdate(equipo.torneo, {
        $inc: { equiposRegistrados: 1 }
      }, { new: true });
    }

    res.json({ msg: 'Equipo aprobado', equipo });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error en el servidor');
  }
});

/**
 * PUT /api/equipos/:id/rechazar - RF-002: Rechazar equipo
 */
router.put('/:id/rechazar', auth, async (req, res) => {
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
 * GET /api/equipos - Listar todos los equipos
 */
router.get('/', auth, async (req, res) => {
  try {
    const equipos = await Equipo.find().populate('torneo', 'nombre');
    res.json({ equipos });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error en el servidor');
  }
});

/**
 * GET /api/equipos/jugador/:cedula/torneos
 */
router.get('/jugador/:cedula/torneos', auth, async (req, res) => {
  try {
    const { cedula } = req.params;

    console.log('🔍 Buscando cédula:', cedula);

    // ✅ Búsqueda correcta: en capitán.cedula Y en jugadores.cedula
    const equipos = await Equipo.find({
      $or: [
        { 'capitán.cedula': cedula },
        { 'jugadores.cedula': cedula }
      ],
      estado: { $in: ['pendiente', 'aprobado'] }
    }).populate('torneo', 'nombre disciplina categoria estado fechaInicio fechaFin maxEquipos equiposRegistrados');

    console.log('✅ Equipos encontrados:', equipos);

    if (!equipos || equipos.length === 0) {
      return res.status(404).json({ msg: 'No estás inscrito en ningún torneo' });
    }

    const torneosMap = new Map();
    equipos.forEach(eq => {
      if (eq.torneo) {
        torneosMap.set(eq.torneo._id.toString(), {
          ...eq.torneo._doc,
          equipo: { nombre: eq.nombre, estado: eq.estado }
        });
      }
    });

    res.json({ torneos: Array.from(torneosMap.values()) });
  } catch (err) {
    console.error('❌ Error en /jugador/:cedula/torneos:', err.message);
    res.status(500).send('Error interno del servidor');
  }
});

module.exports = router;