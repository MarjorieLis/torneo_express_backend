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

/**
 * ✅ Método de instancia: agregarJugadores
 * Agrega jugadores al equipo sin duplicados
 */
equipoSchema.methods.agregarJugadores = function(jugadorIds) {
  // Filtrar duplicados
  const nuevosJugadores = jugadorIds.filter(id => 
    !this.jugadorIds.includes(id)
  );
  this.jugadorIds = [...this.jugadorIds, ...nuevosJugadores];
  return this.save(); // Devuelve una promesa
};

/**
 * ✅ Método de instancia: removerJugador
 * Remueve un jugador del equipo
 */
equipoSchema.methods.removerJugador = function(jugadorId) {
  this.jugadorIds = this.jugadorIds.filter(id => id.toString() !== jugadorId.toString());
  return this.save();
};

/**
 * ✅ Método de instancia: actualizarEstado
 * Cambia el estado del equipo
 */
equipoSchema.methods.actualizarEstado = function(nuevoEstado) {
  if (!['pendiente', 'aprobado', 'rechazado'].includes(nuevoEstado)) {
    throw new Error('Estado no válido');
  }
  this.estado = nuevoEstado;
  return this.save();
};

// Exportar el modelo
module.exports = mongoose.model('Equipo', equipoSchema);