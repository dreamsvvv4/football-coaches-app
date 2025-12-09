import React, { useEffect, useState } from 'react';
import { ClubCard } from '../components/ClubCard';
import { fetchClubs } from '../services/adminApi';

const Clubs = () => {
    const [clubs, setClubs] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const loadClubs = async () => {
            try {
                const data = await fetchClubs();
                setClubs(data);
            } catch (err) {
                setError(err.message);
            } finally {
                setLoading(false);
            }
        };

        loadClubs();
    }, []);

    if (loading) {
        return <div>Loading clubs...</div>;
    }

    if (error) {
        return <div>Error loading clubs: {error}</div>;
    }

    return (
        <div>
            <h1>Clubs Management</h1>
            <div className="club-list">
                {clubs.map(club => (
                    <ClubCard key={club.id} club={club} />
                ))}
            </div>
        </div>
    );
};

export default Clubs;