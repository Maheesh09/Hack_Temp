# CP-Hackathon

A lightweight, reusable **C++17 competitive programming workspace** for Windows, designed for VS Code, PowerShell, MinGW-w64, and Python.

The workspace supports:

- Multiple independent problems
- Fast C++17 compilation
- Manual execution
- Automated test cases
- Expected-vs-actual output comparison
- Runtime error detection
- Basic execution-time measurement
- Brute-force solutions
- Random test generation
- Automated stress testing
- VS Code tasks
- VS Code debugging

---

## 1. Requirements

Make sure these are installed and available in your VS Code terminal:

- Windows
- VS Code
- PowerShell
- MinGW-w64 / g++
- C++17 support
- Python 3

Check your installations:

```powershell
g++ --version
```

```powershell
python --version
```

You should be able to run both commands successfully.

---

# 2. Project Structure

```text
CP-Hackathon/
│
├── .vscode/
│   ├── tasks.json
│   ├── launch.json
│   └── settings.json
│
├── problems/
│   │
│   ├── problem01/
│   │   ├── solution.cpp
│   │   ├── brute.cpp
│   │   ├── generator.py
│   │   └── tests/
│   │       ├── test01.in
│   │       ├── test01.out
│   │       ├── test02.in
│   │       ├── test02.out
│   │       └── failing_test.in
│   │
│   ├── problem02/
│   │   └── ...
│   │
│   └── problem03/
│       └── ...
│
├── templates/
│   └── main.cpp
│
├── tools/
│   ├── run.ps1
│   ├── run_tests.ps1
│   └── stress_test.py
│
├── build/
│
└── README.md
```

### Directory purpose

| Directory/File | Purpose |
|---|---|
| `.vscode/` | VS Code configuration |
| `problems/` | All competition problems |
| `templates/` | Reusable C++ templates |
| `tools/` | Test and stress-testing utilities |
| `build/` | Compiled `.exe` files |
| `README.md` | Workspace documentation |

---

# 3. Competitive Programming Template

The default template is:

```cpp
#include <bits/stdc++.h>
using namespace std;

using ll = long long;

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    // solution

    return 0;
}
```

The template is intentionally kept simple.

Add additional utilities only when the problem actually requires them.

---

# 4. Creating a New Problem

When you receive a new problem, create a new directory.

For example:

```text
problems/problem04/
```

Create the tests directory:

```text
problems/problem04/tests/
```

Then copy:

```text
templates/main.cpp
```

to:

```text
problems/problem04/solution.cpp
```

The minimum structure is:

```text
problem04/
├── solution.cpp
└── tests/
```

You only need these files if you want stress testing:

```text
problem04/
├── solution.cpp
├── brute.cpp
├── generator.py
└── tests/
```

---

# 5. Writing the Solution

Write your optimized solution in:

```text
problems/problem04/solution.cpp
```

Example:

```cpp
#include <bits/stdc++.h>
using namespace std;

using ll = long long;

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    cin >> n;

    vector<int> a(n);

    for (int& x : a) {
        cin >> x;
    }

    // solution

    return 0;
}
```

---

# 6. Run a Problem Interactively

From the project root:

```powershell
.\tools\run.ps1 problem01
```

The program will compile using:

```text
C++17
-O2
-Wall
-Wextra
-pedantic
```

Then it will run interactively.

For example:

```text
Running interactively...
Enter your input below.

5
2 4 1 3 5
```

You can enter input directly into the terminal.

If the program appears to be stuck after:

```text
Running...
```

it is probably waiting for input.

Press:

```text
Ctrl + C
```

to stop it.

---

# 7. Run Using a Test Input

You can run a specific input file:

```powershell
.\tools\run.ps1 problem01 test01.in
```

The script automatically looks inside:

```text
problems/problem01/tests/
```

So this:

```powershell
.\tools\run.ps1 problem01 test01.in
```

uses:

```text
problems/problem01/tests/test01.in
```

You can also provide the full path:

```powershell
.\tools\run.ps1 problem01 .\problems\problem01\tests\test01.in
```

---

# 8. Test File Format

Each test consists of two files:

```text
test01.in
test01.out
```

For example:

### test01.in

```text
5
2 4 1 3 5
```

### test01.out

```text
3
```

The `.in` file contains the input.

The `.out` file contains the expected output.

---

# 9. Run All Tests

Run:

```powershell
.\tools\run_tests.ps1 problem01
```

