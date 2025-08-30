// backend/controllers/equipo.js
const Equipo = require('../models/Equipo');
const Torneo = require('../models/Torneo');

// POST /api/equipos - RF-002: Registrar equipo
exports.crearEquipo = async (req, res) => {
  const { nombre, disciplina, cedulaCapitan } = req.body;

  try {
    const nuevoEquipo = new Equipo({
      nombre,
      disciplina,
      capitán: req.user.id,
      cedulaCapitan,
      estado: 'pendiente'
    });

    await nuevoEquipo.save();

    res.status(201).json({
      msg: 'Equipo registrado, pendiente de aprobación',
      equipo: nuevoEquipo
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error en el servidor');
  }
};

// GET /api/equipos - Listar equipos para organizador
exports.listarEquipos = async (req, res) => {
  try {
    const equipos = await Equipo.find().populate('capitán', 'name email');
    res.json({  equipos });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error en el servidor');
  }
};

// PUT /api/equipos/:id/aprobar - RF-002: Aprobar equipo
exports.aprobarEquipo = async (req, res) => {
  try {
    const equipo = await Equipo.findById(req.params.id);
    if (!equipo) {
      return res.status(404).json({ msg: 'Equipo no encontrado' });
    }

    equipo.estado = 'aprobado';
    await equipo.save();

    // Asignar automáticamente al torneo si hay cupo
    const torneo = await Torneo.findOne({ disciplina: equipo.disciplina, estado: 'activo' });
    if (torneo) {
      const equiposRegistrados = await Equipo.countDocuments({ torneo: torneo._id, estado: 'aprobado' });
      if (equiposRegistrados < torneo.maxEquipos) {
        equipo.torneo = torneo._id;
        await equipo.save();
      }
    }

    res.json({ msg: 'Equipo aprobado y asignado', equipo });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error en el servidor');
  }
};

// PUT /api/equipos/:id/rechazar - RF-002: Rechazar equipo
exports.rechazarEquipo = async (req, res) => {
  try {
    const equipo = await Equipo.findById(req.params.id);
    if (!equipo) {
      return res.status(404).json({ msg: 'Equipo no encontrado' });
    }

    equipo.estado = 'rechazado';
    await equipo.save();

    res.json({ msg: 'Equipo rechazado', equipo });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error en el servidor');
  }
};