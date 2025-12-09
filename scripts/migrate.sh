#!/bin/bash

# This script is used to migrate the database schema.

# Load environment variables
source .env

# Run database migration commands
echo "Starting database migration..."

# Example command to run migrations (adjust according to your migration tool)
npx prisma migrate deploy

echo "Database migration completed."