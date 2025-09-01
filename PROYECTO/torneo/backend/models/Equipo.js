// backend/models/Equipo.js
const mongoose = require('mongoose');

const jugadorSchema = new mongoose.Schema({
  nombre: { type: String, required: true },
  cedula: { type: String, required: true }
});

const equipoSchema = new mongoose.Schema({
  nombre: {
    type: String,
    required: true,
    trim: true,
    unique: true
  },
  disciplina: {
    type: String,
    required: true,
    enum: ['fútbol', 'baloncesto', 'voleibol', 'tenis']
  },
  torneo: { // ✅ Cambiado de torneoId a torneo
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Torneo',
    required: true
  },
  capitán: {
    nombre: { type: String, required: true },
    cedula: { type: String, required: true }
  },
  cedulaCapitan: {
    type: String,
    required: true
  },
  jugadores: [jugadorSchema],
  estado: {
    type: String,
    default: 'pendiente',
    enum: ['pendiente', 'aprobado', 'rechazado']
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Equipo', equipoSchema);