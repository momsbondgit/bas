Use implementation.md to excute the task below: 
---

# **AI Agent Task: Update Topic of the Day Layout with Image Rounds**

## Layout Changes

1. **Remove Heading**

   * Remove the current heading above the Topic of the Day.

2. **Move Topic of the Day Up**

   * Shift the Topic of the Day section upward to free space below it.

3. **Image Row**

   * Add a row that displays **3 images side by side**.
   * Images are uploaded via the **Admin Dashboard**. 
   * Images must be large enough for mobile visibility, but balanced so the UI is not cluttered.

---

## Admin Dashboard Updates

* Allow uploading up to **9 images** for a session.
* Only **3 images are shown at a time**.
* Admins control the image set, but users see them in **rounds**.

---

## User Experience Flow

1. **Queue Round 1**

   * Users see the first 3 images under the Topic of the Day.
   * No button shown yet.

2. **After Queue Ends**

   * Show a popup button: **“Next Round”**. - instead of Bye popup
   * Every user must confirm the popup.

3. **Next Rounds**

   * On confirm, the next 3 images replace the previous ones.
   * The queue restarts.
   * This happens a total of **3 rounds** (9 images max).

4. **Session End**

   * After the 3rd round ends, the session finishes.
   * Show the **Bye Popup** to all users.

---

## Goal

* Replace the static heading with a **dynamic Topic + Images flow**.
* Support **3 image rounds**, with user confirmation required to advance.
* Ensure clean UI on mobile (big enough images, not cluttered).

---
