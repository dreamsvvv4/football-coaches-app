import { Schema, model, Document } from 'mongoose';

export interface IUser extends Document {
    username: string;
    email: string;
    password: string;
    role: 'coach' | 'player' | 'admin' | 'referee' | 'fan';
    clubId?: string; // Optional, for players and coaches
    createdAt: Date;
    updatedAt: Date;
}

const userSchema = new Schema<IUser>({
    username: { type: String, required: true, unique: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    role: { type: String, enum: ['coach', 'player', 'admin', 'referee', 'fan'], required: true },
    clubId: { type: String, required: false },
}, {
    timestamps: true,
});

export const User = model<IUser>('User', userSchema);