import { Request, Response } from 'express';
import { Tournament } from '../models/tournament.model';

// Create a new tournament
export const createTournament = async (req: Request, res: Response) => {
    try {
        const tournamentData = req.body;
        const tournament = await Tournament.create(tournamentData);
        res.status(201).json(tournament);
    } catch (error) {
        res.status(500).json({ message: 'Error creating tournament', error });
    }
};

// Get all tournaments
export const getTournaments = async (req: Request, res: Response) => {
    try {
        const tournaments = await Tournament.find();
        res.status(200).json(tournaments);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching tournaments', error });
    }
};

// Get a tournament by ID
export const getTournamentById = async (req: Request, res: Response) => {
    try {
        const { id } = req.params;
        const tournament = await Tournament.findById(id);
        if (!tournament) {
            return res.status(404).json({ message: 'Tournament not found' });
        }
        res.status(200).json(tournament);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching tournament', error });
    }
};

// Update a tournament
export const updateTournament = async (req: Request, res: Response) => {
    try {
        const { id } = req.params;
        const tournamentData = req.body;
        const tournament = await Tournament.findByIdAndUpdate(id, tournamentData, { new: true });
        if (!tournament) {
            return res.status(404).json({ message: 'Tournament not found' });
        }
        res.status(200).json(tournament);
    } catch (error) {
        res.status(500).json({ message: 'Error updating tournament', error });
    }
};

// Delete a tournament
export const deleteTournament = async (req: Request, res: Response) => {
    try {
        const { id } = req.params;
        const tournament = await Tournament.findByIdAndDelete(id);
        if (!tournament) {
            return res.status(404).json({ message: 'Tournament not found' });
        }
        res.status(204).send();
    } catch (error) {
        res.status(500).json({ message: 'Error deleting tournament', error });
    }
};