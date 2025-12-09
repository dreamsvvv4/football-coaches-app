import React from 'react';

interface Match {
  id: number;
  teamA: string;
  teamB: string;
  scoreA: number;
  scoreB: number;
}

interface BracketViewerProps {
  matches: Match[];
}

const BracketViewer: React.FC<BracketViewerProps> = ({ matches }) => {
  return (
    <div className="bracket-viewer">
      {matches.map((match) => (
        <div key={match.id} className="match">
          <div className="team">{match.teamA}</div>
          <div className="score">{match.scoreA} - {match.scoreB}</div>
          <div className="team">{match.teamB}</div>
        </div>
      ))}
    </div>
  );
};

export default BracketViewer;