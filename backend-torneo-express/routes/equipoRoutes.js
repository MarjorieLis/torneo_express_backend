// routes/equipoRoutes.js
const express = require('express');
const router = express.Router();

// ✅ Importa todo el controlador
const equipoController = require('../controllers/equipoController');
const auth = require('../middleware/auth');

router.post('/', auth, equipoController.crearEquipo);
router.get('/pendientes', auth, equipoController.obtenerEquiposPendientes);
router.put('/aprobado/:id', auth, equipoController.aprobarEquipo);
router.put('/rechazado/:id', auth, equipoController.rechazarEquipo);

// ✅ Nueva ruta: obtener equipos aprobados
router.get('/aprobados', auth, equipoController.obtenerEquiposAprobados);

module.exports = router;