The script automatically finds every:

```text
*.in
```

file inside:

```text
problems/problem01/tests/
```

and looks for the corresponding `.out` file.

Example:

```text
Test 1
PASS - 1.20 ms

Test 2
PASS - 1.04 ms

Test 3
FAIL - 1.15 ms

Expected:
----------------------------------------
10
----------------------------------------

Actual:
----------------------------------------
8
----------------------------------------

========================================
Summary
========================================
2/3 passed
```

---

# 10. Output Comparison

The test runner ignores harmless formatting differences.

For example, these are considered equivalent:

```text
10
```

and:

```text
10
```

even if one has additional trailing newlines.

Trailing spaces and tabs are also ignored.

Windows and Linux line endings are normalized.

However, actual differences in the output are treated as failures.

---

# 11. Runtime Errors

A program that crashes must never be reported as `PASS`.

For example:

```text
FAIL - RUNTIME ERROR
Exit code: -1073741819
```

If the program writes information to `stderr`, it is displayed.

This helps identify crashes, assertions, segmentation faults, etc.

---

# 12. Timeouts

The test runner has a default timeout of:

```text
3000 ms
```

per test.

You can change it:

```powershell
.\tools\run_tests.ps1 problem01 -TimeoutMs 5000
```

For most normal competitive programming tests, 3 seconds is sufficient for local testing.

Remember that this is only a **rough local timeout**, not the official hackathon judge's exact time limit.

---

# 13. Brute Force Solutions

For difficult problems, create:

```text
brute.cpp
```

The brute-force solution should prioritize:

```text
Correctness > Speed
```

It does not need to handle huge constraints.

For example:

```cpp
#include <bits/stdc++.h>
using namespace std;

using ll = long long;

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    cin >> n;

    vector<int> a(n);

    for (int& x : a) {
        cin >> x;
    }

    ll answer = 0;

    for (int i = 0; i < n; ++i) {
        for (int j = i + 1; j < n; ++j) {
            if (a[i] > a[j]) {
                ++answer;
            }
        }
    }

    cout << answer << '\n';

    return 0;
}
```

Even though this is `O(n²)`, it is useful for small random inputs.

---

# 14. Random Test Generator

Create:

```text
generator.py
```

inside the problem directory.

Example:

```python
import argparse
import random


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--seed", type=int, default=None)

    args = parser.parse_args()

    if args.seed is not None:
        random.seed(args.seed)

    n = random.randint(1, 100)

    a = [
        random.randint(-1000, 1000)
        for _ in range(n)
    ]

    print(n)
    print(*a)


if __name__ == "__main__":
    main()
```

The generator prints a complete test case to standard output.

You can test it manually:

```powershell
python .\problems\problem01\generator.py
```

Or with a fixed seed:

```powershell
python .\problems\problem01\generator.py --seed 123
```

A fixed seed is useful because it allows you to reproduce a particular random test.

---

# 15. Stress Testing

Stress testing compares:

```text
generator
    ↓
random input
    ↓
brute.cpp
    ↓
expected output
    ↓
solution.cpp
    ↓
actual output
    ↓
compare
```

Run:

```powershell
python .\tools\stress_test.py problem01 -n 1000
```

This performs 1,000 random tests.

For more tests:

```powershell
python .\tools\stress_test.py problem01 -n 10000
```

---

# 16. Stress Test Output

A successful stress test looks like:

```text
Compiling solution.cpp...
Compilation successful.

Compiling brute.cpp...
Compilation successful.

========================================
Stress testing: problem01
Tests: 1000
========================================

Test #1: PASS | optimized: 1.12 ms | brute: 1.04 ms
Test #2: PASS | optimized: 1.07 ms | brute: 1.11 ms
Test #3: PASS | optimized: 1.05 ms | brute: 1.08 ms

...

Test #1000: PASS | optimized: 1.06 ms | brute: 1.10 ms

========================================
STRESS TEST PASSED
========================================

Tests passed: 1000/1000
Average optimized time: 1.05 ms
Average brute time:     1.09 ms
```

---

# 17. When Stress Testing Finds a Bug

The stress tester immediately stops when the outputs differ.

Example:

