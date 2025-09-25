const express = require('express');
const jwt = require('jsonwebtoken');
const { User } = require('../models');
const { authLimiter } = require('../middleware/rateLimiter');

const router = express.Router();

// Generate JWT token
const generateToken = (userId) => {
  return jwt.sign(
    { userId },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRE || '7d' }
  );
};

// Register new user
router.post('/register', authLimiter, async (req, res) => {
  try {
    const { username, email, password, firstName, lastName } = req.body;

    // Basic validation
    if (!username || !email || !password) {
      return res.status(400).json({
        error: 'Username, email, and password are required.'
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        error: 'Password must be at least 6 characters long.'
      });
    }

    // Check if user already exists
    const existingUser = await User.findByEmailOrUsername(email);
    if (existingUser) {
      return res.status(409).json({
        error: 'User with this email or username already exists.'
      });
    }

    const existingUsername = await User.findByEmailOrUsername(username);
    if (existingUsername) {
      return res.status(409).json({
        error: 'Username already taken.'
      });
    }

    // Create new user
    const user = await User.create({
      username,
      email,
      password,
      firstName,
      lastName
    });

    // Generate token
    const token = generateToken(user.id);

    res.status(201).json({
      message: 'User registered successfully.',
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        createdAt: user.createdAt
      }
    });
  } catch (error) {
    console.error('Register error:', error);
    
    if (error.name === 'SequelizeValidationError') {
      return res.status(400).json({
        error: error.errors.map(err => err.message).join(', ')
      });
    }
    
    if (error.name === 'SequelizeUniqueConstraintError') {
      return res.status(409).json({
        error: 'Email or username already exists.'
      });
    }

    res.status(500).json({
      error: 'Internal server error during registration.'
    });
  }
});

// Login user
router.post('/login', authLimiter, async (req, res) => {
  try {
    const { identifier, password } = req.body;

    // Basic validation
    if (!identifier || !password) {
      return res.status(400).json({
        error: 'Email/username and password are required.'
      });
    }

    // Find user by email or username
    const user = await User.findByEmailOrUsername(identifier);
    if (!user) {
      return res.status(401).json({
        error: 'Invalid credentials.'
      });
    }

    // Validate password
    const isValidPassword = await user.validatePassword(password);
    if (!isValidPassword) {
      return res.status(401).json({
        error: 'Invalid credentials.'
      });
    }

    // Generate token
    const token = generateToken(user.id);

    res.json({
      message: 'Login successful.',
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        createdAt: user.createdAt
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      error: 'Internal server error during login.'
    });
  }
});

module.exports = router;