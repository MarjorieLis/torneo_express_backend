// controllers/authController.js
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

/**
 * Registro de usuario
 */
exports.register = async (req, res) => {
  const { nombre, email, password, rol, jugadorInfo } = req.body;

  try {
    // Verificar si el usuario ya existe
    let user = await User.findOne({ email });
    if (user) {
      return res.status(400).json({
        success: false,
        message: 'Ya existe un usuario con este correo'
      });
    }

    // Validar correo institucional para organizadores
    if (rol === 'organizador' && !email.endsWith('@uide.edu.ec')) {
      return res.status(400).json({
        success: false,
        message: 'Los organizadores deben usar correo @uide.edu.ec'
      });
    }

    // Crear nuevo usuario
    user = new User({ 
      nombre, 
      email, 
      password, 
      rol 
    });

    // ✅ Añadir información del jugador solo si el rol es 'jugador'
    if (rol === 'jugador' && jugadorInfo) {
      user.jugadorInfo = {
        cedula: jugadorInfo.cedula,
        edad: jugadorInfo.edad,
        posicionPrincipal: jugadorInfo.posicionPrincipal,
        posicionSecundaria: jugadorInfo.posicionSecundaria,
        numeroCamiseta: jugadorInfo.numeroCamiseta || null,
        genero: jugadorInfo.genero || 'masculino',
        telefono: jugadorInfo.telefono || ''
      };
    }

    // Hashear contraseña
    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(password, salt);

    // Guardar en base de datos
    await user.save();

    // Generar token JWT
    const payload = { user: { id: user.id } };
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '7d' });

    // Respuesta exitosa
    res.status(201).json({
      success: true,
      message: `${rol.charAt(0).toUpperCase() + rol.slice(1)} registrado correctamente`,
      token,
      usuario: {
        id: user.id,
        nombre: user.nombre,
        email: user.email,
        rol: user.rol,
        campus: user.campus,
        jugadorInfo: user.jugadorInfo // ✅ Enviar al frontend
      }
    });

  } catch (err) {
    console.error(err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};

/**
 * Inicio de sesión
 */
exports.login = async (req, res) => {
  const { email, password } = req.body;

  try {
    // Verificar si el usuario existe
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({
        success: false,
        message: 'Credenciales incorrectas'
      });
    }

    // Verificar contraseña
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({
        success: false,
        message: 'Credenciales incorrectas'
      });
    }

    // Generar token JWT
    const payload = { user: { id: user.id } };
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '7d' });

    // Respuesta exitosa
    res.json({
      success: true,
      token,
      usuario: {
        id: user.id,
        nombre: user.nombre,
        email: user.email,
        rol: user.rol,
        campus: user.campus,
        jugadorInfo: user.jugadorInfo // ✅ Incluir en el login
      }
    });

  } catch (err) {
    console.error(err.message);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
};