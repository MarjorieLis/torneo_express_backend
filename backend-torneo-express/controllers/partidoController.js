const Partido = require('../models/Partido');
const Torneo = require('../models/Torneo');

// RF-004: Programar partidos (manual o automático)
exports.programarPartidos = async (req, res) => {
  const { torneoId, modo, partidos: partidosData } = req.body;

  try {
    // ✅ 1. Validar que el torneo exista
    const torneo = await Torneo.findById(torneoId);
    if (!torneo) {
      return res.status(404).json({
        success: false,
        message: 'Torneo no encontrado'
      });
    }

    // ✅ 2. Verificar que el usuario sea el creador
    if (torneo.creador.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'No tienes permiso para programar partidos en este torneo'
      });
    }

    // ✅ 3. Validar que haya equipos inscritos
    if (!torneo.equipos || torneo.equipos.length < 2) {
      return res.status(400).json({
        success: false,
        message: 'No hay suficientes equipos inscritos para programar partidos'
      });
    }

    let partidosCreados = [];

    if (modo === 'automatica') {
      // Generar calendario sin conflictos
      partidosCreados = await generarCalendarioAutomatico(torneo);
    } else {
      // Validar y guardar manual
      for (let p of partidosData) {
        // ✅ Validación de campos obligatorios
        if (!p.equipoLocal || !p.equipoVisitante || !p.fecha || !p.hora || !p.lugar) {
          return res.status(400).json({
            success: false,
            message: 'Todos los campos (equipos, fecha, hora, lugar) son obligatorios en modo manual'
          });
        }

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
      message: 'Error en el servidor al programar partidos'
    });
  }
};

// ✅ Lógica de generación automática
const generarCalendarioAutomatico = async (torneo) => {
  const equipos = torneo.equipos.filter(e => e); // Asegura que no haya valores nulos
  const partidos = [];
  const MS_POR_DIA = 24 * 60 * 60 * 1000; // ✅ 1 día en milisegundos
  let index = 0;

  // Fecha inicial del torneo
  let fecha = new Date(torneo.fechaInicio);

  // Generar partidos: todos contra todos
  for (let i = 0; i < equipos.length; i++) {
    for (let j = i + 1; j < equipos.length; j++) {
      const dia = Math.floor(index / 3); // 3 partidos por día
      const hora = (index % 3) * 2 + 18; // 18, 20, 22

      const fechaPartido = new Date(fecha.getTime() + dia * MS_POR_DIA);

      const partido = new Partido({
        torneoId: torneo._id,
        equipoLocal: equipos[i],
        equipoVisitante: equipos[j],
        fecha: fechaPartido,
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