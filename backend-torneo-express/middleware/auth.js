// middlewares/auth.js
const jwt = require('jsonwebtoken');
require('dotenv').config();

const auth = (req, res, next) => {
  // 1. Obtener el token del header
  const token = req.header('x-auth-token');
  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'No hay token, autorización denegada',
    });
  }

  // 2. Verificar el token
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    console.log('✅ Token decodificado:', decoded);

    // Asignar usuario a req.usuario
    req.usuario = decoded.user ? decoded.user : { id: decoded.id, rol: decoded.rol };
    next();
  } catch (err) {
    console.error('❌ Token no válido o expirado:', err.message);
    return res.status(400).json({
      success: false,
      message: 'Token no válido o ha expirado',
    });
  }
};

module.exports = auth;