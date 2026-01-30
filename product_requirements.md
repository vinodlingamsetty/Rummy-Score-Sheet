# Rummy Scorekeeper — Product Requirements

## 1. Product Overview

**Rummy Scorekeeper** is a premium iOS app for tracking scores during Indian Rummy games. It offers a dark-mode-first, "Liquid Glass" visual style and is designed for quick, fluid score entry during play.

---

## 2. Target Users

- Casual to regular Indian Rummy players
- Players who want a polished, distraction-free scorekeeping experience
- Users who prefer dark mode and modern aesthetics

---

## 3. Core Features

### 3.1 Home
- Primary entry point and navigation hub
- Quick access to start a new game or resume an existing one
- Overview of recent games and statistics

### 3.2 Game
- Active game / scorekeeping flow
- Per-round score entry for multiple players
- Cumulative totals per player
- Support for common Rummy variants (sets, runs, knock bonuses, etc.)
- Fast, low-friction input optimized for gameplay

### 3.3 Friends
- Manage friends / players
- Reuse saved players across games
- Invite or share results (future)

### 3.4 Profile
- User account and preferences
- Settings and customization
- App information and support

---

## 4. Technical Requirements

| Area | Requirement |
|------|-------------|
| Platform | iOS 17+ |
| Framework | SwiftUI |
| Architecture | MVVM |
| Local persistence | SwiftData (Local-First) |
| Backend | Firebase (Auth, Firestore) |
| Dependencies | Swift Package Manager |

---

## 5. Design Requirements

- **Theme:** Dark mode only
- **Backgrounds:** Deep gradients (Deep Navy #0f172a to Black)
- **Materials:** Heavy use of `UltraThinMaterial` ("Liquid Glass")
- **Typography:** SF Pro Rounded (`Font.design(.rounded)`)
- **Haptics:** Feedback on key actions (e.g., score entry, button taps)
- **Animations:** `.spring()` or `.bouncy`; avoid linear
- **Layout:** Responsive across iPhone and iPad

---

## 6. Non-Functional Requirements

- **Performance:** Smooth, responsive UI during gameplay
- **Offline:** Local-first; core scorekeeping works without connectivity
- **Data:** Sync via Firebase when online (optional)
- **Accessibility:** Clear, readable UI; support VoiceOver where relevant

---

## 7. Out of Scope (Current Version)

- Light mode
- Other card games
- In-app purchases or subscriptions
- Real-time multiplayer scoring

---

## 8. Success Criteria

- Score entry is fast enough for live play
- UI feels premium (animations, haptics, visual polish)
- Offline functionality for all core scorekeeping flows
- Intuitive flow for new and returning players
