const mongoose = require('mongoose');

const partidoSchema = new mongoose.Schema({
  // Referencia al torneo al que pertenece
  torneoId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Torneo',
    required: true
  },

  // Equipos que juegan
  equipoLocal: {
    type: String,
    required: true
  },
  equipoVisitante: {
    type: String,
    required: true
  },

  // Fecha y hora del partido
  fecha: {
    type: Date,
    required: true
  },
  hora: {
    hour: { type: Number, required: true, min: 0, max: 23 },
    minute: { type: Number, required: true, min: 0, max: 59 }
  },

  // Lugar del partido
  lugar: {
    type: String,
    required: true
  },

  // Estado del partido
  estado: {
    type: String,
    enum: ['programado', 'jugado', 'suspendido', 'cancelado'],
    default: 'programado'
  },

  // Resultado (se llena cuando el partido se juega)
  resultado: {
    golesLocal: { type: Number, default: 0 },
    golesVisitante: { type: Number, default: 0 },
    puntosLocal: { type: Number, default: 0 },
    puntosVisitante: { type: Number, default: 0 }
  },

  // Capitán y jugadores (opcional, para futuras mejoras)
  capitanLocal: { type: String },
  capitanVisitante: { type: String },
  jugadoresLocales: [{ type: String }], // IDs o nombres
  jugadoresVisitantes: [{ type: String }],

  // Fecha de creación
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Partido', partidoSchema);