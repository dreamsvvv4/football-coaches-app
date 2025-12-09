import { Request, Response } from 'express';
import { Club } from '../models/club.model';

// Get all clubs
export const getAllClubs = async (req: Request, res: Response) => {
    try {
        const clubs = await Club.find();
        res.status(200).json(clubs);
    } catch (error) {
        res.status(500).json({ message: 'Error retrieving clubs', error });
    }
};

// Get a club by ID
export const getClubById = async (req: Request, res: Response) => {
    const { id } = req.params;
    try {
        const club = await Club.findById(id);
        if (!club) {
            return res.status(404).json({ message: 'Club not found' });
        }
        res.status(200).json(club);
    } catch (error) {
        res.status(500).json({ message: 'Error retrieving club', error });
    }
};

// Create a new club
export const createClub = async (req: Request, res: Response) => {
    const newClub = new Club(req.body);
    try {
        const savedClub = await newClub.save();
        res.status(201).json(savedClub);
    } catch (error) {
        res.status(400).json({ message: 'Error creating club', error });
    }
};

// Update a club
export const updateClub = async (req: Request, res: Response) => {
    const { id } = req.params;
    try {
        const updatedClub = await Club.findByIdAndUpdate(id, req.body, { new: true });
        if (!updatedClub) {
            return res.status(404).json({ message: 'Club not found' });
        }
        res.status(200).json(updatedClub);
    } catch (error) {
        res.status(400).json({ message: 'Error updating club', error });
    }
};

// Delete a club
export const deleteClub = async (req: Request, res: Response) => {
    const { id } = req.params;
    try {
        const deletedClub = await Club.findByIdAndDelete(id);
        if (!deletedClub) {
            return res.status(404).json({ message: 'Club not found' });
        }
        res.status(200).json({ message: 'Club deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting club', error });
    }
};