// models/Torneo.js
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
    enum: ['Fútbol', 'Baloncesto', 'Voleibol']
  },
  fechaInicio: { type: Date, required: true },
  fechaFin: { type: Date, required: true },
  maxEquipos: { type: Number, required: true },
  reglas: { type: String },
  formato: { 
    type: String, 
    enum: ['grupos', 'eliminacion', 'mixto'], 
    required: true 
  },
  estado: { 
    type: String, 
    enum: ['activo', 'suspendido', 'cancelado', 'finalizado'], 
    default: 'activo' 
  },
  equipos: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Equipo' }],
  partidos: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Partido' }],
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Torneo', torneoSchema);