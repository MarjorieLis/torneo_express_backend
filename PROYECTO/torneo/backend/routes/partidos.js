// backend/routes/partidos.js
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Torneo = require('../models/Torneo');
const Equipo = require('../models/Equipo');
const Partido = require('../models/Partido');

/**
 * POST /api/partidos/automatico - RF-004: Programar partidos automáticamente
 */
router.post('/automatico', auth, async (req, res) => {
  const { torneoId } = req.body;

  try {
    if (!torneoId) {
      return res.status(400).json({ msg: 'ID del torneo requerido' });
    }

    const torneo = await Torneo.findById(torneoId);
    if (!torneo) {
      return res.status(404).json({ msg: 'Torneo no encontrado' });
    }

    if (torneo.estado !== 'activo') {
      return res.status(400).json({ msg: 'Solo se pueden programar partidos en torneos activos' });
    }

    const equipos = await Equipo.find({
      torneo: torneoId,
      estado: 'aprobado'
    });

    if (equipos.length < 2) {
      return res.status(400).json({ msg: 'Se necesitan al menos 2 equipos aprobados' });
    }

    const partidos = [];
    const fechaInicio = new Date(torneo.fechaInicio);
    let fecha = new Date(fechaInicio);
    let hora = 10;

    if (torneo.formato === 'grupos') {
      for (let i = 0; i < equipos.length; i++) {
        for (let j = i + 1; j < equipos.length; j++) {
          partidos.push({
            torneo: torneoId,
            equipoLocal: equipos[i]._id,
            equipoVisitante: equipos[j]._id,
            fecha: new Date(fecha),
            hora: `${hora}:00`,
            lugar: 'Cancha Principal',
            estado: 'programado'
          });
          hora += 2;
          if (hora >= 18) {
            fecha.setDate(fecha.getDate() + 1);
            hora = 10;
          }
        }
      }
    } else if (torneo.formato === 'eliminación directa') {
      let equiposRonda = [...equipos];
      let ronda = 1;

      while (equiposRonda.length > 1) {
        const partidosRonda = [];
        for (let i = 0; i < equiposRonda.length; i += 2) {
          if (equiposRonda[i + 1]) {
            partidos.push({
              torneo: torneoId,
              equipoLocal: equiposRonda[i]._id,
              equipoVisitante: equiposRonda[i + 1]._id,
              fecha: new Date(fecha),
              hora: `${hora}:00`,
              lugar: 'Cancha Principal',
              estado: 'programado',
              ronda
            });
            partidosRonda.push(equiposRonda[i]);
            hora += 2;
            if (hora >= 18) {
              fecha.setDate(fecha.getDate() + 1);
              hora = 10;
            }
          }
        }
        equiposRonda = partidosRonda;
        ronda++;
      }
    }

    await Partido.insertMany(partidos);

    res.json({
      msg: `✅ Se programaron ${partidos.length} partidos`,
      partidos
    });
  } catch (err) {
    console.error('❌ Error:', err.message);
    res.status(500).send('Error en el servidor');
  }
});

module.exports = router;