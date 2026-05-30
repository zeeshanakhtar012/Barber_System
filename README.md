# Barber SaaS — White-Label Barber Shop Queue Management Platform

A full-stack white-label SaaS platform for managing barber shop queues, appointments, and operations. Customers discover nearby shops, join live queues, and track their position in real time. Each shop gets its own admin dashboard with full control over services, queue, breaks, and branding.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter (Dart) + GetX (state management/routing) |
| **Backend** | Node.js + Express |
| **Database** | MongoDB + Mongoose ODM |
| **Auth** | JWT (`jsonwebtoken`) + bcryptjs |
| **Real-time** | Socket.IO (queue & notification namespaces) |
| **HTTP Client** | Dio (Flutter) |
| **Validation** | Joi |
| **File Uploads** | Multer |
| **Security** | Helmet, CORS, express-rate-limit |
| **Deep Linking** | Custom URL scheme (`barberspace://shop/:id`) |

## Features

### User Roles
- **Super Admin** — Manage all shops (create, edit, suspend), view all customers
- **Barber Admin** — Manage shop queue, services, breaks, settings, branding
- **Customer** — Browse shops, book appointments with service selection, view bookings, real-time queue updates

### White-Label Support
Set `targetShopId` in `lib/core/config/app_config.dart` to compile a standalone branded app for a single shop, or leave `null` for the multi-shop portal mode.

## Project Structure

```
lib/                          # Flutter frontend
  core/                       # Config, theme, networking, routes, services
  data/models/                # User, Shop, Service, Appointment, Break, Notification models
  features/                   # Auth, Super Admin, Barber, Customer feature modules
  shared/widgets/             # Reusable UI components (GlassContainer, etc.)
server/                       # Node.js backend
  src/
    config/                   # DB, env, socket config
    core/                     # Errors, responses, utilities
    middlewares/               # Auth, role, validation, error handling, upload
    modules/                  # Auth, Users, Shops, Services, Appointments, Queue,
                              # Analytics, Breaks, Notifications, Subscriptions, Uploads
    sockets/                  # Queue & notification Socket.IO namespaces
```

## Getting Started

### Prerequisites
- Flutter SDK (^3.11.5)
- Node.js (v18+)
- MongoDB (local or remote)
- Firebase project (for `google-services.json` / `GoogleService-Info.plist`)

### Backend Setup
```bash
cd server
npm install
# Edit server/.env with your MongoDB URI, JWT secret, etc.
npm run dev     # Development with nodemon
npm start       # Production
```

### Flutter Frontend Setup
```bash
flutter pub get
flutter run
```

### Build
```bash
flutter build apk     # Android APK
flutter build ios     # iOS (requires Xcode)
flutter build web     # Web build
```

## Environment Variables (`server/.env`)

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `5001` | Server port |
| `NODE_ENV` | `development` | Environment mode |
| `MONGODB_URI` | `mongodb://localhost:27017/barber_saas` | MongoDB connection |
| `JWT_SECRET` | — | JWT signing secret |
| `JWT_EXPIRES_IN` | `7d` | Token expiration |
| `RATE_LIMIT_WINDOW_MS` | `900000` (15 min) | Rate limit window |
| `RATE_LIMIT_MAX_REQUESTS` | `100` | Max requests per window |
