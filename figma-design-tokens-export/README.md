# Rummy Score Tracker - Frontend Prototype

A fully functional frontend prototype for a Rummy scorekeeping app built with React, TypeScript, and Tailwind CSS.

## Features

### 🏠 Home Tab
- **Google Login** (simulated with mock data)
- **Create Room** - Generate unique room codes with customizable point limits and bet amounts
- **Join Room** - Enter 6-digit codes or scan QR codes
- **Game History** - View completed games with timestamps, players, and results

### 🎮 Current Game Tab
- **Room Lobby**
  - View all players with avatars
  - Ready/Not Ready status
  - Moderator controls to start game
  
- **Score Tracking**
  - 4 players × 15 rounds grid
  - Round navigation (R1, R2, R3... T for totals)
  - Real-time score input
  - Disabled fields for eliminated players
  - Edit and Submit controls
  - Moderator approval system

- **Game Results**
  - Winner announcement
  - Final scores for all players
  - Auto-balance updates

### 👥 Friends Tab
- Search friends by name
- View balances (red = you owe, green = they owe you)
- Pending friend requests
- Friend detail management:
  - Update balances
  - Settle in cash
  - Remove friends
- Auto-friend players from game rooms

### 📖 Rules Tab
- Maximum player limits (up to 10)
- Deck recommendations by player count
- Winning conditions
- Scoring rules
- Game flow explanation

### 👤 Profile Tab
- Edit profile (name, avatar)
- Avatar selection from preset emojis
- Game statistics (games played, won, total winnings)
- App settings:
  - Push notifications
  - Sound effects
  - Vibration
  - Dark/Light mode
- Logout functionality

## Demo Features

- **Mock Data**: All data is simulated - no backend required
- **LocalStorage**: User sessions persist across refreshes
- **Toast Notifications**: Real-time feedback for all actions
- **Responsive Design**: Works on mobile and desktop
- **Smooth Animations**: Motion/React powered transitions
- **Glassmorphism UI**: Modern 2026 liquid glass design

## How to Use

1. **Login**: Click "Sign in with Google" (uses mock authentication)
2. **Create a Room**: 
   - Set point limit (e.g., 500)
   - Set bet amount (e.g., $10)
   - Share the generated room code
3. **Join Room**: Enter a 6-digit code to join existing games
4. **Play**:
   - Mark yourself as ready in lobby
   - Moderator starts the game
   - Submit scores each round
   - Navigate rounds using R1, R2, etc buttons
   - View totals with "T" button
5. **Manage Friends**: View balances, settle payments, send requests
6. **View History**: Check past games and results

## Technical Stack

- **React 18** with TypeScript
- **Tailwind CSS v4** for styling
- **Motion/React** for animations
- **Radix UI** components
- **Sonner** for toast notifications
- **Next Themes** for theme management
- **Vite** for build tooling

## Mock Data

The app includes:
- Mock users with avatars
- Sample game history
- Pre-populated friends list
- Simulated room creation/joining
- Example score tracking scenarios

## Limitations (Frontend Only)

- No real backend - all data is local
- No actual Google OAuth
- No real-time multiplayer sync
- No persistent database
- No payment processing
- No QR code scanning (UI only)

## Next Steps for Production

To convert this to a production app, you would need:
1. **Backend Integration** - Supabase, Firebase, or custom API
2. **Real Authentication** - Google OAuth implementation
3. **Real-time Database** - For multiplayer sync
4. **Push Notifications** - For game updates
5. **Payment Integration** - For bet tracking
6. **QR Code Scanner** - Camera integration

## Design Highlights

- **Glassmorphism**: Backdrop blur effects with translucent surfaces
- **Violet/Indigo Gradient**: Modern purple color scheme
- **Smooth Animations**: Scale effects, fades, and transitions
- **Mobile-First**: Bottom navigation, touch-friendly buttons
- **Clear Typography**: Easy-to-read fonts and spacing

---

**Note**: This is a frontend prototype using mock data for demonstration purposes. All gameplay and features work locally without a backend server.
