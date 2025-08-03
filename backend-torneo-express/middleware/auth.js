// middleware/auth.js
const jwt = require('jsonwebtoken');

const auth = async (req, res, next) => {
  // 1. Obtener el token del header
  const token = req.header('x-auth-token');
  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'No hay token, autorización denegada'
    });
  }

  // 2. Verificar el token
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // ✅ Asegúrate de que `decoded` tenga la estructura correcta
    console.log('Token decodificado:', decoded); // 🔍 Depuración

    req.user = decoded.user; // ← Debe ser { id: '60b8d2d8e4b0e45c1c9d8e2a' }
    next();
  } catch (err) {
    console.error('❌ Token no válido:', err.message);
    return res.status(400).json({
      success: false,
      message: 'Token no válido'
    });
  }
};

module.exports = auth;