```text
========================================
WRONG ANSWER FOUND!
========================================

Test #327
Seed: 327

Input:
----------------------------------------
17
31 5 8 2 19 4 7 1 9 12 3 6 20 11 10 15 14
----------------------------------------

Expected:
----------------------------------------
64
----------------------------------------

Actual:
----------------------------------------
61
----------------------------------------

Failing test saved to:
D:\PROJECTS\CP-Hackathon\problems\problem01\tests\failing_test.in
```

The failing input is saved as:

```text
problems/problem01/tests/failing_test.in
```

This allows you to reproduce and debug the problem.

---

# 18. Reproducing a Failing Stress Test

If a specific seed causes a failure:

```powershell
python .\tools\stress_test.py problem01 -n 1000 --seed 327
```

The seed makes the generated test reproducible.

This is extremely useful when debugging randomized failures.

---

# 19. Stress Test Timeout

You can change the timeout:

```powershell
python .\tools\stress_test.py problem01 -n 1000 --timeout 5
```

The value is in seconds.

For example:

```powershell
--timeout 2
```

means each program has approximately 2 seconds for each generated test.

---

# 20. Performance Testing

The test runner reports approximate execution time:

```text
Test 1
PASS - 1.23 ms

Test 2
PASS - 0.98 ms

Test 3
PASS - 1.44 ms
```

Stress testing also reports execution time:

```text
Test #50: PASS | optimized: 1.21 ms | brute: 4.37 ms
```

This is intended for **rough performance checking**, not precise benchmarking.

The actual hackathon judge may have different hardware and limits.

---

# 21. VS Code Tasks

The workspace provides VS Code tasks.

Open:

```text
Terminal → Run Task
```

Available tasks:

```text
CP: Run Problem
CP: Run Tests
CP: Stress Test
```

VS Code will ask for the problem name.

For example:

```text
problem01
```

---

# 22. Run Problem from VS Code

Use:

```text
Terminal
→ Run Task
→ CP: Run Problem
```

Enter:

```text
problem01
```

The workspace runs:

```powershell
.\tools\run.ps1 problem01
```

---

# 23. Run Tests from VS Code

Use:

```text
Terminal
→ Run Task
→ CP: Run Tests
```

Enter:

```text
problem01
```

This runs:

```powershell
.\tools\run_tests.ps1 problem01
```

---

# 24. Stress Test from VS Code

Use:

```text
Terminal
→ Run Task
→ CP: Stress Test
```

Enter:

```text
problem01
```

The task runs approximately:

```powershell
python .\tools\stress_test.py problem01 -n 1000
```

---

# 25. Debugging with VS Code

For debugging, compile with debugging information.

The debug configuration uses:

```text
-O0
-g
```

instead of the normal:

```text
-O2
```

This makes debugging easier.

To debug:

1. Open `solution.cpp`.
2. Set a breakpoint by clicking beside a line number.
3. Press `F5`.
4. VS Code starts the debugger.
5. Inspect variables in the Debug panel.
6. Step through the program.

Useful debugger shortcuts:

```text
F5              Start/Continue
F10             Step Over
F11             Step Into
Shift + F11     Step Out
Shift + F5      Stop
```

---

# 26. Debugging with cerr

For competitive programming, `cerr` is often faster than using the debugger.

Example:

```cpp
cerr << "n = " << n << '\n';
```

For multiple variables:

```cpp
cerr << "left = " << left
     << ", right = " << right
     << ", mid = " << mid
     << '\n';
```

For a vector:

```cpp
for (int x : a) {
    cerr << x << ' ';
}

cerr << '\n';
```

Use `cout` for the actual answer:

```cpp
cout << answer << '\n';
```

and `cerr` for debugging:

```cpp
cerr << "DEBUG: answer = " << answer << '\n';
```

Remove temporary debug output before submitting.

---

# 27. Recommended Test Cases

For every problem, try to include:

### 1. Minimum case

The smallest valid input.

### 2. Normal case

A typical input.

### 3. Maximum case

Something close to the maximum constraint.

### 4. Edge cases

Depending on the problem:

- `0`
- `1`
- duplicate values
- negative values
- all equal values
- sorted values
- reverse sorted values
- empty structures where allowed
- maximum integer values

Don't rely only on random tests.

Good manually designed edge cases are extremely important.

---

# 28. Recommended Hackathon Workflow

When you receive a new problem:

