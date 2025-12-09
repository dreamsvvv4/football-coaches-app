import React, { useEffect, useState } from 'react';
import { fetchTournaments } from '../services/adminApi';
import BracketViewer from '../components/BracketViewer';

const Tournaments = () => {
    const [tournaments, setTournaments] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const loadTournaments = async () => {
            try {
                const data = await fetchTournaments();
                setTournaments(data);
            } catch (err) {
                setError(err.message);
            } finally {
                setLoading(false);
            }
        };

        loadTournaments();
    }, []);

    if (loading) {
        return <div>Loading tournaments...</div>;
    }

    if (error) {
        return <div>Error loading tournaments: {error}</div>;
    }

    return (
        <div>
            <h1>Tournaments</h1>
            {tournaments.length > 0 ? (
                tournaments.map(tournament => (
                    <BracketViewer key={tournament.id} tournament={tournament} />
                ))
            ) : (
                <div>No tournaments available.</div>
            )}
        </div>
    );
};

export default Tournaments;