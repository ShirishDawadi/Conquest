# Conquest

**Outside is the new meta.**

Conquest is a cross-platform, gamified fitness and exploration app that turns everyday walking into a quest-based experience. Complete adaptive daily step goals, hunt down real-world objects with on-device object detection, track your walking routes, and climb the leaderboard — one step at a time.

> ⚠️ **Status: In active development.** Most core functionality is complete, with additional features, offline support, and polish still in progress. See [Roadmap](#roadmap).

---

## Features

### 🏃 Daily Quests
- Adaptive step goals that adjust based on your last 7 days of activity
- Two object-detection challenges per day, selected with difficulty-aware randomization and monthly deduplication so quests stay fresh

### 📸 Object Detection
- On-device object detection powered by **YOLOv8n (TensorFlow Lite)**, trained on the COCO dataset — works fully offline
- **Live mode**: point your camera and get real-time bounding boxes as objects are detected
- **Capture mode**: snap a photo, then detect — better for lower-end devices or unreliable lighting
- Automatic mode recommendation based on an on-device inference benchmark, with a manual override

### 🗺️ Exploration & GPS Tracking
- Optional GPS-tracked walking/exploration sessions
- Route compression using the **Ramer-Douglas-Peucker (RDP) algorithm** to keep GPS paths lightweight
- Calendar view of past sessions, with distance, duration, and average speed
- Fully offline-capable — sessions sync when back online

### 🏆 Progression System
- XP, levels, and league tiers (Bronze → up)
- Weekly points, all-time XP, and streak tracking
- Weekly, steps-based, and all-time leaderboards

### 👤 Profile & Social
- Custom pixel-art avatars
- Editable profile with stats: total steps, weekly points, longest streak
- Global leaderboard

---

## Screenshots

**Auth**
![Auth](screenshots/auth.png)

**Home**
![Home](screenshots/home.png)

**Map**
![Map 1](screenshots/map-1.png)
![Map 2](screenshots/map-2.png)

**Leaderboard**
![Leaderboard](screenshots/leaderboard.png)

**Profile**
![Profile](screenshots/profile.png)

**Scan**
![Scan](screenshots/scan.png)

---

## Tech Stack

**Frontend**
- [Flutter](https://flutter.dev/) — cross-platform mobile (Android/iOS)
- [Riverpod](https://riverpod.dev/) — state management, MVVM architecture
- `camera`, `tflite_flutter`, `image` — on-device object detection pipeline
- `geolocator`, `flutter_map` — GPS tracking and route rendering
- `flutter_foreground_task` — background location tracking
- `sqflite` — local offline-first storage

**Backend**
- [FastAPI](https://fastapi.tiangolo.com/) (Python) — REST API
- [PostgreSQL](https://www.postgresql.org/) via [Supabase](https://supabase.com/) — database + object storage
- [SQLAlchemy](https://www.sqlalchemy.org/) — ORM
- JWT-based authentication
- Deployed on [Render](https://render.com/)

**ML**
- YOLOv8n exported to TensorFlow Lite for on-device inference
- 192×192 input resolution with NMS post-processing and temporal confirmation to reduce false positives

---

## Architecture

```text
Frontend (Flutter)
├─ core/
│  ├─ constants/
│  ├─ database/
│  ├─ network/
│  ├─ services/
│  ├─ theme/
│  ├─ utils/
│  └─ validators/
├─ data/
│  ├─ models/
│  └─ sources/
│     ├─ local/
│     └─ remote/
└─ presentation/
   ├─ viewmodels/
   └─ views/
      ├─ auth/
      ├─ home/
      ├─ leaderboard/
      ├─ map/
      ├─ object_scan/
      ├─ profile/
      ├─ shared_widgets/
      └─ shell/

Backend (FastAPI)
├─ models/
├─ routers/
├─ schemas/
├─ services/
└─ utils/

Supabase
├─ PostgreSQL Database
└─ Storage
```

The app follows an **MVVM** pattern on the frontend. Views remain focused on UI, business logic lives in view models, and long-running services such as camera and object detection are managed independently of the widget lifecycle.

---

## Key Algorithms

| Algorithm | Purpose |
|---|---|
| **RDP (Ramer-Douglas-Peucker)** | Compresses raw GPS point streams into simplified paths without losing route shape |
| **Adaptive Goal Setting** | Calculates personalized daily step goals from a rolling 7-day activity window |
| **Difficulty-Aware Random Selection** | Picks daily object-detection targets, weighted by difficulty, with deduplication across the month |

---

## Roadmap

- [ ] Offline-first sync for object detection captures (SQLite queue)
- [ ] Connect profile activity calendar and charts to backend
- [ ] Forgot password / change password flows
- [ ] Rate limiting & hardened backend validation
- [ ] Level-up and streak animations
- [ ] Settings screen (theme, account, notifications)

---

## Getting Started

### Prerequisites
- Flutter SDK (^3.9.2)
- Python 3.12+
- A Supabase project (PostgreSQL + Storage)

### Backend
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

Environment variables needed (backend): `DATABASE_URL`, `SECRET_KEY`, `SUPABASE_URL`, `SUPABASE_SERVICE_KEY`.

### Frontend

`core/config.dart` is gitignored (it holds the API base URL) and needs to be created manually before the app will build:

```dart
class Config {
  static const String baseUrl = 'http://YOUR_BACKEND_URL_HERE';
}
```

Use `http://10.0.2.2:8000` for the Android emulator talking to a local backend, or your deployed Render URL (e.g. `https://your-service.onrender.com`) for a live backend.

> **Note:** The real backend URL isn't published here. Reach out for the live URL if you need one, or deploy your own backend using the steps below.

```bash
cd frontend
flutter pub get
flutter run
```

---

## Author

**Shirish Dawadi** — Mobile App Developer, Bharatpur, Nepal
[GitHub](https://github.com/ShirishDawadi)