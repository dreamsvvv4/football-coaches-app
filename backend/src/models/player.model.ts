import { Schema, model } from 'mongoose';

const playerSchema = new Schema({
    name: {
        type: String,
        required: true,
    },
    age: {
        type: Number,
        required: true,
    },
    dorsal: {
        type: Number,
        required: true,
        unique: true,
    },
    position: {
        type: String,
        required: true,
    },
    photo: {
        type: String,
        required: false,
    },
    medicalNotes: {
        type: String,
        required: false,
    },
    statistics: {
        matchesPlayed: {
            type: Number,
            default: 0,
        },
        goals: {
            type: Number,
            default: 0,
        },
        assists: {
            type: Number,
            default: 0,
        },
        yellowCards: {
            type: Number,
            default: 0,
        },
        redCards: {
            type: Number,
            default: 0,
        },
    },
    historicalData: [{
        season: {
            type: String,
            required: true,
        },
        matchesPlayed: {
            type: Number,
            default: 0,
        },
        goals: {
            type: Number,
            default: 0,
        },
        assists: {
            type: Number,
            default: 0,
        },
    }],
}, { timestamps: true });

export const Player = model('Player', playerSchema);