import { Router } from 'express';
import { createUser, getUser, updateUser, deleteUser } from '../controllers/users.controller';
import { validateUser } from '../middlewares/validate.middleware';
import { authenticate } from '../middlewares/auth.middleware';
import { authorize } from '../middlewares/roles.middleware';

const router = Router();

// Routes for user management
router.post('/', authenticate, authorize(['Superadmin', 'ClubAdmin']), validateUser, createUser);
router.get('/:id', authenticate, authorize(['Superadmin', 'ClubAdmin', 'Coach']), getUser);
router.put('/:id', authenticate, authorize(['Superadmin', 'ClubAdmin']), validateUser, updateUser);
router.delete('/:id', authenticate, authorize(['Superadmin', 'ClubAdmin']), deleteUser);

export default router;