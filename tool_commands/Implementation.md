
---

## Guiding Rules

1. **Bare minimum only**  
   - Strip the scope down until it breaks.  
   - Add back only what’s strictly necessary for functionality.

2. **MVVM, simplest possible**  
   - Follow the app’s existing MVVM pattern.  
   - No extra layers or abstractions.  
   - No third-party dependencies unless absolutely unavoidable.

3. **Confirm before coding each step**  
   - Developer must **state the plan** (files, functions, exclusions, and test cases).  
   - Wait for explicit **“Approved”** confirmation before proceeding.  
   - Repeat this loop for every step.

4. **instead of creating new metnods and logic**
   - check the code base to see if there is already logic that we can use instead of makin know ones. 

---

## okayuConfirmation Protocol

For **every change step**, the developer must post:

**“Step N — Plan to implement:”**
- **Files to add/edit**: exact paths (e.g., `lib/services/feedback_service.dart`)  
- **Data structures / functions**: names + signatures (e.g., `Future<FeedbackModel> generateFeedback(...)`)  
- **What will and will not be included**  
- **Test cases**: list of validations they will run  

** questions ** 
- ** always question me if you are are not sure about somthing never make things up theres should be no room for assuptions, keep asking me questions untill it super clear what you need to do. 

** key thing to keep in mind **
- ** everything that we do or implment has to be simple, simplify over all complexity we should not include complexity at all 

⚠️ Do not write code until receiving explicit **“Approved”** reply.  
Once approved, implement **only** what was confirmed.