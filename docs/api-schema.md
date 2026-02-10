# Rummy Scorekeeper API Schema

**Version:** 1.0  
**Last Updated:** 2026-01-30  
**Status:** Active

This document defines the data models and API contract between the iOS app and Firebase backend. Both implementations must stay synchronized with this schema.

---

## Data Models

### GameRoom

Represents a game session/room.

| Field | Type | Required | Constraints | Description |
|-------|------|----------|-------------|-------------|
| `id` | String | ✅ | 6 alphanumeric chars, uppercase | Unique room code (e.g., "A1B2C3") |
| `pointLimit` | Int | ✅ | 100-350 | Target score to end game |
| `pointValue` | Int | ✅ | > 0 | Dollar value per point (cents) |
| `currentRound` | Int | ✅ | 1-6 | Current round number |
| `isStarted` | Bool | ✅ | - | Whether game has started |
| `players` | [Player] | ✅ | 2-10 players | Array of players in room |
| `createdAt` | Timestamp | ✅ | - | Room creation time (Firebase only) |
| `createdBy` | String | ✅ | UUID string | Moderator's user ID (Firebase only) |

**Validation:**
- Room code must be unique
- At least 2 players required to start
- Only moderator can start game

**iOS Type:**
```swift
struct GameRoom: Identifiable {
    let id: String
    let pointLimit: Int
    let pointValue: Int
    var players: [Player]
    var currentRound: Int
    var isStarted: Bool
}
```

**Firebase Type:**
```typescript
interface GameRoom {
  id: string;
  pointLimit: number;
  pointValue: number;
  players: Player[];
  currentRound: number;
  isStarted: boolean;
  createdAt: Timestamp;
  createdBy: string;
}
```

---

### Player

Represents a player in a room.

| Field | Type | Required | Constraints | Description |
|-------|------|----------|-------------|-------------|
| `id` | UUID (String in Firebase) | ✅ | Valid UUID | Unique player identifier |
| `name` | String | ✅ | 1-50 chars | Display name |
| `isReady` | Bool | ✅ | - | Ready to start game |
| `isModerator` | Bool | ✅ | - | Room creator/host |
| `scores` | [Int] | ✅ | Empty or 6 elements | Score per round (0-indexed) |

**Computed:**
- `totalScore` = sum of all scores

**Validation:**
- Only one moderator per room
- Moderator is always ready by default
- Scores array initialized to `[0,0,0,0,0,0]` when game starts

**iOS Type:**
```swift
struct Player: Identifiable {
    let id: UUID
    let name: String
    var isReady: Bool
    var isModerator: Bool
    var scores: [Int]
    
    var totalScore: Int { 
        scores.reduce(0, +) 
    }
}
```

**Firebase Type:**
```typescript
interface Player {
  id: string;  // UUID as string
  name: string;
  isReady: boolean;
  isModerator: boolean;
  scores: number[];
}
```

---

### RoomServiceResult

Response when creating or joining a room.

| Field | Type | Description |
|-------|------|-------------|
| `room` | GameRoom | The full room object |
| `currentUserId` | UUID (String in Firebase) | The current user's player ID |

**iOS Type:**
```swift
struct RoomServiceResult {
    let room: GameRoom
    let currentUserId: UUID
}
```

**Firebase Response:**
```json
{
  "room": { /* GameRoom object */ },
  "currentUserId": "uuid-string"
}
```

---

## API Operations

### 1. Create Room

**Operation:** `createRoom`  
**Method:** POST (REST) or Firestore write  
**Authorization:** Authenticated user

**Input:**
```swift
pointLimit: Int    // 100-350
pointValue: Int    // > 0, in cents
playerCount: Int   // 2-10 (stored but not enforced yet)
```

**Process:**
1. Generate unique 6-char room code
2. Create room with moderator as first player
3. Set moderator as `isReady: true`, `isModerator: true`
4. Return room + currentUserId

**Output:** `RoomServiceResult`

**Errors:**
- `invalidInput` — validation failed
- `networkError` — connection issue

---

### 2. Join Room

**Operation:** `joinRoom`  
**Method:** POST (REST) or Firestore transaction  
**Authorization:** Authenticated user

**Input:**
```swift
code: String        // 6-char room code
playerName: String  // Display name
```

**Process:**
1. Validate room exists and not full
2. Add player to room.players array
3. Set player as `isReady: false`, `isModerator: false`
4. Return room + currentUserId

