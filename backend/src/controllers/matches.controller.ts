import { Request, Response } from 'express';
import { Match } from '../models/match.model';

// Create a new match
export const createMatch = async (req: Request, res: Response) => {
    try {
        const matchData = req.body;
        const newMatch = await Match.create(matchData);
        res.status(201).json(newMatch);
    } catch (error) {
        res.status(500).json({ message: 'Error creating match', error });
    }
};

// Get all matches
export const getAllMatches = async (req: Request, res: Response) => {
    try {
        const matches = await Match.find();
        res.status(200).json(matches);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching matches', error });
    }
};

// Get match by ID
export const getMatchById = async (req: Request, res: Response) => {
    try {
        const matchId = req.params.id;
        const match = await Match.findById(matchId);
        if (!match) {
            return res.status(404).json({ message: 'Match not found' });
        }
        res.status(200).json(match);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching match', error });
    }
};

// Update match
export const updateMatch = async (req: Request, res: Response) => {
    try {
        const matchId = req.params.id;
        const updatedMatch = await Match.findByIdAndUpdate(matchId, req.body, { new: true });
        if (!updatedMatch) {
            return res.status(404).json({ message: 'Match not found' });
        }
        res.status(200).json(updatedMatch);
    } catch (error) {
        res.status(500).json({ message: 'Error updating match', error });
    }
};

// Delete match
export const deleteMatch = async (req: Request, res: Response) => {
    try {
        const matchId = req.params.id;
        const deletedMatch = await Match.findByIdAndDelete(matchId);
        if (!deletedMatch) {
            return res.status(404).json({ message: 'Match not found' });
        }
        res.status(204).send();
    } catch (error) {
        res.status(500).json({ message: 'Error deleting match', error });
    }
};