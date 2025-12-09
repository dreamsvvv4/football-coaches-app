import { Router } from 'express';
import { 
    createClub, 
    getClubs, 
    getClubById, 
    updateClub, 
    deleteClub 
} from '../controllers/clubs.controller';

const router = Router();

// Route to create a new club
router.post('/', createClub);

// Route to get all clubs
router.get('/', getClubs);

// Route to get a club by ID
router.get('/:id', getClubById);

// Route to update a club
router.put('/:id', updateClub);

// Route to delete a club
router.delete('/:id', deleteClub);

export default router;