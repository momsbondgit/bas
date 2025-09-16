i need you to implement the follwoing task below using the Implementation.md file: 

---

# **AI Agent Prompt: Redesign Admin Dashboard**

## 1. Compass Metrics (Core Tracking)

⚠️ Metrics include **real users only** — bots are excluded.
Each compass point = **one human need + one simple number**.

---

### **North – Belonging Proof**

* **Question:** Did they return? How many times?
* **Metric:** Number of returns per real user (D+1, D+2, etc.).
* **Indicator:**

  * ✅ Returned (with count, e.g., “3x”)
  * ○ Not returned
* **Meaning:** Shows if users feel **continuity** — same table, same cast, not reshuffled.

---

### **East – Flow Working**

* **Question:** Did they complete the full session?
* **Definition:** Completion = user reached the **Session End screen**.
* **Metric:** Sessions completed vs total attempts (e.g., `4/5`).
* **Indicator:** % completion rate.
* **Meaning:** Shows if users feel **rhythm** — start → middle → goodbye → “see you tomorrow.”

---

### **South – Voice / Recognition**

* **Question:** Did they get their voice in?
* **Metric:** Posts **per real user** (should be ≥1).
* **Indicator:** Count (e.g., `1 post`, `2 posts`).
* **Meaning:** Shows if users feel **seen** — they got their turn, their words landed.

---

### **West – Affection / Resonance**

* **Question:** Did they react emotionally?
* **Metric:** Total reactions made by **real users**.
* **Indicator:** Count (e.g., `5 reactions`).
* **Meaning:** Shows if users felt **emotional response** — laughter, empathy, or spice from the table.

---

## 2. User Organization in Dashboard

### **List View (Default)**

* Show a **simple table of all active real users**.
* Each row = one user.
* Columns:

  * Nickname
  * Partial User ID (shortened)
  * Status (Active, Completed, Returning)

---

### **Expanded View (On Click)**

* When admin clicks a user row → show **all four compass metrics expanded with full detail**.
* For each direction, display:

  * **Name + Direction**
  * **Question** (in plain language)
  * **Metric** (what we’re measuring)
  * **Indicator** (value or status)
  * **Meaning** (why this matters)

---

### **Collapse Back**

* When admin clicks the row again → collapse back to the **default user list**.

---

## 3. Why This Design Works

* **Scannable** at a glance → table view.
* **Drill-down with full clarity** → expanded view shows **everything** (question, metric, indicator, meaning).
* **Clean toggle** → one click expands, one click collapses.

---

## 4. Example Flow

* **Table View:**

  ```
  User A | ID123 | Active
  User B | ID456 | Returning
  ```

* **Click User A → Expanded View:**

  * **North (Belonging Proof)**

    * Question: Did they return? How many times?
    * Metric: Number of returns per real user.
    * Indicator: ✅ Returned 3x
    * Meaning: They felt continuity — same table, same cast.
  * **East (Flow Working)**

    * Question: Did they complete the full session?
    * Metric: 4/5 sessions completed.
    * Indicator: 80% completion.
    * Meaning: They experienced rhythm — start → middle → goodbye → tomorrow.
  * **South (Voice / Recognition)**

    * Question: Did they get their voice in?
    * Metric: 2 posts per real user.
    * Indicator: 2 posts.
    * Meaning: They felt seen — their words landed in the group.
  * **West (Affection / Resonance)**

    * Question: Did they react emotionally?
    * Metric: 5 reactions.
    * Indicator: Count = 5.
    * Meaning: They felt emotional response — laughter, empathy, spice.

* **Click User A again → Collapse:** back to table list.

----