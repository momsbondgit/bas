
Use implementation.md file to implement the task below: 
---

# **AI Agent Task: Replace World Entry Popup with Lobby**

## Current Behavior

* Right now, clicking on the world opens a popup that asks for **code + username**.

## Required Update

* Replace this popup with a **lobby system**, similar to **Kahoot’s waiting screen** where players wait for others to join before starting.

### Lobby Features

1. **Heading / Message**

   * Display text like *“Waiting for your friends to join…”*.

2. **Username Input**

   * Ask each user for their **preferred username**.

3. **Real-Time Updates**

   * As friends join, their usernames appear in the lobby UI.
   * Every user in the lobby sees the updated list of who is online.

4. **Start Button**

   * When all intended friends are online, users click **Start**.
   * Only those users in the lobby are placed into the world together.

---

## Goal

* Change the flow from **code-entry popup** → to a **real-time friend lobby**.
* Make it work like Kahoot’s waiting room, where everyone can see who has joined before the game (world) begins.

---