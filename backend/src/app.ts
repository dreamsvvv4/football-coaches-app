import express from 'express';
import mongoose from 'mongoose';
import bodyParser from 'body-parser';
import cors from 'cors';
import { authRoutes } from './routes/auth.routes';
import { usersRoutes } from './routes/users.routes';
import { clubsRoutes } from './routes/clubs.routes';
import { matchesRoutes } from './routes/matches.routes';
import { teamsRoutes } from './routes/teams.routes';
import { tournamentsRoutes } from './routes/tournaments.routes';
import { logger } from './utils/logger';

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/clubs', clubsRoutes);
app.use('/api/matches', matchesRoutes);
app.use('/api/teams', teamsRoutes);
app.use('/api/tournaments', tournamentsRoutes);

// Database connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/football-coaches-app', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
})
.then(() => {
    logger.info('Database connected successfully');
})
.catch(err => {
    logger.error('Database connection error:', err);
});

// Start server
app.listen(PORT, () => {
    logger.info(`Server is running on port ${PORT}`);
});