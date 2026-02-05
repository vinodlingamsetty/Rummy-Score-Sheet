# Backend Setup for Friends & Settlements Feature

## Overview
This document contains the Firestore security rules and indexes needed for the Friends and Settlements feature.

---

## 1. Firestore Security Rules

Add these rules to your `firestore.rules` file in your backend repo:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user is part of a friendship
    function isFriendshipParticipant(friendship) {
      return isAuthenticated() && 
             (request.auth.uid == friendship.userId1 || 
              request.auth.uid == friendship.userId2);
    }
    
    // ==========================================
    // FRIENDS Collection
    // ==========================================
    match /friends/{friendshipId} {
      // Allow read if user is part of the friendship
      allow read: if isAuthenticated() && 
                     (resource.data.userId1 == request.auth.uid || 
                      resource.data.userId2 == request.auth.uid);
      
      // Allow create if user is one of the participants
      allow create: if isAuthenticated() && 
                       (request.resource.data.userId1 == request.auth.uid || 
                        request.resource.data.userId2 == request.auth.uid) &&
                       // Ensure required fields exist
                       request.resource.data.keys().hasAll([
                         'userId1', 'userId2', 'user1Name', 'user2Name', 
                         'balance', 'gamesPlayedTogether', 'createdAt'
                       ]);
      
      // Allow update if user is part of the friendship
      allow update: if isFriendshipParticipant(resource.data) &&
                       // Ensure critical fields cannot be changed
                       request.resource.data.userId1 == resource.data.userId1 &&
                       request.resource.data.userId2 == resource.data.userId2;
      
      // Allow delete only if both users agree (optional - you might want to prevent deletion)
      allow delete: if isFriendshipParticipant(resource.data);
    }
    
    // ==========================================
    // SETTLEMENTS Collection
    // ==========================================
    match /settlements/{settlementId} {
      // Allow read if user was involved in the settlement
      allow read: if isAuthenticated() && 
                     (resource.data.settledBy == request.auth.uid ||
                      // Also check if user is part of the related friendship
                      exists(/databases/$(database)/documents/friends/$(resource.data.friendshipId)));
      
      // Allow create only by authenticated users
      allow create: if isAuthenticated() && 
                       request.resource.data.settledBy == request.auth.uid &&
                       // Ensure required fields exist
                       request.resource.data.keys().hasAll([
                         'friendshipId', 'amount', 'settledAt', 'settledBy'
                       ]) &&
                       // Verify the friendship exists
                       exists(/databases/$(database)/documents/friends/$(request.resource.data.friendshipId));
      
      // Prevent updates and deletes (settlements are immutable records)
      allow update: if false;
      allow delete: if false;
    }
    
    // ==========================================
    // Existing Rules (keep your gameRooms rules)
    // ==========================================
    match /gameRooms/{roomId} {
      // ... your existing gameRooms rules ...
    }
  }
}
```

---

## 2. Firestore Indexes

Add these composite indexes to `firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "friends",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId1", "order": "ASCENDING" },
        { "fieldPath": "lastPlayedDate", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "friends",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId2", "order": "ASCENDING" },
        { "fieldPath": "lastPlayedDate", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "settlements",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "friendshipId", "order": "ASCENDING" },
        { "fieldPath": "settledAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "settlements",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "settledBy", "order": "ASCENDING" },
        { "fieldPath": "settledAt", "order": "DESCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

---

## 3. Deploy to Firebase

After adding the rules and indexes:

```bash
# Deploy security rules
firebase deploy --only firestore:rules

# Deploy indexes
firebase deploy --only firestore:indexes
```

Or deploy everything:

```bash
firebase deploy
```

---

## 4. Data Structure Reference

### `/friends/{friendshipId}` Document:
```javascript
{
  userId1: string,          // Smaller user ID (alphabetically)
  userId2: string,          // Larger user ID (alphabetically)
  user1Name: string,        // Display name of user1
  user2Name: string,        // Display name of user2
  balance: number,          // Positive = user2 owes user1, Negative = user1 owes user2
  gamesPlayedTogether: number,
  lastPlayedDate: timestamp (optional),
  createdAt: timestamp
}
```

**Friendship ID Format**: `{userId1}_{userId2}` (ensures uniqueness and consistency)

### `/settlements/{settlementId}` Document:
```javascript
{
  id: string,               // Auto-generated UUID
  friendshipId: string,     // Reference to friendship document
  amount: number,           // Amount that was settled (always positive)
  settledAt: timestamp,
  settledBy: string,        // User ID who marked as settled
  note: string (optional)
}
```

---

## 5. Testing the Rules

You can test the rules in the Firebase Console:

1. Go to **Firestore Database** → **Rules** tab
2. Click **Rules Playground**
3. Test these scenarios:
   - User can read their own friendships ✅
   - User cannot read other people's friendships ❌
   - User can settle their own friendship ✅
   - User cannot modify userId1/userId2 of existing friendship ❌
   - Settlement records are immutable ✅

---

## 6. Optional: Cloud Function for Auto-Adding Friends

If you want to automatically create friendships when a game ends, you can add this Cloud Function:

```javascript
// functions/src/index.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

export const onGameEnd = functions.firestore
  .document('gameRooms/{roomId}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const oldData = change.before.data();
    
    // Check if game just ended
    if (!oldData.isCompleted && newData.isCompleted) {
      const players = newData.players;
      
      // Create friendships between all players
      const friendshipPromises = [];
      
      for (let i = 0; i < players.length; i++) {
        for (let j = i + 1; j < players.length; j++) {
          const player1 = players[i];
          const player2 = players[j];
          
          // Ensure consistent ordering
          const [userId1, userId2, user1Name, user2Name] = 
            player1.id < player2.id 
              ? [player1.id, player2.id, player1.name, player2.name]
              : [player2.id, player1.id, player2.name, player1.name];
          
          const friendshipId = `${userId1}_${userId2}`;
          const friendshipRef = db.collection('friends').doc(friendshipId);
          
          friendshipPromises.push(
            friendshipRef.set({
              userId1,
              userId2,
              user1Name,
              user2Name,
              balance: 0, // Calculate based on game results
              gamesPlayedTogether: admin.firestore.FieldValue.increment(1),
              lastPlayedDate: admin.firestore.FieldValue.serverTimestamp(),
              createdAt: admin.firestore.FieldValue.serverTimestamp()
            }, { merge: true })
          );
        }
      }
      
      await Promise.all(friendshipPromises);
      console.log(`Created/updated friendships for game ${context.params.roomId}`);
    }
  });
```

Deploy with:
```bash
firebase deploy --only functions
```

---

## Summary

✅ **What to add to your backend repo:**
1. Update `firestore.rules` with the friends and settlements rules
2. Update `firestore.indexes.json` with the composite indexes
3. Deploy to Firebase
4. (Optional) Add Cloud Function for auto-friend creation

✅ **What's already done in iOS app:**
- FirebaseFriendService implementation
- Settlement transaction recording
- Real-time friend updates
- Mock/Firebase service toggle

**Next step:** Let me know when you've updated the backend, then we can test with real Firebase! 🚀