**Output:** `RoomServiceResult`

**Errors:**
- `roomNotFound` — invalid code
- `roomFull` — max players reached
- `invalidRoomCode` — malformed code

---

### 3. Set Ready

**Operation:** `setReady`  
**Method:** PUT (REST) or Firestore update  
**Authorization:** Authenticated user, must be in room

**Input:**
```swift
roomCode: String
playerId: UUID
ready: Bool
```

**Process:**
1. Find player in room
2. Update `isReady` field
3. Return updated room

**Output:** `GameRoom`

**Errors:**
- `roomNotFound`
- `playerNotFound`
- `notModerator` (if trying to set other players' ready state)

---

### 4. Start Game

**Operation:** `startGame`  
**Method:** POST (REST) or Firestore transaction  
**Authorization:** Room moderator only

**Input:**
```swift
roomCode: String
```

**Process:**
1. Verify caller is moderator
2. Check all players are ready
3. Check min 2 players
4. Set `isStarted: true`
5. Initialize all players' scores to `[0,0,0,0,0,0]`
6. Return updated room

**Output:** `GameRoom`

**Errors:**
- `notModerator`
- `roomNotFound`
- `invalidState` — not enough players or not all ready

---

### 5. Leave Room

**Operation:** `leaveRoom`  
**Method:** DELETE (REST) or Firestore transaction  
**Authorization:** Authenticated user

**Input:**
```swift
roomCode: String
playerId: UUID
```

**Process:**
1. Remove player from room.players
2. If no players remain, delete room
3. If moderator leaves, assign new moderator (first remaining player)

**Output:** Success (no data) or error

**Errors:**
- `roomNotFound`
- `playerNotFound`

---

### 6. Observe Room

**Operation:** `observeRoom`  
**Method:** Real-time listener (Firestore snapshot) or WebSocket  
**Authorization:** Authenticated user

**Input:**
```swift
code: String  // Room code
```

**Process:**
1. Subscribe to room document changes
2. Stream updates to client
3. Client receives new GameRoom on every change

**Output:** `AsyncStream<GameRoom?>`

**Lifecycle:**
- Stream starts when called
- Emits on every room change (player join, ready toggle, score update)
- Ends when client cancels or room is deleted

---

## Error Codes

All errors follow this structure:

| Code | Description | HTTP Status | When |
|------|-------------|-------------|------|
| `roomNotFound` | Room doesn't exist | 404 | Invalid room code |
| `roomFull` | Max players reached | 409 | Join when at capacity |
| `notModerator` | Action requires moderator | 403 | Non-mod tries to start game |
| `playerNotFound` | Player not in room | 404 | Invalid player ID |
| `invalidRoomCode` | Malformed code | 400 | Code not 6 chars or invalid format |
| `invalidState` | Operation not allowed | 409 | Start game when not ready |
| `networkError` | Connection/server issue | 500 | Network failure |

**iOS Type:**
```swift
enum RoomServiceError: Error {
    case roomNotFound
    case roomFull
    case notModerator
    case playerNotFound
    case invalidRoomCode
    case networkError(Error)
}
```

**Firebase Response:**
```json
{
  "error": {
    "code": "ROOM_NOT_FOUND",
    "message": "Room not found"
  }
}
```

---

## Firestore Data Structure

```
/rooms/{roomCode}
  ├── id: string
  ├── pointLimit: number
  ├── pointValue: number
  ├── currentRound: number
  ├── isStarted: boolean
  ├── createdAt: timestamp
  ├── createdBy: string
  └── /players/{playerId}
      ├── id: string
      ├── name: string
      ├── isReady: boolean
      ├── isModerator: boolean
      └── scores: number[]
```

**Security Rules:**
- Anyone can read room (for QR join)
- Only authenticated users can create rooms
- Only room participants can update ready status
- Only moderator can start game
- Only participants can leave

---

## Change Log

### v1.0 (2026-01-30)
- Initial schema
- GameRoom, Player, RoomServiceResult models
- 6 core API operations
- Error codes defined

---

## Migration Notes

When making breaking changes:
1. Update version number at top
2. Document change in Change Log
3. Update iOS models in `Models/GameRoom.swift`
4. Update Firebase types in `functions/src/types.ts`
5. Update both RoomService implementations
6. Update Firestore rules if needed
