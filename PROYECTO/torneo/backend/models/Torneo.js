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
    enum: ['Futbol', 'Baloncesto', 'Voleibol', 'Tenis']
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
  reglas: {
    type: String,
    required: true
  },
  formato: {
    type: String,
    required: true,
    enum: ['Grupos', 'Eliminación directa']
  },
  estado: {
    type: String,
    default: 'activo',
    enum: ['Activo', 'Suspendido', 'Cancelado', 'Finalizado']
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
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Torneo', torneoSchema);