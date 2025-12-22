import { NextFunction, Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import type { IUser } from '../models/user.model';
import { getJwtSecret } from '../utils/security';

export const authMiddleware = (req: Request, res: Response, next: NextFunction) => {
    const token = req.headers['authorization']?.split(' ')[1];

    if (!token) {
        return res.status(401).json({ message: 'No token provided' });
    }

    jwt.verify(token, getJwtSecret(), (err: jwt.VerifyErrors | null, decoded: unknown) => {
        if (err) {
            return res.status(401).json({ message: 'Unauthorized' });
        }

        req.user = decoded as IUser; // Assuming the decoded token contains user information
        next();
    });
};

// Backwards-compatible export name used by some routes
export const authenticate = authMiddleware;
