// This file contains TypeScript definitions for API responses related to the football coaches app.

export interface User {
    id: string;
    name: string;
    email: string;
    role: UserRole;
}

export interface Club {
    id: string;
    name: string;
    teams: Team[];
}

export interface Team {
    id: string;
    name: string;
    players: Player[];
}

export interface Player {
    id: string;
    name: string;
    age: number;
    position: string;
    number: number;
}

export interface Match {
    id: string;
    homeTeam: Team;
    awayTeam: Team;
    date: string;
    status: MatchStatus;
}

export interface Tournament {
    id: string;
    name: string;
    teams: Team[];
    matches: Match[];
}

export type UserRole = 'Coach' | 'Player' | 'Admin' | 'Referee';

export type MatchStatus = 'Scheduled' | 'In Progress' | 'Completed';