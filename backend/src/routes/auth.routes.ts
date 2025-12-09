import { Router } from 'express';
import { register, login, logout } from '../controllers/auth.controller';
import { validateRegister, validateLogin } from '../middlewares/validate.middleware';

const router = Router();

// Register route
router.post('/register', validateRegister, register);

// Login route
router.post('/login', validateLogin, login);

// Logout route
router.post('/logout', logout);

export default router;