Use Implementation.md to implement the follwoing task: 

---

# **AI Agent Task: Update Returning User Toggle Logic**

## Current Behavior

* **Toggle ON:** Returning users are fully blocked (can’t enter). ✅
* **Toggle OFF:** Returning users can enter and leave the world as many times as they want. ❌

## Problem

* When toggle is OFF, returning users see the **same bot responses** if they re-enter multiple times in one day.
* This breaks the experience since bots are pretending to be humans, and repeated responses ruin the illusion.

## Required Update

* **Toggle ON:** Keep current behavior → returning users are completely blocked.
* **Toggle OFF:** Change behavior so returning users can only enter the world **once per day**.

  * After their one session, they are blocked until the next day.

## Goal

* Prevent returning users from re-entering the same day and seeing recycled bot responses.
* Preserve the “magic” of the world while keeping toggle logic simple:

  * ON = no returning users at all.
  * OFF = returning users allowed, but **only one visit per day**.

---

