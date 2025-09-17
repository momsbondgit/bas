

# **Implementation Principles**

## 1. **Guiding Rules**

1. **Bare minimum only**

   * Strip scope down until it breaks.
   * Add back only what is strictly necessary for functionality.

2. **MVVM, simplest possible**

   * Follow the app’s existing MVVM pattern.
   * No extra layers or abstractions.
   * No third-party dependencies unless absolutely unavoidable.

3. **Confirm before coding each step**

   * Developer must always state the **plan** first (see Confirmation Protocol).
   * Wait for explicit **“Approved”** before writing any code.
   * Repeat this confirmation loop for every step.

4. **Reuse before adding**

   * Always check if existing logic or methods can be reused.
   * Do not create new methods or add complexity unless absolutely necessary.

---

## 2. **Confirmation Protocol**

For **every change step**, the developer must post:

**“Step N — Plan to implement:”**

* **Files to add/edit** → exact paths (e.g., `lib/services/feedback_service.dart`)
* **Data structures / functions** → names + signatures (e.g., `Future<FeedbackModel> generateFeedback(...)`)
* **Inclusions / exclusions** → what will and will not be done
* **Test cases** → list of validations to confirm implementation

---

## 3. **Questions Protocol**

* Always ask questions if unsure.
* Never make assumptions.
* Keep asking until the task is **100% clear**.

---

## 4. **Simplicity Protocol**

* Every implementation must reduce or maintain simplicity.
* Complexity should never be introduced.
* **Simplify over all complexity** — this is the default rule.

---

## 5. **don't touch rule**

* Dont not touch or change any other functionatity that is not related to the task at hand. 
* if you must change code not related to the task at hand then you must confirm with and wait for my approve.

---


⚠️ **Do not write code** until receiving explicit **“Approved”** reply.
Once approved, implement **only** what was confirmed.

---