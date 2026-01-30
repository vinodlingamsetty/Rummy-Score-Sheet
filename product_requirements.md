# Product Requirements: Rummy Scorekeeper

## 1. App Overview
A premium, offline-first iOS scorekeeping app for Indian Rummy.
**Design Aesthetic:** "Liquid Glass" (Dark Mode, Blur Effects, Neon Accents).
**Tech Stack:** Native iOS (SwiftUI), SwiftData (Local DB), Firebase (Cloud Sync).

## 2. Terminology (Strict Compliance)
- **Point Value:** The value assigned to each point (e.g., $0.10). Never use "Bet".
- **Settlement:** The final calculation of who owes whom. Never use "Debt".
- **Game Pot:** The total value of the game.
- **Moderator:** The player who created the room and controls settings.

## 3. Navigation Structure (5 Tabs)
1.  **Home:** Dashboard, Create/Join, History.
2.  **Current Game:** The active scoreboard (Disabled if no game active).
3.  **Friends:** Ledger of settlements.
4.  **Rules:** Static guide for gameplay.
5.  **Profile:** User settings and account management.

## 4. Core Features Detailed

### A. Authentication & Onboarding
- **Sign in with Apple** (Primary) & Google (Secondary).
- **Profile Setup:**
    - **Display Name:** Public "Player Alias".
    - **Avatar:** Selection from 12 pre-loaded 3D Memoji-style avatars.
    - **Privacy:** Email/Phone hidden from other players.

### B. Home Tab & History
- **Actions:**
    - **Host Game:** Opens setup modal.
    - **Join Game:** QR Code scanner or 6-digit PIN entry.
- **Game History:**
    - List of all completed games (Date, Winner, My Final Score).
    - **Filters:** By Date, By Player Name, By Room Code.
    - **Action:** Tap a past game to view the full readonly scoreboard.

### C. Game Setup (Host Only)
- **Inputs:**
    - Point Limit (range from 100 to 900). this should be a slider bar 
    - Point Value (e.g., 0.10).
    - Player Count (Max 10).
- **Lobby:**
    - **QR Code:** Generated locally for others to join.
    - **Roster:** List of joined players with "Ready" status indicators.
    - **Mod Action:** "Start Game" (only enabled when all players are ready).

### D. The Scoreboard (Active Game)
- **View:** Vertical scrolling list (Chat style, not pagination).
- **Sticky Header:** Live Leaderboard (Top 3) & Current Round Number.
- **Score Entry:**
    - Tap player row -> Expands large numeric keypad.
    - **Haptics:** `Light` impact on keypress.
    - **Auto-Advance:** "Next Player" button on keyboard.
- **Game Logic:**
    - **Elimination:** If Score >= Point Limit, row turns Red (Opacity 0.5), input disabled.
    - **Winning Condition:** The last player remaining (or lowest score if game ended manually) wins the "Game Pot".
    - **Re-Buy:** Moderator can "Revive" a player (Score = Highest Active Score + 1).
- **Real-Time Updates:**
    - Scores sync instantly via Firebase Firestore listeners.
    - **Toasts:** Show in-app notification when a new score is submitted by another player.

### E. Friends & Settlements Tab
- **View:** Split into two sections:
    - **"To Collect" (Green):** Positive balance.
    - **"To Settle" (Orange):** Negative balance.
- **Search:** Filter friends by name.
- **Actions:**
    - **Nudge:** Sends a push notification ("Reminder to check score").
    - **Settle:** "Mark as Settled" button (Clear balance to $0).
- **Logic:** Players from the same room are auto-added to Friends list.

### F. Rules Tab
- Static text/graphical display of Indian Rummy rules.
- **Decks Guide:**
    - 2 Players: 1-2 Decks.
    - 2-6 Players: 2 Decks.
    - 7+ Players: 3 Decks.

### G. Profile & Settings
- **User Info:** Edit Display Name, Change Avatar.
- **App Settings:**
    - **Notifications:** Toggle On/Off.
    - **Haptics:** Toggle Sound/Vibration.
    - **Theme:** (Locked to Dark Mode, but maybe Accessibility High Contrast option).
- **Account:** Logout button.

## 5. Technical Constraints
- **Offline First:** All game logic saves to `SwiftData` (local) first. Syncs to Firebase when online.
- **Permissions:** Camera (for QR), Notifications (for Nudges).