import React from 'react';

interface ClubCardProps {
    clubName: string;
    clubLogo: string;
    location: string;
    establishedYear: number;
    onClick: () => void;
}

const ClubCard: React.FC<ClubCardProps> = ({ clubName, clubLogo, location, establishedYear, onClick }) => {
    return (
        <div className="club-card" onClick={onClick}>
            <img src={clubLogo} alt={`${clubName} logo`} className="club-logo" />
            <h3 className="club-name">{clubName}</h3>
            <p className="club-location">{location}</p>
            <p className="club-established">Established: {establishedYear}</p>
        </div>
    );
};

export default ClubCard;