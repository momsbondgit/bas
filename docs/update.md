Here’s a clean **Markdown spec** you can hand to your AI agent. It turns your notes into an actionable build prompt.

---

# **Bot Simulation Specification**

You must follow the **development\_principles.md** process when implementing this. Keep everything minimal, auditable, and simple.

---

## **Goal**

Simulate human-like participation in rituals by assigning each user a **unique mix of pre-defined bots**. Bots must appear as normal users  and generate distinct responses so the experience doesn’t look scripted.

---

## **Requirements**

### 1. Bot Pool

* Create **10 total bots**.
* Each bot has:

  * **bot\_id** (static, unique)
  * **nickname** (shown in UI)
  * **quine\_responses\[]** (list of unique one-liners it can use).

### 2. Bot Assignment

* When a **new user** joins a world for the first time:

  * Assign them a **subset of bots** (randomized mix).
  * Store assignment in Firestore:

    ```
    users/{user_id}/assigned_bots/{bot_id}:
      nickname
      assigned_at
    ```
  * Different users get different mixes → no two tables look identical.

### 3. Bot Behavior in Ritual

* Bots must behave like users in the **turn queue**:

  * Each bot is inserted into the ritual queue along with real users.
  * The bot’s nickname shows in the queue just like a real participant.
  

```

### 5. Turn Queue Logic

* Queue is a mix of **real user\_ids + assigned bot\_ids**.
* Bots always respect queue order.
* Ensure only **one active speaker** at a time.

---

## **Constraints**

* No global randomness → each user’s assigned bots are persistent.
* Bots must be indistinguishable from real users in **queue + typing indicator**.
* Keep simple → no AI generation, only pre-written quine responses. also try to use areas where we are already using writes to firebase to set up which bots gets assigned to what users so we can save on reads and writes 

---

## **Success Criteria**

* Two users logging in at the same time see **different bots** in their queue.
* Bots type and post with delays, making them feel human.
* Bots never repeat exact same responses across two users in the same ritual. at least not in the same order 

---
