export interface User {
    id: string;
    name: string;
    email: string;
    role: UserRole;
    profilePicture?: string;
}

export interface Club {
    id: string;
    name: string;
    location: string;
    teams: Team[];
}

export interface Team {
    id: string;
    name: string;
    category: string;
    players: Player[];
    coach: User;
}

export interface Player {
    id: string;
    name: string;
    age: number;
    position: string;
    jerseyNumber: number;
    medicalNotes?: string;
    statistics: PlayerStatistics;
}

export interface PlayerStatistics {
    matchesPlayed: number;
    goals: number;
    assists: number;
    yellowCards: number;
    redCards: number;
}

export interface Match {
    id: string;
    homeTeam: Team;
    awayTeam: Team;
    date: Date;
    status: MatchStatus;
    events: MatchEvent[];
}

export interface MatchEvent {
    type: EventType;
    player: Player;
    timestamp: Date;
}

export interface Tournament {
    id: string;
    name: string;
    teams: Team[];
    matches: Match[];
    format: TournamentFormat;
}

export enum UserRole {
    Coach = 'COACH',
    Player = 'PLAYER',
    ClubAdmin = 'CLUB_ADMIN',
    Referee = 'REFEREE',
    Fan = 'FAN',
    SuperAdmin = 'SUPER_ADMIN',
}

export enum MatchStatus {
    Scheduled = 'SCHEDULED',
    Ongoing = 'ONGOING',
    Finished = 'FINISHED',
}

export enum EventType {
    Goal = 'GOAL',
    YellowCard = 'YELLOW_CARD',
    RedCard = 'RED_CARD',
    Substitution = 'SUBSTITUTION',
    Injury = 'INJURY',
}

export enum TournamentFormat {
    League = 'LEAGUE',
    Knockout = 'KNOCKOUT',
    RoundRobin = 'ROUND_ROBIN',
}