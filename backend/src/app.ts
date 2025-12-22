import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import authRoutes from './routes/auth.routes';
import usersRoutes from './routes/users.routes';
import clubsRoutes from './routes/clubs.routes';
import matchesRoutes from './routes/matches.routes';
import { logger } from './utils/logger';
import { buildCorsOptions, getJwtSecret } from './utils/security';

const app = express();
const PORT = process.env.PORT || 5000;

// Fail fast on critical configuration
getJwtSecret();

// Middleware
app.disable('x-powered-by');
app.use(
    helmet({
        // API-first service; leave CSP to frontends/CDN.
        contentSecurityPolicy: false,
    })
);

app.use(
    rateLimit({
        windowMs: 15 * 60 * 1000,
        max: 300,
        standardHeaders: true,
        legacyHeaders: false,
    })
);

app.use(cors(buildCorsOptions()));
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true, limit: '1mb' }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/clubs', clubsRoutes);
app.use('/api/matches', matchesRoutes);

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
