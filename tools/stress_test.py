import argparse
import os
import subprocess
import sys
import time
from pathlib import Path


def normalize_output(text: str) -> str:
    """
    Normalize harmless formatting differences:
    - CRLF -> LF
    - remove trailing spaces/tabs
    - remove trailing newlines
    """
    text = text.replace("\r\n", "\n").replace("\r", "\n")

    lines = text.split("\n")
    lines = [line.rstrip(" \t") for line in lines]

    return "\n".join(lines).rstrip("\n")


def run_program(executable, input_data, timeout):
    start = time.perf_counter()

    try:
        result = subprocess.run(
            [str(executable)],
            input=input_data,
            text=True,
            capture_output=True,
            timeout=timeout,
        )

    except subprocess.TimeoutExpired:
        elapsed = (time.perf_counter() - start) * 1000
        return None, "TIMEOUT", elapsed

    elapsed = (time.perf_counter() - start) * 1000

    if result.returncode != 0:
        return result, "RUNTIME_ERROR", elapsed

    return result, "OK", elapsed


def compile_cpp(source, executable):
    print(f"Compiling {source.name}...")

    command = [
        "g++",
        "-std=c++17",
        "-O2",
        "-Wall",
        "-Wextra",
        "-pedantic",
        str(source),
        "-o",
        str(executable),
    ]

    result = subprocess.run(
        command,
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        print("\nCOMPILATION FAILED")
        print(result.stderr)
        sys.exit(1)

    print("Compilation successful.\n")


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "problem",
        help="Problem folder name, e.g. problem01"
    )

    parser.add_argument(
        "-n",
        "--tests",
        type=int,
        default=100,
        help="Number of random tests"
    )

    parser.add_argument(
        "--timeout",
        type=float,
        default=2.0,
        help="Timeout per program in seconds"
    )

    parser.add_argument(
        "--seed",
        type=int,
        default=None,
        help="Starting random seed"
    )

    args = parser.parse_args()

    # --------------------------------------------------------
    # Resolve paths
    # --------------------------------------------------------

    tools_dir = Path(__file__).resolve().parent
    root_dir = tools_dir.parent

    # Accept either "problem01" or a full path from ${fileDirname}
    p = Path(args.problem)
    if p.is_dir():
        problem_dir = p.resolve()
    else:
        problem_dir = root_dir / "problems" / args.problem

    solution = problem_dir / "solution.cpp"
    brute = problem_dir / "brute.cpp"
    generator = problem_dir / "generator.py"

    build_dir = root_dir / "build" / args.problem
    build_dir.mkdir(parents=True, exist_ok=True)

    solution_exe = build_dir / "solution.exe"
    brute_exe = build_dir / "brute.exe"

    failing_test = problem_dir / "tests" / "failing_test.in"

    # --------------------------------------------------------
    # Validate
    # --------------------------------------------------------

    if not problem_dir.exists():
        print(f"ERROR: Problem '{args.problem}' does not exist.")
        sys.exit(1)

    if not solution.exists():
        print(f"ERROR: {solution} not found.")
        sys.exit(1)

    if not brute.exists():
        print(f"ERROR: {brute} not found.")
        sys.exit(1)

    if not generator.exists():
        print(f"ERROR: {generator} not found.")
        sys.exit(1)

    # --------------------------------------------------------
    # Compile
    # --------------------------------------------------------

    compile_cpp(solution, solution_exe)
    compile_cpp(brute, brute_exe)

    # --------------------------------------------------------
    # Stress test
    # --------------------------------------------------------

    print("========================================")
    print(f"Stress testing: {args.problem}")
    print(f"Tests: {args.tests}")
    print("========================================")
    print()

    total_solution_time = 0.0
    total_brute_time = 0.0

    for test_number in range(1, args.tests + 1):

        seed = (
            args.seed + test_number - 1
            if args.seed is not None
            else test_number
        )

        # ----------------------------------------------------
        # Generate input
        # ----------------------------------------------------

        generator_result = subprocess.run(
            [
                sys.executable,
                str(generator),
                "--seed",
                str(seed),
            ],
            capture_output=True,
            text=True,
        )

        if generator_result.returncode != 0:
            print("\nGENERATOR FAILED")
            print(generator_result.stderr)
            sys.exit(1)

        input_data = generator_result.stdout

        # ----------------------------------------------------
        # Run brute
        # ----------------------------------------------------

        brute_result, brute_status, brute_time = run_program(
            brute_exe,
            input_data,
            args.timeout,
        )

        if brute_status == "TIMEOUT":
            print(f"\nBRUTE FORCE TIMEOUT on test #{test_number}")
            print(f"Seed: {seed}")
            sys.exit(1)

        if brute_status == "RUNTIME_ERROR":
            print(f"\nBRUTE FORCE CRASHED on test #{test_number}")
            print(f"Seed: {seed}")
            print(brute_result.stderr)
            sys.exit(1)

        expected = brute_result.stdout

        # ----------------------------------------------------
        # Run optimized solution
        # ----------------------------------------------------

        solution_result, solution_status, solution_time = run_program(
            solution_exe,
            input_data,
            args.timeout,
        )

        if solution_status == "TIMEOUT":

            print("\n========================================")
            print("TIME LIMIT EXCEEDED")
            print("========================================")

            print(f"Test #{test_number}")
            print(f"Seed: {seed}")
            print(f"Timeout: {args.timeout} seconds")

            failing_test.parent.mkdir(parents=True, exist_ok=True)
            failing_test.write_text(input_data, encoding="utf-8")

            print(f"\nFailing test saved to:")
            print(failing_test)

            sys.exit(1)

        if solution_status == "RUNTIME_ERROR":

            print("\n========================================")
            print("RUNTIME ERROR")
            print("========================================")

            print(f"Test #{test_number}")
            print(f"Seed: {seed}")

            print("\nInput:")
            print(input_data)

            print("\nstderr:")
            print(solution_result.stderr)

            failing_test.parent.mkdir(parents=True, exist_ok=True)
            failing_test.write_text(input_data, encoding="utf-8")

            print(f"\nFailing test saved to:")
            print(failing_test)

            sys.exit(1)

        actual = solution_result.stdout

        # ----------------------------------------------------
        # Compare
        # ----------------------------------------------------

        expected_normalized = normalize_output(expected)
        actual_normalized = normalize_output(actual)

        total_solution_time += solution_time
        total_brute_time += brute_time

        if expected_normalized != actual_normalized:

            print("\n========================================")
            print("WRONG ANSWER FOUND!")
            print("========================================")

            print(f"\nTest #{test_number}")
            print(f"Seed: {seed}")

            print("\nInput:")
            print("----------------------------------------")
            print(input_data, end="")
            print("----------------------------------------")

            print("\nExpected:")
            print("----------------------------------------")
            print(expected, end="")
            print("----------------------------------------")

            print("\nActual:")
            print("----------------------------------------")
            print(actual, end="")
            print("----------------------------------------")

            failing_test.parent.mkdir(parents=True, exist_ok=True)
            failing_test.write_text(input_data, encoding="utf-8")

            print("\nFailing test saved to:")
            print(failing_test)

            sys.exit(1)

        # ----------------------------------------------------
        # Progress
        # ----------------------------------------------------

        print(
            f"Test #{test_number}: PASS | "
            f"optimized: {solution_time:.2f} ms | "
            f"brute: {brute_time:.2f} ms"
        )

    # --------------------------------------------------------
    # Finished
    # --------------------------------------------------------

    average_solution = total_solution_time / args.tests
    average_brute = total_brute_time / args.tests

    print("\n========================================")
    print("STRESS TEST PASSED")
    print("========================================")

    print(f"Tests passed: {args.tests}/{args.tests}")
    print(f"Average optimized time: {average_solution:.2f} ms")
    print(f"Average brute time:     {average_brute:.2f} ms")


if __name__ == "__main__":
    main()