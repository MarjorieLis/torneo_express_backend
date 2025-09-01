// backend/models/Partido.js
const mongoose = require('mongoose');

const partidoSchema = new mongoose.Schema({
  torneo: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Torneo',
    required: true
  },
  equipoLocal: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Equipo',
    required: true
  },
  equipoVisitante: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Equipo',
    required: true
  },
  fecha: {
    type: Date,
    required: true
  },
  hora: {
    type: String,
    required: true
  },
  lugar: {
    type: String,
    required: true,
    default: 'Cancha Principal'
  },
  estado: {
    type: String,
    enum: ['programado', 'jugado', 'suspendido'],
    default: 'programado'
  },
  ronda: {
    type: Number
  }
}, { timestamps: true });

module.exports = mongoose.model('Partido', partidoSchema);