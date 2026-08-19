# Safe Senior

**Scam protection for elderly users** — a three-component system that detects SMS/call scams, masks OTPs, alerts guardians, and provides a voice-guided security assistant.

## Architecture

```
┌─────────────────────────┐     HTTPS / JWT     ┌──────────────────────────┐
│   Flutter Mobile App    │◄────────────────────►│   Node.js + Express API  │
│   (Android-first)       │                      │   (Railway-hosted)       │
│                         │                      │   + PostgreSQL           │
│  • SMS scam detection   │                      │                          │
│  • OTP masking          │                      │  • Auth (OTP, 2FA, JWT)  │
│  • Call blocking        │                      │  • Guardian sync (multi) │
│  • Voice assistant      │                      │  • Scam pattern dist.    │
│  • 7-language UI        │                      │  • Admin operations      │
│  • Offline-first cache  │                      │  • Audit logging         │
└─────────────────────────┘                      └──────────┬───────────────┘
                                                            │
                                           ┌───────────────▼────────────────┐
                                           │   React + Vite Admin Panel     │
                                           │   (internal staff only)        │
                                           │                                │
                                           │  • User management             │
                                           │  • Scam report review          │
                                           │  • Pattern curation            │
                                           │  • Audit log viewer            │
                                           │  • Push broadcast (FCM)        │
                                           └────────────────────────────────┘
```

## Component Quick Start

### 1. Backend API

```bash
cd backend
cp .env.example .env          # Fill in DATABASE_URL, JWT_SECRET, SMTP_*, ADMIN_*
npm install
npm run dev                   # Starts on port 3000, auto-runs schema migrations
```

Requires PostgreSQL 14+. On first start the schema is created automatically.

### 2. Flutter App

```bash
flutter pub get
# Edit lib/services/api_client.dart — set _kLocalIp to your machine's LAN IP
flutter run                   # Android emulator or physical device
```

> **Note:** SMS monitoring and native call screening require a real Android device or an emulator with telephony support. iOS shows an informational banner for these features.

### 3. Admin Panel

```bash
cd admin-panel
npm install
# Edit .env.local — set VITE_API_BASE_URL to your backend URL + admin route prefix
npm run dev                   # Starts on http://localhost:5173
```

Create the first admin account via `POST ${ADMIN_ROUTE_PREFIX}/auth/signup` with the initial credentials.

## Environment Variables

See [`backend/.env.example`](./backend/.env.example) for a full reference with generation commands for each secret.

## Platform Limitations

| Feature | Android | iOS |
|---|---|---|
| SMS scam scanning | ✅ Full | ℹ️ Info banner shown (Android-only OS API) |
| Call blocking / screening | ✅ Full | ℹ️ Info banner shown (Android-only OS API) |
| Biometric unlock | ✅ | ✅ |
| Voice assistant | ✅ | ✅ |
| Push notifications | ✅ | ✅ |
| Guardian alerts (SMS/call) | ✅ | ✅ |

## Security Notes

- **Never commit `backend/.env`** — it is `.gitignore`d at both root and backend level
- Rotate `JWT_SECRET` and `ADMIN_JWT_SECRET` if ever exposed
- `ADMIN_ROUTE_PREFIX` should be a secret, randomly-generated path segment
- Admin 2FA (TOTP) can be enabled by setting `ADMIN_2FA_REQUIRED=true`
- FCM push delivery is opt-in — set `FCM_SERVICE_ACCOUNT_PATH` or `FCM_SERVICE_ACCOUNT_JSON` to enable
