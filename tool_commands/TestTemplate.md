# Test Creation Template

## Simple Request Format

```
Create a simple independent test app for:

**Feature:** [What you're testing]

**Test Scenarios:**
1. [Scenario 1] → Expected: [Result]
2. [Scenario 2] → Expected: [Result]
3. [Scenario 3] → Expected: [Result]

**Include:**
- Console test (run with: dart run_test.dart)
- Interactive Flutter UI test
- Mock services as needed
```

## Example

```
Create a simple independent test app for:

**Feature:** Returning user once-per-day logic

**Test Scenarios:**
1. Toggle ON + returning user → Expected: Blocked
2. Toggle OFF + first visit today → Expected: Allowed
3. Toggle OFF + already visited today → Expected: Blocked
4. Visit at 11:59pm, then 12:01am → Expected: Allowed (new day)

**Include:**
- Console test (run with: dart run_test.dart)
- Interactive Flutter UI test
- Mock services as needed
```

## You'll Get

- `/test_[feature]/` folder with:
  - `run_test.dart` - Console test with pass/fail
  - `test_app.dart` - Flutter UI with controls
  - `README.md` - How to run tests