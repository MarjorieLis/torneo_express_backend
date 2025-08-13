// controllers/notificacionController.js
const Notificacion = require('../models/Notificacion');

exports.crearNotificacion = async (usuarioId, mensaje) => {
  try {
    await Notificacion.create({
      usuarioId,
      mensaje,
      leida: false
    });
  } catch (err) {
    console.error('❌ Error al crear notificación:', err.message);
  }
};