```text
1. Create problemXX
        ↓
2. Copy templates/main.cpp
        ↓
3. Understand constraints
        ↓
4. Determine required complexity
        ↓
5. Implement solution.cpp
        ↓
6. Create manual tests
        ↓
7. Run run_tests.ps1
        ↓
8. Fix obvious bugs
        ↓
9. If useful, create brute.cpp
        ↓
10. Create generator.py
        ↓
11. Run stress testing
        ↓
12. Investigate every failure
        ↓
13. Check time complexity
        ↓
14. Check space complexity
        ↓
15. Check integer overflow
        ↓
16. Run final tests
        ↓
17. Submit
```

---

# 29. Complexity Checklist

Before submitting, ask:

```text
What is my time complexity?

What is my space complexity?

What is the maximum possible n?

Can this loop become O(n²)?

Can recursion become too deep?

Can an integer overflow?

Should I use long long?

Are there duplicate values?

What happens at the minimum input?

What happens at the maximum input?

What happens for already sorted data?

What happens for reverse sorted data?
```

---

# 30. Integer Overflow

Be careful with:

```cpp
int
```

An `int` is usually limited to approximately:

```text
-2.1 × 10^9 to 2.1 × 10^9
```

Use:

```cpp
long long
```

when calculations can become large.

For example:

```cpp
using ll = long long;

ll answer = 0;
```

Multiplication is a common source of overflow:

```cpp
long long result = 1LL * a * b;
```

---

# 31. Important PowerShell Note

This workspace intentionally avoids CMD/Linux-style input redirection inside PowerShell scripts.

Do **not** write scripts such as:

```text
solution.exe < input.txt
```

Instead, the test runner uses PowerShell/.NET process APIs to provide input directly to the program's standard input.

This makes the test runner more reliable on Windows.

---

# 32. Paths With Spaces

The tools resolve paths from the location of the scripts rather than assuming that the current terminal directory is always the project root.

This means the workspace can safely exist in a path such as:

```text
D:\My Projects\CP Hackathon\
```

You should still normally open the project root in VS Code.

---

# 33. Main Commands Cheat Sheet

### Run interactively

```powershell
.\tools\run.ps1 problem01
```

### Run using a specific test

```powershell
.\tools\run.ps1 problem01 test01.in
```

### Run all tests

```powershell
.\tools\run_tests.ps1 problem01
```

### Run all tests with a 5-second timeout

```powershell
.\tools\run_tests.ps1 problem01 -TimeoutMs 5000
```

### Stress test 1,000 cases

```powershell
python .\tools\stress_test.py problem01 -n 1000
```

### Stress test 10,000 cases

```powershell
python .\tools\stress_test.py problem01 -n 10000
```

### Stress test with reproducible seed

```powershell
python .\tools\stress_test.py problem01 -n 1000 --seed 123
```

### Stress test with 5-second timeout

```powershell
python .\tools\stress_test.py problem01 -n 1000 --timeout 5
```

### Check compiler

```powershell
g++ --version
```

### Check Python

```powershell
python --version
```

---

# 34. Typical Problem Structure

A simple problem:

```text
problem02/
├── solution.cpp
└── tests/
    ├── test01.in
    ├── test01.out
    ├── test02.in
    └── test02.out
```

A problem requiring stress testing:

```text
problem03/
├── solution.cpp
├── brute.cpp
├── generator.py
└── tests/
    ├── test01.in
    ├── test01.out
    ├── test02.in
    ├── test02.out
    └── failing_test.in
```

---

# 35. Philosophy of This Workspace

The workspace intentionally follows a simple principle:

```text
Simple enough to use quickly.
Powerful enough to catch bugs.
Small enough to understand.
```

The goal is not to build a full online judge.

The goal is to give you a reliable local environment for:

```text
Code
  ↓
Compile
  ↓
Test
  ↓
Stress
  ↓
Debug
  ↓
Submit
```

During the hackathon, prioritize solving problems rather than improving the tooling.

---

# 36. Final Pre-Submission Checklist

For each problem:

- [ ] Code compiles with C++17
- [ ] `run_tests.ps1` passes all manual tests
- [ ] Edge cases tested
- [ ] Constraints checked
- [ ] Time complexity checked
- [ ] Space complexity checked
- [ ] Integer overflow checked
- [ ] No accidental infinite loops
- [ ] No unnecessary debug `cout`
- [ ] Temporary `cerr` debugging removed
- [ ] Stress test passed if brute force is available
- [ ] Failing stress tests investigated
- [ ] Final solution tested again

Then:

```text
SUBMIT
```

Good luck with the hackathon. 🚀