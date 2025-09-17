Use Implementation.md protocols to fix the following bug: 

---

# **AI Agent Prompt: Fix World Rejection Bug**

## 1. Problem

* When a user is rejected because the world is full:

  * ✅ First attempt → user goes through vibe check flow → if full, they see the **World is Full popup** (this is correct).
  * ❌ On **refresh**:

    * User **skips the vibe check flow**.
    * Instead, they are automatically placed into a fallback world with bots named **Alex, Casey, Jordan, Riley, Quinn, and the user**.
* These fallback bots should not exist in the codebase.

---

## 2. Expected Behavior

For **rejected users** (world full):

1. On refresh or re-entry, user must **always go through the vibe check flow again**.
2. After vibe check, if the world is still full → show the **World is Full popup** again.
3. User should **never** be assigned to any fallback world with placeholder bots.

---

## 3. Fix Requirements

* Remove all fallback world logic (no Alex, Casey, Jordan, Riley, Quinn).
* Ensure refresh = restart from vibe check → world full check → popup.
* Popup must repeat consistently until space is available.

---

## 4. Goal

* Rejected users always have the **same consistent flow**:

  * Vibe check → World capacity check → Popup if full.
* No bypass, no hidden bot world, no exceptions.

---