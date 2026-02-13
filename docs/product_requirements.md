# Product Requirements: Rummy Scorekeeper

## 1. App Overview
A premium iOS scorekeeping app for Indian Rummy.
**Design Aesthetic:** "Liquid Glass" (Dark Mode, Blur Effects, Subtle System Gradient Backdrop, Neon Accents).
**Tech Stack:** Native iOS (SwiftUI), Firebase (Auth, Firestore, Cloud Functions).

## 2. Terminology
- **Point Value:** The dollar value assigned to each point (e.g., $10).
- **Settlement:** Recording a payment to adjust the balance between two users.
- **Moderator:** The player who created the room and controls settings.
- **Eliminated:** A player whose total score has reached or exceeded the Point Limit.

## 3. Navigation Structure
1.  **Home:** Dashboard, Create/Join, Recent Games history.
2.  **Game:** The active scoreboard (Only accessible if in a room).
3.  **Friends:** List of friends with real-time balances and settlement history.
4.  **Rules:** Indian Rummy rules and deck guidelines.
5.  **Profile:** User statistics, display name editing, and app settings.

## 4. Core Features & Workflows

### A. Authentication
- **Methods:** Sign in with Apple, Google, or Email OTP (One-Time Password).
- **Anonymous:** Supports guest entry for quick setup.
- **Workflow:** 
    1. User enters email -> Receives 6-digit code.
    2. User enters code -> Authenticated and profile created.

### B. Game Setup & Lobby
- **Creation:** Moderator sets Point Limit (100-350) and Point Value.
- **Lobby:** Shows a 6-digit Room Code and QR Code for others to join.
- **Start Game:** Enabled only when at least 2 players are present and all are marked "Ready".
- **Workflow:** 
    1. Host taps "Create Room" -> Sets parameters -> enters Lobby.
    2. Players scan QR/Enter Code -> enters Lobby -> taps "Ready".
    3. Host taps "Start Game" -> transitions all to Scoreboard.

### C. Active Scoreboard
- **Score Entry:** Tap a player row to enter a round score via numeric keypad.
- **Elimination:** Players reaching the limit get an alert and their row is dimmed.
- **End Game:** 
    - **Automatic:** When only one player remains, game ends and winner is declared.
    - **Manual:** Moderator can end game early via confirmation alert (Game is voided, scores zeroed).
- **Workflow:**
    1. Players enter scores each round.
    2. App calculates totals and identifies leader (Crown icon).
    3. Game reaches conclusion -> transitions to Winner Screen.

### D. Game Conclusion & Winnings
- **Winner Screen:** Celebratory view with trophy, final standings, and winnings summary.
- **Fixed Payment Model:** 
    - Every eliminated/loser player pays the "Point Value" to the winner.
    - Winner receives the total "Pot" from all losers.
- **Workflow:**
    1. Game ends -> Server triggers `onGameEnd` Cloud Function.
    2. Server calculates balances and updates Friends list automatically.

### E. Friends & Settlements
- **Friends List:** Automatically populated with anyone you've played a game with.
- **Balances:** Real-time tracking of who owes whom.
- **Settlement History:** Vertical ledger showing every payment made or received.
- **Workflow:**
    1. User taps Friend -> views details and shared game history.
    2. User taps "Record Settlement" -> enters amount and note.
    3. Balance updates instantly across both devices.

### F. Game History
- **Recent Games:** List of past games with date, time, winner, and point value.
- **Shared History:** In Friend Details, view only the games played with that specific person.

## 5. Technical Details
- **Sync:** Real-time synchronization via Firestore snapshots.
- **Consistency:** Balanced-updating logic centralized in Firebase Cloud Functions to prevent race conditions.
- **Timezone:** All timestamps are synchronized to the player's local device timezone.
