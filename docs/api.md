# API Documentation for Football Coaches App

## Overview

This document provides an overview of the API endpoints available in the Football Coaches App. The API is designed to facilitate communication between the mobile application, web admin interface, and backend services.

## Base URL

The base URL for the API is:

```
http://api.football-coaches-app.com/v1
```

## Authentication

All endpoints require authentication. Use the following method to obtain a token:

### POST /auth/login

- **Request Body:**
  - `email`: string
  - `password`: string

- **Response:**
  - `token`: string
  - `user`: object (user details)

## User Endpoints

### GET /users

- **Description:** Retrieve a list of users.
- **Response:**
  - `users`: array of user objects

### GET /users/:id

- **Description:** Retrieve a specific user by ID.
- **Response:**
  - `user`: object (user details)

## Club Endpoints

### GET /clubs

- **Description:** Retrieve a list of clubs.
- **Response:**
  - `clubs`: array of club objects

### POST /clubs

- **Description:** Create a new club.
- **Request Body:**
  - `name`: string
  - `location`: string

- **Response:**
  - `club`: object (created club details)

## Team Endpoints

### GET /teams

- **Description:** Retrieve a list of teams.
- **Response:**
  - `teams`: array of team objects

### POST /teams

- **Description:** Create a new team.
- **Request Body:**
  - `name`: string
  - `category`: string

- **Response:**
  - `team`: object (created team details)

## Match Endpoints

### GET /matches

- **Description:** Retrieve a list of matches.
- **Response:**
  - `matches`: array of match objects

### POST /matches

- **Description:** Schedule a new match.
- **Request Body:**
  - `teamA`: string (team ID)
  - `teamB`: string (team ID)
  - `date`: string (ISO 8601 format)

- **Response:**
  - `match`: object (scheduled match details)

## Tournament Endpoints

### GET /tournaments

- **Description:** Retrieve a list of tournaments.
- **Response:**
  - `tournaments`: array of tournament objects

### POST /tournaments

- **Description:** Create a new tournament.
- **Request Body:**
  - `name`: string
  - `teams`: array of team IDs

- **Response:**
  - `tournament`: object (created tournament details)

## Notifications

### GET /notifications

- **Description:** Retrieve notifications for the authenticated user.
- **Response:**
  - `notifications`: array of notification objects

## Error Handling

All responses will include a status code and a message. Common status codes include:

- `200 OK`: Successful request
- `201 Created`: Resource created successfully
- `400 Bad Request`: Invalid request
- `401 Unauthorized`: Authentication failed
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

## Conclusion

This API documentation provides a comprehensive overview of the available endpoints for the Football Coaches App. For further details, please refer to the individual endpoint documentation or contact the development team.