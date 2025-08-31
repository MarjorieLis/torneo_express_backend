// backend/models/Torneo.js
const mongoose = require('mongoose');

const torneoSchema = new mongoose.Schema({
  nombre: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  disciplina: {
    type: String,
    required: true,
    enum: ['fútbol', 'baloncesto', 'voleibol', 'tenis']
  },
  categoria: {
    type: String,
    required: true,
    enum: ['masculino', 'femenino', 'mixto'],
    default: 'mixto'
  },
  fechaInicio: {
    type: Date,
    required: true
  },
  fechaFin: {
    type: Date,
    required: true
  },
  maxEquipos: {
    type: Number,
    required: true,
    min: 2
  },
  minJugadores: {
    type: Number,
    required: true,
    min: 1
  },
  maxJugadores: {
    type: Number,
    required: true,
    min: 2
  },
  reglas: {
    type: String,
    required: true
  },
  formato: {
    type: String,
    required: true,
    enum: ['grupos', 'eliminación directa', 'mixto']
  },
  estado: {
    type: String,
    default: 'activo',
    enum: ['activo', 'suspendido', 'cancelado', 'finalizado']
  },
  organizador: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  equipos: [
    {
      equipoId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Equipo'
      },
      grupo: String
    }
  ],
  partidos: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Partido'
    }
  ],
  visibilidad: {
    type: String,
    default: 'pública'
  },
  equiposRegistrados: { 
    type: Number,
    default: 0
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Torneo', torneoSchema);