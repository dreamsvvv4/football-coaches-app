import React, { useEffect, useState } from 'react';
import { fetchTeams } from '../services/adminApi';
import TeamCard from '../components/TeamCard';

const Teams = () => {
    const [teams, setTeams] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const loadTeams = async () => {
            try {
                const data = await fetchTeams();
                setTeams(data);
            } catch (err) {
                setError(err.message);
            } finally {
                setLoading(false);
            }
        };

        loadTeams();
    }, []);

    if (loading) {
        return <div>Loading teams...</div>;
    }

    if (error) {
        return <div>Error loading teams: {error}</div>;
    }

    return (
        <div>
            <h1>Teams Management</h1>
            <div className="team-list">
                {teams.map(team => (
                    <TeamCard key={team.id} team={team} />
                ))}
            </div>
        </div>
    );
};

export default Teams;