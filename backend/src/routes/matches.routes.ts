import { Router } from 'express';
import { 
    createMatch, 
    getMatchById, 
    updateMatch, 
    deleteMatch, 
    getAllMatches 
} from '../controllers/matches.controller';

const router = Router();

// Route to create a new match
router.post('/', createMatch);

// Route to get all matches
router.get('/', getAllMatches);

// Route to get a match by ID
router.get('/:id', getMatchById);

// Route to update a match
router.put('/:id', updateMatch);

// Route to delete a match
router.delete('/:id', deleteMatch);

export default router;