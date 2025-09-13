# Vibe Check System Implementation Plan


Use Implementation.md to implement the changes below: 

## Overview
Replace gender-based selection with a personality-based vibe check system that assigns users to bot groups matching their personality style.

## Implementation Steps

### 1. **Extend the World Access Modal**
- After users enter code and nickname, keep them in the same popup
- Add a progress bar at the top showing: Step 1 (Code) → Step 2 (Nickname) → Step 3 (Vibe Check)
- Transition smoothly between sections without closing the modal
- Match existing modal styling and theme

### 2. **Add Vibe Check Questions**
- Show 3 personality questions one at a time after nickname submission
- Each question has 2 button options (A or B)
- Progress bar fills up as they answer each question (33% → 66% → 100%)
- Keep the casual, Gen-Z friendly language style
- Questions:
  1. "Your crew is going out Friday night. You're…"
     - A: "Already putting on the fit 💃"
     - B: "Staying in w snacks + Netflix 🍿"
  2. "You're chilling in your dorm and 6 people walk in. You…"
     - A: "Say hi first and jump in the convo 👋"
     - B: "Kick back, let them come to you 😏"
  3. "If you hear someone spreading rumors about you, you're…"
     - A: "Pulling up receipts + clapping back 🔥"
     - B: "Laughing it off with the squad 💀"

### 3. **Remove All Gender-Related Code**
- Remove any gender fields from user profiles and posts
- Clean up gender references in confessions cards
- Remove gender-based world routing logic
- Update any UI components that show gender information

### 4. **Set Up Bot Table System**
- Create two bot tables:
  - Table 1 (Chaotic/Edgy): For users who answer mostly A's (2+ out of 3)
  - Table 2 (Goofy/Soft): For users who answer mostly B's (2+ out of 3)
- Each table has 5 unique bot personalities with distinct response patterns
- Table 1 bots: Bold, provocative, uses roasting humor
- Table 2 bots: Self-deprecating, relatable, softer humor
- Bots stay with the user permanently once assigned
- remove old bot logic 

### 5. **Update User Storage**
- Add new fields to user model:
  - `tableId`: String ('1' or '2')
  - `vibeCheckAnswers`: Map of answers (q1: 'A', q2: 'B', etc.)
  - `assignedBots`: List of 5 bot IDs
  - `firstWorldEntry`: Timestamp
  - `hasEnteredWorld`: Boolean
- Save user's vibe check answers
- Store their assigned table ID
- Remember their 5 assigned bots permanently
- remove old logic that we no longer need 

### 6. **Fix Queue Behavior**
- Always show user at position 3 in the queue (regardless of actual position)
- Display their 5 assigned bots in the queue
- Bots interact based on their table's personality style
- Maintain consistent bot order for each user

### 7. **Add Admin Controls**
- Add toggle to allow/block returning users from re-entering worlds
- Dashboard showing user distribution across tables (Table 1 vs Table 2 count)
- Analytics for vibe check completion rates
- Display bot table statistics in admin panel
- also simpliy the admin dashbaord to a simple one pager with all the things we need 

### 8. **Handle Return Users**
- First-time users: Full flow (code → nickname → vibe check → world entry)
- Returning users: Skip vibe check, use existing bot assignments
- Check admin toggle to determine if re-entry is allowed
- If re-entry blocked, show appropriate message (which says something like: come back tomorrow for the next etc.. )

### 9. **Style Consistency**
- Use the same rounded corners and soft colors as existing UI
- Match button styles from the rest of the app (black primary buttons, bordered secondary)
- Keep the progress bar subtle and clean (thin line or dots)
- Maintain the existing color themes for each world (pink/peach for girl, blue for guy)
- Use existing font families (SF Pro, SF Pro Rounded)

### 10. **Testing Checklist**
- Verify vibe check flow works end-to-end
- Test that majority rule assigns correct table (2+ A's = Table 1, 2+ B's = Table 2)
- Confirm bot assignments persist across sessions
- Test admin toggle for world re-entry
- Verify returning users skip vibe check
- Check that queue always shows position 3
- Ensure all gender references are removed

## Key Changes Summary
- **OUT**: Gender selection ("How do you identify?")
- **IN**: Vibe check personality quiz (3 questions)
- **OUT**: Gender-based separation
- **IN**: Personality-based bot table assignment
- **PERSISTENT**: Users keep the same 5 bots forever
- **CONTROLLED**: Admin can toggle world re-entry access

## Benefits
- More inclusive (no gender selection required)
- Better personalization (bots match user personality)
- Increased engagement (tailored bot interactions)
- Simplified onboarding (all in one modal flow)