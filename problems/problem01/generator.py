import argparse
import random


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--seed", type=int, default=None)

    args = parser.parse_args()

    if args.seed is not None:
        random.seed(args.seed)

    # Keep this small because brute force is O(n^2)
    n = random.randint(1, 100)

    a = [
        random.randint(-1000, 1000)
        for _ in range(n)
    ]

    print(n)
    print(*a)


if __name__ == "__main__":
    main()