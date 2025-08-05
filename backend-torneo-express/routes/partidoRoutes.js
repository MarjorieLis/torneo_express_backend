const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { programarPartidos } = require('../controllers/partidoController');

router.post('/programar', auth, programarPartidos);

module.exports = router;