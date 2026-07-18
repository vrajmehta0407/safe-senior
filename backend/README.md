# Safe Senior Backend

Node.js/Express + PostgreSQL backend for the Safe Senior app.  
Designed to be deployed on **Railway** with a PostgreSQL plugin.

---

## Tech Stack

| Layer        | Library / Service          |
|--------------|---------------------------|
| Runtime      | Node.js 18+               |
| Framework    | Express 4                 |
| Database     | PostgreSQL (via `pg` pool)|
| Auth         | JWT + bcryptjs            |
| OTP delivery | MSG91 SMS API             |
| Hosting      | Railway                   |

---

## Project Structure

```
backend/
├── railway.json
├── package.json
├── .env.example
└── src/
    ├── index.js                   ← entry point
    ├── db/
    │   ├── pool.js                ← pg Pool singleton
    │   └── schema.sql             ← auto-run on startup
    ├── middleware/
    │   ├── auth.js                ← JWT Bearer verification
    │   └── rateLimit.js           ← OTP + auth rate limiters
    ├── routes/
    │   ├── auth.js                ← /auth/*
    │   ├── guardian.js            ← /guardian/*
    │   └── scamPatterns.js        ← /scam-patterns/*
    └── services/
        └── msg91.js               ← MSG91 OTP sender
```

---

## Environment Variables

Copy `.env.example` to `.env` and fill in every value before running locally.

| Variable            | Description                                          |
|---------------------|------------------------------------------------------|
| `DATABASE_URL`      | Full PostgreSQL connection string                    |
| `JWT_SECRET`        | Random secret for signing JWTs (min 32 chars)        |
| `MSG91_AUTH_KEY`    | Your MSG91 account Auth Key                          |
| `MSG91_TEMPLATE_ID` | Approved MSG91 OTP template ID                       |
| `MSG91_SENDER_ID`   | 6-char sender ID approved by MSG91 (default SAFESNR) |
| `PORT`              | HTTP port (Railway sets this automatically)          |
| `NODE_ENV`          | `production` or `development`                        |
| `ALLOWED_ORIGINS`   | Comma-separated list of allowed CORS origins (prod)  |

---

## Local Development

### Prerequisites
- Node.js 18+
- PostgreSQL 13+ running locally (or a cloud instance)
- A MSG91 account with an approved OTP template

### Steps

```bash
# 1. Install dependencies
cd backend
npm install

# 2. Set up environment
cp .env.example .env
# Edit .env with your local DB URL and MSG91 keys

# 3. Start the dev server (auto-restarts on file changes)
npm run dev
```

The server will:
1. Connect to PostgreSQL
2. Auto-run `src/db/schema.sql` to create tables (idempotent — safe to re-run)
3. Listen on http://localhost:3000

### Health check
```
GET http://localhost:3000/health
→ { status: 'ok', timestamp: '...', uptime: 12 }
```

---

## MSG91 Account Setup

1. Register at [https://msg91.com](https://msg91.com)
2. Go to **API** → **Auth Key** and copy your key → set `MSG91_AUTH_KEY`
3. Go to **SMS** → **Templates** → create an OTP template:
   - Template body example: `Your Safe Senior OTP is ##otp##. Valid for 8 minutes. Do not share.`
   - Get the Template ID after approval → set `MSG91_TEMPLATE_ID`
4. Register a **Sender ID** (6 chars, e.g. `SAFSNR`) → set `MSG91_SENDER_ID`

> **Note**: MSG91 template approval can take 1–24 hours. During development you can log the OTP to the console by temporarily bypassing the `sendOtp` call.

---

## Railway Deployment

### One-click via Railway CLI

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Create a new project
railway init

# Add PostgreSQL plugin inside Railway dashboard:
# Project → New → Database → PostgreSQL
# Railway will inject DATABASE_URL automatically.

# Set remaining env vars
railway variables set JWT_SECRET=<your_secret>
railway variables set MSG91_AUTH_KEY=<your_key>
railway variables set MSG91_TEMPLATE_ID=<template_id>
railway variables set MSG91_SENDER_ID=SAFESNR
railway variables set NODE_ENV=production

# Deploy
railway up
```

### Via GitHub Integration

1. Push this repo to GitHub
2. In Railway dashboard → **New Project** → **Deploy from GitHub repo**
3. Select the repo; Railway auto-detects `railway.json` and uses Nixpacks
4. Add a **PostgreSQL** plugin — `DATABASE_URL` is injected automatically
5. Add the other env vars in **Variables** tab
6. Railway will build and deploy; the health check endpoint `/health` is polled

### After Deployment

```
GET https://<your-project>.up.railway.app/health
```

Should return `{ "status": "ok", ... }`.

---

## API Reference

### Auth

| Method | Path                    | Auth | Description                        |
|--------|-------------------------|------|------------------------------------|
| POST   | `/auth/signup`          | No   | Register new user                  |
| POST   | `/auth/login`           | No   | Login, returns JWT                 |
| POST   | `/auth/otp/request`     | No   | Send OTP via SMS (rate-limited)    |
| POST   | `/auth/otp/verify`      | No   | Verify OTP code                    |
| POST   | `/auth/2fa/verify`      | Yes  | Verify 2FA OTP (requires JWT)      |
| POST   | `/auth/reset-password`  | No   | Reset password with OTP            |

### Guardian

| Method | Path              | Auth | Description                  |
|--------|-------------------|------|------------------------------|
| GET    | `/guardian/sync`  | Yes  | Fetch user's guardian        |
| POST   | `/guardian/sync`  | Yes  | Create or update guardian    |

### Scam Patterns

| Method | Path                    | Auth | Description                      |
|--------|-------------------------|------|----------------------------------|
| GET    | `/scam-patterns/latest` | No   | Get all scam patterns            |
| POST   | `/scam-patterns/report` | Yes  | Submit a scam report             |

---

## Rate Limits

| Limiter      | Window    | Max requests | Keyed by     |
|--------------|-----------|--------------|--------------|
| OTP request  | 15 min    | 3            | Phone number |
| Auth/login   | 15 min    | 10           | IP address   |

---

## Security Notes

- Passwords are hashed with **bcrypt** (10 rounds)
- OTP codes are hashed with **bcrypt** before DB storage — never stored in plain text
- OTPs expire after **8 minutes** and are locked after **5 failed attempts**
- JWTs expire after **7 days**
- The `/auth/otp/request` endpoint returns a generic response when a phone number is not found to prevent user enumeration
