import React from 'react';
import { Link } from 'react-router-dom';
import { ClubCard } from '../components/ClubCard';
import { BracketViewer } from '../components/BracketViewer';

const Dashboard: React.FC = () => {
    return (
        <div className="dashboard">
            <h1>Dashboard</h1>
            <section className="clubs-section">
                <h2>Clubs</h2>
                <div className="club-cards">
                    {/* Example club cards, replace with dynamic data */}
                    <ClubCard clubName="Club A" />
                    <ClubCard clubName="Club B" />
                    <ClubCard clubName="Club C" />
                </div>
            </section>
            <section className="tournaments-section">
                <h2>Tournaments</h2>
                <BracketViewer />
            </section>
            <section className="navigation-section">
                <h2>Quick Links</h2>
                <ul>
                    <li><Link to="/clubs">Manage Clubs</Link></li>
                    <li><Link to="/teams">Manage Teams</Link></li>
                    <li><Link to="/tournaments">Manage Tournaments</Link></li>
                </ul>
            </section>
        </div>
    );
};

export default Dashboard;