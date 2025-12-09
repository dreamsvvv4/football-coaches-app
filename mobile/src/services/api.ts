import axios from 'axios';

const API_BASE_URL = 'https://api.yourfootballapp.com'; // Replace with your actual API base URL

// Set up axios instance
const api = axios.create({
    baseURL: API_BASE_URL,
    timeout: 10000, // Set timeout for requests
});

// Function to get all clubs
export const getClubs = async () => {
    try {
        const response = await api.get('/clubs');
        return response.data;
    } catch (error) {
        throw error;
    }
};

// Function to get a specific club by ID
export const getClubById = async (clubId) => {
    try {
        const response = await api.get(`/clubs/${clubId}`);
        return response.data;
    } catch (error) {
        throw error;
    }
};

// Function to create a new team
export const createTeam = async (teamData) => {
    try {
        const response = await api.post('/teams', teamData);
        return response.data;
    } catch (error) {
        throw error;
    }
};

// Function to get players of a specific team
export const getPlayersByTeamId = async (teamId) => {
    try {
        const response = await api.get(`/teams/${teamId}/players`);
        return response.data;
    } catch (error) {
        throw error;
    }
};

// Function to update match details
export const updateMatch = async (matchId, matchData) => {
    try {
        const response = await api.put(`/matches/${matchId}`, matchData);
        return response.data;
    } catch (error) {
        throw error;
    }
};

// Function to get live match updates
export const getLiveMatchUpdates = async (matchId) => {
    try {
        const response = await api.get(`/matches/${matchId}/live`);
        return response.data;
    } catch (error) {
        throw error;
    }
};