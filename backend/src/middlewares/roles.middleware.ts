import { Request, Response, NextFunction } from 'express';
import { UserRole } from '../../shared/src/types/roles';

const rolesMiddleware = (roles: UserRole[]) => {
    return (req: Request, res: Response, next: NextFunction) => {
        const userRole = req.user?.role;

        if (!userRole) {
            return res.status(403).json({ message: 'Access denied. No role provided.' });
        }

        if (!roles.includes(userRole)) {
            return res.status(403).json({ message: 'Access denied. Insufficient permissions.' });
        }

        next();
    };
};

export default rolesMiddleware;