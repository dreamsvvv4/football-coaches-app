export interface Team {
    id: string;
    name: string;
    category: string;
    coachId: string;
    players: string[]; // Array of player IDs
    clubId: string;
    createdAt: Date;
    updatedAt: Date;
}

export class TeamModel {
    constructor(public team: Team) {}

    // Method to add a player to the team
    addPlayer(playerId: string): void {
        if (!this.team.players.includes(playerId)) {
            this.team.players.push(playerId);
        }
    }

    // Method to remove a player from the team
    removePlayer(playerId: string): void {
        this.team.players = this.team.players.filter(id => id !== playerId);
    }

    // Method to update team details
    updateTeamDetails(updatedTeam: Partial<Team>): void {
        this.team = { ...this.team, ...updatedTeam, updatedAt: new Date() };
    }
}