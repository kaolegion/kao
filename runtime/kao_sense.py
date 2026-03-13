#!/usr/bin/env python3
import os
import sys
from pathlib import Path

HOME = Path.home().resolve()
PWD = Path.cwd().resolve()

def main():
    print("===== KAO SENSE =====")
    print(f"HOME ROOT       : {HOME}")
    print(f"CURRENT PATH    : {PWD}")

    if PWD == HOME:
        state = "ON_ROOT"
        suggestion = "already at canonical root"
    elif str(PWD).startswith(str(HOME) + os.sep):
        state = "INSIDE_ROOT"
        suggestion = "inside canonical root"
    else:
        state = "DRIFT"
        suggestion = f"cd {HOME}"

    print(f"STATE           : {state}")
    print(f"SUGGESTION      : {suggestion}")

    try:
        relative = PWD.relative_to(HOME)
        print(f"RELATIVE PATH   : /{relative}")
    except ValueError:
        print("RELATIVE PATH   : outside /home/kao")

if __name__ == "__main__":
    main()
