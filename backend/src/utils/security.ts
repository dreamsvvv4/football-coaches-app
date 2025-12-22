import type { CorsOptions } from 'cors';

export function getRequiredEnv(name: string): string {
  const value = process.env[name];
  if (!value || value.trim().length === 0) {
    throw new Error(`Missing required env var: ${name}`);
  }
  return value;
}

export function getJwtSecret(): string {
  const secret = getRequiredEnv('JWT_SECRET');
  if (secret.length < 32) {
    throw new Error('JWT_SECRET must be at least 32 characters long');
  }
  return secret;
}

export function buildCorsOptions(): CorsOptions {
  const isProd = process.env.NODE_ENV === 'production';
  const rawOrigins = process.env.CORS_ORIGINS;

  const allowedOrigins = (rawOrigins
    ? rawOrigins.split(',').map(o => o.trim()).filter(Boolean)
    : isProd
      ? []
      : ['http://localhost:3000', 'http://localhost:5173', 'http://localhost:5000']
  );

  return {
    origin: (origin, callback) => {
      if (!origin) return callback(null, true);
      if (allowedOrigins.includes(origin)) return callback(null, true);
      return callback(new Error('Not allowed by CORS'));
    },
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Authorization', 'Content-Type'],
    credentials: true,
    maxAge: 60 * 60 * 24,
  };
}
