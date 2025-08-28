// backend/routes/auth.js
const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const authController = require('../controllers/authController');

/**
 * POST /api/auth/register
 * RF-014: Registro de Usuarios con Información Personal Detallada
 */
router.post(
  '/register',
  [
    body('name', 'El nombre es obligatorio').not().isEmpty(),
    body('email', 'Debe ser un correo válido').isEmail(),
    body('password', 'La contraseña debe tener al menos 6 caracteres').isLength({ min: 6 }),
    body('role').optional().isIn(['jugador', 'organizador']),
    body('position').optional().isString(),
    body('jerseyNumber').optional().isInt({ min: 1, max: 99 }),
  ],
  authController.register
);

/**
 * POST /api/auth/login
 * RF-014: Inicio de sesión
 */
router.post(
  '/login',
  [
    body('email', 'Debe ser un correo válido').isEmail(),
    body('password', 'La contraseña es obligatoria').exists(),
  ],
  authController.login
);

module.exports = router;