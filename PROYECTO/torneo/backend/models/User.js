// backend/models/User.js
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { type: String, enum: ['jugador', 'organizador'], default: 'jugador' },
  position: { type: String },
  jerseyNumber: { type: Number },
  phone: { type: String },
  profilePhoto: { type: String },
  socialLinks: [{ type: String }],
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
  // 👇 Cédula: no obligatoria aquí, validaremos en el controlador
  cedula: {
    type: String,
    validate: {
      validator: function(v) {
        return !v || v.trim().length >= 5;
      },
      message: 'La identificación debe tener al menos 5 caracteres.'
    }
  }
});

module.exports = mongoose.model('User', userSchema);