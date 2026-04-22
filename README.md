# AfriConnect - Social Media Platform

A Flutter-based social media platform for Africa with AI features.

## Features

- 📱 **Feed** - Chronological and algorithmic feed
- 👤 **Profiles** - Customizable user profiles
- 💬 **Messaging** - Direct messages between users
- 📺 **Live Streaming** - Live video streams via LiveKit
- 🎨 **AI Tools** - Caricature and emoji generators
- 📊 **Analytics** - Post performance dashboard
- 📑 **Pages** - Instagram-like sector pages
- 🚫 **Moderation** - Content reporting system

## Setup

### 1. Prerequisites
- Flutter 3.22+
- Node.js 18+ (for Edge Functions)
- Supabase account

### 2. Supabase Setup

```bash
# Create project on Supabase
# Go to Dashboard > SQL Editor and run:
# - SQL schema from documentation
# - Database functions from supabase/database_functions.sql
```

Create storage buckets:
- `posts` - For post media
- `avatars` - For profile pictures
- `ai_inputs` - For AI generation inputs
- `caricatures` - For generated caricatures

### 3. Environment Variables

Update `.env`:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
REPLICATE_API_TOKEN=your_replicate_token
LIVEKIT_API_KEY=your_livekit_key
LIVEKIT_API_SECRET=your_livekit_secret
OPENAI_API_KEY=your_openai_key
```

### 4. Edge Functions

```bash
# Install Supabase CLI
npm install -g supabase

# Link project
supabase link --project-ref your_project_ref

# Deploy functions
supabase functions deploy create-post
supabase functions deploy generate-caricature
supabase functions deploy analytics-processing
supabase functions deploy get-algorithmic-feed
supabase functions deploy get-user-stats
```

### 5. Run App

```bash
flutter pub get
flutter create assets/images assets/icons
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── config/         # App configuration
│   ├── models/         # Data models
│   ├── services/       # Business logic
│   ├── themes/        # UI themes
│   └── utils/          # Utilities
├── features/
│   ├── ai_tools/      # AI generators
│   ├── analytics/     # Dashboard
│   ├── auth/          # Login/Register
│   ├── feed/          # Posts feed
│   ├── live/          # Streaming
│   ├── messaging/     # Chat
│   ├── pages/         # Sector pages
│   └── profile/       # User profiles
├── widgets/           # Reusable UI
└── main.dart          # Entry point
```

## License

MIT