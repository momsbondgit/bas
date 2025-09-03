
---

**Prompt (for AI agent):**

We are making updates to the *Girl Meets College* world. You must implement these updates using the **development\_principles.md process**.

### Update Requirements

1. **Access Flow Change**

   * Currently: users enter the world with no authentication.
   * New Flow:

     * When a user clicks *Join World*, a popup modal appears (centered on screen).
     * The modal must match the project’s theme (colors, fonts, styles).

2. **Popup Fields**

   * Field 1: *World Access Code*
   * Field 2: *World Nickname* (this will be the name displayed in rituals).
   * Copywriting for both fields should use **Gen Z style language** (casual, playful, not corporate).

3. **Account Creation**

   * Submitting the popup creates a **simple account** tied to that access code + nickname.
   * This is the only form of account creation.
   * No email, no password, no extra onboarding — just **this 2-step process**.
   * The account must be trackable in the backend. (firebase)

---

**Key Notes:**

* Popup = styled modal, not separate page.
* Authentication = lightweight, only access code + nickname.
* Everything must follow the **development\_principles.md** (delete unnecessary, keep simple, elegant, safe).

---
