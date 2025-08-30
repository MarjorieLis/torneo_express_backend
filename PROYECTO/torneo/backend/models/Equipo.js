// backend/models/Equipo.js
const mongoose = require('mongoose');

const equipoSchema = new mongoose.Schema({
  nombre: {
    type: String,
    required: true,
    trim: true
  },
  disciplina: {
    type: String,
    required: true,
    enum: ['fútbol', 'baloncesto', 'voleibol', 'tenis']
  },
  capitán: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  jugadores: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    }
  ],
  cedulaCapitan: {
    type: String,
    required: true
  },
  estado: {
    type: String,
    default: 'pendiente',
    enum: ['pendiente', 'aprobado', 'rechazado']
  },
  torneo: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Torneo'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Equipo', equipoSchema);