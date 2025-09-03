
# 🔧 Firebase Write Optimization — AI Agent Prompt

You must implement these updates using the **development\_principles.md process**.
Goal: **Reduce heavy writes to Firebase while preserving core ritual functionality.**

---

## 1. Posts System (`PostService`)

**Collection:** `posts`

### Rules

* **Keep:**

  * User posts (one write per confession/post).
  * Admin posts (with special flags).
  * Post edits (rare).
  * Post deletions (admin only).

* **Change:**

  * **Reactions** → ❌ Do **not** store in Firebase.

    * Reactions should be local-only (client state).
    * No counters in Firestore.

---

## 2. Authentication System (`AuthService`)

**Collection:** `accounts`

### Rules

* ✅ Keep as is.
* One write per account creation (`anon_uid + access code + nickname`).
* No extra auth layers (lightweight only).

---

## 3. Ritual Queue System (`RitualQueueService`)

**Collections:** `ritual_queue`, `ritual_messages`

### Rules

* **Queue positions:**

  * Created once at session start.
  * ✅ Prefer local (client) creation instead of Firebase.
  * Each client gets one write: queue assignment + turn info.

* **Turn management:**

  * Delivered once to each client at ritual start.
  * No mid-session writes needed (session ends when everyone finishes).

* **Messages:**

  * ✅ Only **user messages** get stored in Firebase.
  * Bot messages and ephemeral events (like typing) → client-only.

* **Message reactions:**

  * ❌ Remove from Firebase.
  * Use local UI state only.

* **Message updates:**

  * Rare; keep only if absolutely needed.

---

## 4. Presence Tracking (`PresenceService`)

**Collection:** `presence_home`

### Rules

* ❌ Delete this service completely.
* No 20-second presence writes.
* No session start/stop presence writes.
* No cleanup operations.
* Presence will not be tracked in MVP.

---

## 5. Typing Indicators (`TypingIndicatorService`)

**Collection:** `typing_indicators`

### Rules

* ❌ Delete this service completely.
* No typing indicator writes to Firebase.
* Replace with static UI state:

  * Bots → always display `<BotName> is typing…` (with dots).
  * Users → display `"It’s your turn"` when active.
* No animations, no backend writes.

---

# ✅ Summary of Changes

* Posts → keep posts, kill reactions.
* Auth → keep.
* Ritual Queue → one-time assignment, client-managed; only user messages stored.
* Presence → delete.
* Typing → delete; replace with static state.

---

This is the **lean MVP design**. Every feature must justify its writes. If the ritual still works without it, delete it.

---