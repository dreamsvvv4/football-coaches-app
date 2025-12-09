export type UserRole = 'Entrenador' | 'Jugador' | 'Club' | 'Árbitro' | 'Aficionado' | 'Superadmin';

export interface User {
    id: string;
    name: string;
    role: UserRole;
    email: string;
    password: string; // hashed password
}

export interface Coach extends User {
    teams: string[]; // Array of team IDs
}

export interface Player extends User {
    teamId: string; // ID of the team the player belongs to
    position: string;
    number: number; // Jersey number
}

export interface ClubAdmin extends User {
    clubId: string; // ID of the club the admin manages
}

export interface Referee extends User {
    matchesOfficiated: string[]; // Array of match IDs
}

export interface Fan extends User {
    favoriteTeams: string[]; // Array of team IDs
}