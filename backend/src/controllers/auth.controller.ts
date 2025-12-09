import { Request, Response } from 'express';
import { AuthService } from '../services/auth.service';

class AuthController {
    async register(req: Request, res: Response) {
        try {
            const user = await AuthService.register(req.body);
            res.status(201).json(user);
        } catch (error) {
            res.status(400).json({ message: error.message });
        }
    }

    async login(req: Request, res: Response) {
        try {
            const token = await AuthService.login(req.body);
            res.status(200).json({ token });
        } catch (error) {
            res.status(401).json({ message: error.message });
        }
    }

    async logout(req: Request, res: Response) {
        try {
            await AuthService.logout(req.user.id);
            res.status(200).json({ message: 'Logged out successfully' });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async refreshToken(req: Request, res: Response) {
        try {
            const token = await AuthService.refreshToken(req.body.token);
            res.status(200).json({ token });
        } catch (error) {
            res.status(401).json({ message: error.message });
        }
    }
}

export const authController = new AuthController();