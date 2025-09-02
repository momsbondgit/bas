#updates 

When implementing bot posting behavior:

1. **Typing Simulation**

   * Bot users should not post instantly.
   * When it is a bot’s turn, display the message in the feed:

     ```
     [BotName] is typing…
     ```
   * Keep this typing indicator visible for **10 seconds** before the bot’s confession appears.

2. **Post Delay + Reactions**

   * After 10 seconds, the bot’s confession is posted to the feed.
   * Immediately after posting, start the **reaction timer** (same as with real users).

3. **Looping Through Bots**

   * Once the reaction timer for the current bot ends, move to the next bot in the queue.
   * Repeat the same cycle (Typing → Post → Reaction) for all remaining bots.

4. **Consistency with Development Principles**

   * Follow the guidelines in **Development_priciples.md** for implementation.
   * Ensure code remains simple, state-driven, and testable.
   * No extra abstractions beyond what is needed for this feature.

