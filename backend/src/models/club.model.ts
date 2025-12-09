import { Schema, model } from 'mongoose';

const clubSchema = new Schema({
    name: {
        type: String,
        required: true,
        unique: true,
    },
    location: {
        type: String,
        required: true,
    },
    establishedYear: {
        type: Number,
        required: true,
    },
    teams: [{
        type: Schema.Types.ObjectId,
        ref: 'Team',
    }],
    coaches: [{
        type: Schema.Types.ObjectId,
        ref: 'User',
    }],
    players: [{
        type: Schema.Types.ObjectId,
        ref: 'Player',
    }],
}, { timestamps: true });

const Club = model('Club', clubSchema);

export default Club;