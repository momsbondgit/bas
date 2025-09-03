Here’s a clean, copy-ready prompt for your AI dev:

---

# Task: Tweak “Turn queue” UI/logic

**Goal**
Simplify the Turn Queue section: rename the header, remove arrows, keep user order fixed, and move the highlight to the active user as turns advance.

**Requirements**

* Change header text to just: `Turn queue`.
* Beneath the header, render user names **in a fixed order** (no arrows, no reordering).
* Highlight the **current user** using the same highlight style we used previously for “current turn”.
* When the turn advances, **only the highlight moves** to the next user; the list order never changes.

**Behavior Examples**

```
[Turn queue]
User1  User2 (highlighted)  User3  User4

# After next turn:
[Turn queue]
User1  User2  User3 (highlighted)  User4
```

---
