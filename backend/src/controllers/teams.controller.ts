import { Request, Response } from 'express';
import { Team } from '../models/team.model';

// Get all teams
export const getAllTeams = async (req: Request, res: Response) => {
    try {
        const teams = await Team.find();
        res.status(200).json(teams);
    } catch (error) {
        res.status(500).json({ message: 'Error retrieving teams', error });
    }
};

// Get a team by ID
export const getTeamById = async (req: Request, res: Response) => {
    const { id } = req.params;
    try {
        const team = await Team.findById(id);
        if (!team) {
            return res.status(404).json({ message: 'Team not found' });
        }
        res.status(200).json(team);
    } catch (error) {
        res.status(500).json({ message: 'Error retrieving team', error });
    }
};

// Create a new team
export const createTeam = async (req: Request, res: Response) => {
    const newTeam = new Team(req.body);
    try {
        const savedTeam = await newTeam.save();
        res.status(201).json(savedTeam);
    } catch (error) {
        res.status(400).json({ message: 'Error creating team', error });
    }
};

// Update a team
export const updateTeam = async (req: Request, res: Response) => {
    const { id } = req.params;
    try {
        const updatedTeam = await Team.findByIdAndUpdate(id, req.body, { new: true });
        if (!updatedTeam) {
            return res.status(404).json({ message: 'Team not found' });
        }
        res.status(200).json(updatedTeam);
    } catch (error) {
        res.status(400).json({ message: 'Error updating team', error });
    }
};

// Delete a team
export const deleteTeam = async (req: Request, res: Response) => {
    const { id } = req.params;
    try {
        const deletedTeam = await Team.findByIdAndDelete(id);
        if (!deletedTeam) {
            return res.status(404).json({ message: 'Team not found' });
        }
        res.status(200).json({ message: 'Team deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting team', error });
    }
};