// models/Equipo.js
const mongoose = require('mongoose');

const equipoSchema = new mongoose.Schema({
  nombre: { 
    type: String, 
    required: true, 
    trim: true 
  },
  torneoId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Torneo', 
    required: true 
  },
  capitanId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
    required: true 
  },
  capitanNombre: { 
    type: String, 
    required: true, 
    trim: true 
  },
  capitanTelefono: { 
    type: String, 
    required: true, 
    trim: true 
  },
  jugadorIds: [{ 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User' 
  }],
  estado: { 
    type: String, 
    enum: ['pendiente', 'aprobado', 'rechazado'], 
    default: 'pendiente' 
  },
  fechaRegistro: { 
    type: Date, 
    default: Date.now 
  }
});

module.exports = mongoose.model('Equipo', equipoSchema);