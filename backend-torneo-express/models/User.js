// models/User.js
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  nombre: { 
    type: String, 
    required: true 
  },
  email: { 
    type: String, 
    required: true, 
    unique: true,
    lowercase: true
  },
  password: { 
    type: String, 
    required: true,
    minlength: 6
  },
  rol: { 
    type: String, 
    enum: ['organizador', 'jugador'], 
    default: 'jugador' 
  },
  campus: { 
    type: String, 
    default: 'UIDE' 
  },
  // ✅ Información adicional para jugadores
  jugadorInfo: {
    edad: { type: Number },
    posicionPrincipal: { type: String },
    posicionSecundaria: { type: String },
    numeroCamiseta: { type: Number },
    genero: { type: String, enum: ['masculino', 'femenino'] },
    telefono: { type: String }
  },
  createdAt: { 
    type: Date, 
    default: Date.now 
  }
});

module.exports = mongoose.model('User', userSchema);