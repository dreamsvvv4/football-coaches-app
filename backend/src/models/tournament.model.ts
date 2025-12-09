import { Schema, model, Document } from 'mongoose';

interface ITournament extends Document {
    name: string;
    startDate: Date;
    endDate: Date;
    teams: string[];
    location: string;
    format: string; // e.g., knockout, league
    createdAt: Date;
    updatedAt: Date;
}

const tournamentSchema = new Schema<ITournament>({
    name: { type: String, required: true },
    startDate: { type: Date, required: true },
    endDate: { type: Date, required: true },
    teams: { type: [String], required: true },
    location: { type: String, required: true },
    format: { type: String, required: true },
}, {
    timestamps: true,
});

const Tournament = model<ITournament>('Tournament', tournamentSchema);

export default Tournament;