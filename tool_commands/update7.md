i need you to implement the following task below using implementation.md's protocol: 

---

# **AI Agent Prompt: Make Bot Data Editable in Admin Dashboard**

## 1. Constraints

* ❌ No logic or functionality changes unless absolutely required.
* ✅ Only replace **hardcoded values** with editable variables.

---

## 2. Current Problem

* In **Girl World**, bot properties (`nickname`, `quineResponse`, `goodbyeText`) are **hardcoded** in the codebase.
* This makes them difficult to update without redeploying.

---

## 3. Expected Behavior

* Bot properties (`nickname`, `quineResponse`, `goodbyeText`) must be:

  * Stored in **Firebase** (middle layer).
  * Editable at any time via the **Admin Dashboard**.
  * Displayed in a new **“Bot Settings” section** directly under the **Maintenance section** in the Admin Dashboard.

---

## 4. Implementation Requirements

1. Replace hardcoded bot data with variables fetched from Firebase.
2. Add a new **Bot Settings panel** in the Admin Dashboard:

   * Editable fields for each bot’s `nickname`, `quineResponse`, and `goodbyeText`.
   * Save changes → update Firebase.
   * Firebase changes should sync in real time.
3. Keep scope minimal → only apply this to **Girl World bots** for now.

---

## 5. Goal

* Admins can update bot nicknames, responses, and goodbye texts **without code changes**.
* All changes propagate via Firebase and appear in the app instantly.


