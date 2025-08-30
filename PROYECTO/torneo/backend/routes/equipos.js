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
  'tenis': { min: 1, max: 2 },
  'atletismo': { min: 1, max: 5 }
};

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

    // Resto de validaciones (duplicados, nombre, etc.)
    const equipoExistente = await Equipo.findOne({ nombre, torneoId });
    if (equipoExistente) {
      return res.status(400).json({ msg: 'Ya existe un equipo con ese nombre' });
    }

    // Validación de jugadores duplicados (como antes)
    const otrosEquipos = await Equipo.find({ torneoId, _id: { $ne: equipoId } });
    const cedulasExistentes = new Set();
    otrosEquipos.forEach(e => {
      if (e.capitan?.cedula) cedulasExistentes.add(e.capitan.cedula);
      if (Array.isArray(e.jugadores)) {
        e.jugadores.forEach(j => {
          const match = j.match(/\(([^)]+)\)/);
          if (match) cedulasExistentes.add(match[1]);
        });
      }
    });

    if (capitan?.cedula && cedulasExistentes.has(capitan.cedula)) {
      return res.status(400).json({ 
        msg: `El jugador con cédula ${capitan.cedula} ya está inscrito` 
      });
    }

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
    console.error(err.message);
    res.status(500).send('Error en el servidor');
  }
});