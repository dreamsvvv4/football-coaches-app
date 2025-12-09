import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || 'http://localhost:5000/api';

export const fetchClubs = async () => {
    try {
        const response = await axios.get(`${API_BASE_URL}/clubs`);
        return response.data;
    } catch (error) {
        throw new Error('Error fetching clubs: ' + error.message);
    }
};

export const fetchTeams = async (clubId) => {
    try {
        const response = await axios.get(`${API_BASE_URL}/clubs/${clubId}/teams`);
        return response.data;
    } catch (error) {
        throw new Error('Error fetching teams: ' + error.message);
    }
};

export const fetchTournaments = async () => {
    try {
        const response = await axios.get(`${API_BASE_URL}/tournaments`);
        return response.data;
    } catch (error) {
        throw new Error('Error fetching tournaments: ' + error.message);
    }
};

export const createClub = async (clubData) => {
    try {
        const response = await axios.post(`${API_BASE_URL}/clubs`, clubData);
        return response.data;
    } catch (error) {
        throw new Error('Error creating club: ' + error.message);
    }
};

export const updateClub = async (clubId, clubData) => {
    try {
        const response = await axios.put(`${API_BASE_URL}/clubs/${clubId}`, clubData);
        return response.data;
    } catch (error) {
        throw new Error('Error updating club: ' + error.message);
    }
};

export const deleteClub = async (clubId) => {
    try {
        await axios.delete(`${API_BASE_URL}/clubs/${clubId}`);
    } catch (error) {
        throw new Error('Error deleting club: ' + error.message);
    }
};