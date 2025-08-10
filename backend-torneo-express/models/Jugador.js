// models/Jugador.js
const mongoose = require('mongoose');

const jugadorSchema = new mongoose.Schema({
  nombre_completo: { type: String, required: true },
  email: { 
    type: String, 
    required: true, 
    unique: true, 
    lowercase: true,
    index: true
  },
  cedula: { // ✅ Nuevo campo: cédula
    type: String,
    required: true,
    unique: true,
    index: true
  },
  edad: { type: Number, required: true },
  posicion_principal: { type: String, required: true },
  posicion_secundaria: { type: String },
  numero_camiseta: { type: Number },
  genero: { type: String, enum: ['masculino', 'femenino'], default: 'masculino' },
  telefono: { type: String },
  equipoId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Equipo', 
    default: null 
  },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Jugador', jugadorSchema);