// backend/routes/equipos.js
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Equipo = require('../models/Equipo');
const Torneo = require('../models/Torneo');

// Reglas por disciplina
const reglasDisciplina = {
  'fútbol': { min: 11, max: 18 },
  'baloncesto': { min: 5, max: 12 },
  'voleibol': { min: 6, max: 12 },
  'tenis': { min: 1, max: 2 }
  // 'atletismo' removido si no se usa
};

/**
 * POST /api/equipos - RF-002: Registrar equipo
 */
router.post('/', auth, async (req, res) => {
  const { nombre, disciplina, torneoId, capitan, jugadores } = req.body;

  try {
    // Validar disciplina
    if (!reglasDisciplina[disciplina]) {
      return res.status(400).json({ msg: 'Disciplina no válida' });
    }

    const { min, max } = reglasDisciplina[disciplina];

    // Total de jugadores (incluido capitán)
    const totalJugadores = 1 + (Array.isArray(jugadores) ? jugadores.length : 0);

    if (totalJugadores < min) {
      return res.status(400).json({ 
        msg: `Se requieren al menos ${min} jugadores para ${disciplina}` 
      });
    }

    if (totalJugadores > max) {
      return res.status(400).json({ 
        msg: `Máximo permitido: ${max} jugadores para ${disciplina}` 
      });
    }

    // Verificar si ya existe un equipo con ese nombre en el torneo
    const equipoExistente = await Equipo.findOne({ nombre, torneoId });
    if (equipoExistente) {
      return res.status(400).json({ msg: 'Ya existe un equipo con ese nombre' });
    }

    // Obtener todos los equipos del torneo (excepto este)
    const otrosEquipos = await Equipo.find({ torneoId });
    const cedulasExistentes = new Set();

    otrosEquipos.forEach(equipo => {
      if (equipo.capitan?.cedulaCapitan) {
        cedulasExistentes.add(equipo.capitan.cedulaCapitan);
      }
      if (Array.isArray(equipo.jugadores)) {
        equipo.jugadores.forEach(j => {
          const match = j.match(/\(([^)]+)\)/);
          if (match) cedulasExistentes.add(match[1]);
        });
      }
    });

    // Validar que el capitán no esté ya inscrito
    if (capitan?.cedulaCapitan && cedulasExistentes.has(capitan.cedulaCapitan)) {
      return res.status(400).json({ 
        msg: `El capitán con cédula ${capitan.cedulaCapitan} ya está inscrito en otro equipo` 
      });
    }

    // Crear nuevo equipo
    const nuevoEquipo = new Equipo({
      nombre,
      disciplina,
      torneoId,
      capitan,
      jugadores,
      estado: 'pendiente'
    });

    await nuevoEquipo.save();
    res.status(201).json(nuevoEquipo);
  } catch (err) {
    console.error('❌ Error en POST /api/equipos:', err.message);
    res.status(500).send('Error en el servidor');
  }
});

// ✅ Exportar el router
module.exports = router;