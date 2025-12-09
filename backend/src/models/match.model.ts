export interface Match {
    id: string;
    homeTeamId: string;
    awayTeamId: string;
    date: Date;
    time: string;
    location: string;
    score: {
        home: number;
        away: number;
    };
    events: MatchEvent[];
}

export interface MatchEvent {
    type: 'goal' | 'card' | 'substitution' | 'injury';
    playerId: string;
    teamId: string;
    minute: number;
    details?: string; // Additional details about the event
}