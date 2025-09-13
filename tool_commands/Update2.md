Got it — I’ll rewrite your instructions into a **clear, step-by-step execution prompt** for your AI agent, no fluff, just precise implementation details:

---

# **Task: World Updates – Girls World**

## 1. **Change Topic of the Day**

* World: `GirlMeetsCollegeWorld`
* Update `topicOfDay` to:

  > *“ok… what’s the weirdest or most annoying thing u seen in Lions Gate so far 👀💀”*

---

## 2. **Change Reactions Section**

* Replace reactions list with:

  * `LMFAOOO 😭`
  * `so real 💅`
  * `nah that’s wild 💀`

---

## 3. **Queue Section Position**

* Move queue display **below the comment section**.
* Remove queue from inside the comment section.

---

## 4. **Goodbye Popup (Session End Flow)**

* When the **last person in the queue finishes**, instead of session end screen:

  * Show a **popup modal** (same theme/design as “enter world” popup).
  * This is the **Goodbye Section**.

### Popup Features

1. **30-second timer** visible to all users.
2. **Input field** for user to type a goodbye message.
3. **Live reaction stream** (all goodbye messages + bot goodbyes fade in/out like chat).

---

## 5. **Bot Goodbye Updates**

* Extend bot model with a new field:

  * `bot.goodbyeText` = list of possible goodbye messages.
* On goodbye popup, each bot sends a random goodbye from this list.
* Bots keep existing `nickname` and `responses` but now also include `goodbyeText`.

---

## 6. **Flow Recap**

1. Last user finishes their turn.
2. Trigger Goodbye Popup.
3. Popup runs for 30 seconds:

   * Users type goodbyes.
   * Bots send goodbye texts.
   * Messages fade in/out like live chat.
4. After 30 seconds, session ends.

---