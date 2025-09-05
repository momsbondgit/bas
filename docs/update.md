
---

# Prompt: Session End Screen + Multi-World Fixes

**Use development\_principles.md to implement.**

---

### Popup Copy Updates

* Remove current popup headings (“join the world bro” and the girl version).
* Replace heading with:
  **“No code, no access. Only members can invite.”**
* Remove sub-text (“share your college confessions…”).

---

### World Copy – Vibe Rules

**Girl World:**

1. One at a time — we’re not tryna overlap like the dorm Wi-Fi.
2. Don’t hold back — spill it like you’re dragging him in the group chat.
3. React to everyone — no silent scrolling, you’re in the circle.

**Guy World:**

1. One at a time — we’re not all yelling over Warzone comms.
2. Don’t hold back — speak up, you’re not chatting with shorties.
3. React to everyone — no sitting on mute like a NPC.

---

### Session End Screen Changes

* Update UI to match popup style but remember this screen is not a popup.
* Add **Instagram field** below **Phone Number field**.
* Copywriting:
  **“You’re a member now — only members can invite, just don’t give the code to lames.”**

  * **Drop your number** (fastest way we’ll send the next code).
  * If you’re on that *‘I don’t give my number out’* headass vibe → drop your IG, we’ll follow you from the private account.
* Functionality: Save both **phone number** and **Instagram handle** to Firebase.

---

### World Codes

* Each world requires its own **unique access code**.
* Example: Boy world has its own code, Girl world has a different one.

---

### Bug Fix

* Currently: users who sign into one world can automatically join the other world without re-auth.
* Fix: **Auto-login applies only within the same world.**

  * If a user signed into Girl world, they should still need to enter a valid code to join Guy world (and vice versa).

---
