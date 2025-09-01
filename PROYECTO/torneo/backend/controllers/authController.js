// backend/controllers/authController.js
const User = require('../models/User');
const Equipo = require('../models/Equipo');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

/**
 * RF-014: Registro de Usuarios con Información Personal Detallada
 */
exports.register = async (req, res) => {
  const { name, email, password, role, position, jerseyNumber, cedula } = req.body;

  // Validar dominio @uide.edu.ec
  if (!email.endsWith('@uide.edu.ec')) {
    return res.status(400).json({ msg: 'Solo se permiten correos institucionales (@uide.edu.ec)' });
  }

  try {
    // Verificar si el usuario ya existe
    let user = await User.findOne({ email });
    if (user) {
      return res.status(400).json({ msg: 'El usuario ya existe' });
    }

    // ✅ Validación manual de cédula para jugadores
    if (role === 'jugador') {
      if (!cedula || cedula.trim().length < 5) {
        return res.status(400).json({ 
          msg: 'La identificación es obligatoria para jugadores y debe tener al menos 5 caracteres' 
        });
      }
    }

    // Crear nuevo usuario
    user = new User({
      name,
      email,
      password,
      role: role || 'jugador',
      position,
      jerseyNumber,
      cedula: role === 'jugador' ? cedula : undefined
    });

    // Encriptar contraseña
    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(password, salt);

    // Guardar en la base de datos
    await user.save();

    // ✅ Buscar equipo donde el jugador sea capitán o esté en jugadores
    let equipo = await Equipo.findOne({
      $or: [
        { 'capitán.cedula': user.cedula },
        { 'jugadores.cedula': user.cedula }
      ]
    }).select('_id nombre');

    // Generar token JWT
    const payload = { 
      user: { 
        id: user.id, 
        role: user.role,
        ...(equipo && { equipoId: equipo._id }) // ✅ Solo si tiene equipo
      } 
    };

    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: '7d' },
      (err, token) => {
        if (err) {
          console.error('Error al generar el token:', err);
          return res.status(500).json({ msg: 'Error al generar el token' });
        }

        res.status(201).json({
          token,
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
            position: user.position,
            jerseyNumber: user.jerseyNumber,
            cedula: user.cedula,
            profilePhoto: user.profilePhoto,
            ...(equipo && { equipoId: equipo._id.toString() }) // ✅ Enviar al frontend
          },
        });
      }
    );
  } catch (err) {
    console.error('Error en el servidor:', err.message);
    res.status(500).json({ msg: 'Error en el servidor' });
  }
};

/**
 * RF-014: Inicio de sesión
 */
exports.login = async (req, res) => {
  const { email, password } = req.body;

  // Validar dominio @uide.edu.ec
  if (!email.endsWith('@uide.edu.ec')) {
    return res.status(400).json({ msg: 'Correo institucional requerido' });
  }

  try {
    // Verificar si el usuario existe
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ msg: 'Credenciales inválidas' });
    }

    // Verificar contraseña
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ msg: 'Credenciales inválidas' });
    }

    // ✅ Buscar equipo donde el jugador sea capitán o esté en jugadores
    let equipo = await Equipo.findOne({
      $or: [
        { 'capitán.cedula': user.cedula },
        { 'jugadores.cedula': user.cedula }
      ]
    }).select('_id nombre');

    // Generar token JWT
    const payload = { 
      user: { 
        id: user.id, 
        role: user.role,
        ...(equipo && { equipoId: equipo._id }) // ✅ Solo si tiene equipo
      } 
    };

    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: '7d' },
      (err, token) => {
        if (err) {
          console.error('Error al generar el token:', err);
          return res.status(500).json({ msg: 'Error al generar el token' });
        }

        res.json({
          token,
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
            position: user.position,
            jerseyNumber: user.jerseyNumber,
            cedula: user.cedula,
            profilePhoto: user.profilePhoto,
            ...(equipo && { equipoId: equipo._id.toString() }) // ✅ Enviar al frontend
          },
        });
      }
    );
  } catch (err) {
    console.error('Error en el servidor:', err.message);
    res.status(500).json({ msg: 'Error en el servidor' });
  }
};