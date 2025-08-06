// models/Equipo.js
const mongoose = require('mongoose');

const equipoSchema = new mongoose.Schema({
  nombre: { type: String, required: true, trim: true },
  torneoId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Torneo', 
    required: true 
  },
  capitanId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Jugador', 
    required: true 
  },
  jugadorIds: [{ 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Jugador' 
  }],
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Equipo', equipoSchema);