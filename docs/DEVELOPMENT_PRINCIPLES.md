
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

---

## okayuConfirmation Protocol

For **every change step**, the developer must post:

**“Step N — Plan to implement:”**
- **Files to add/edit**: exact paths (e.g., `lib/services/feedback_service.dart`)  
- **Data structures / functions**: names + signatures (e.g., `Future<FeedbackModel> generateFeedback(...)`)  
- **What will and will not be included**  
- **Test cases**: list of validations they will run  

** questions ** 
- ** always question me if you are are not sure about somthing never make things up theres should be no room for assuptions. 

⚠️ Do not write code until receiving explicit **“Approved”** reply.  
Once approved, implement **only** what was confirmed.