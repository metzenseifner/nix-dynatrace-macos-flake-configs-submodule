#!/usr/bin/env python3

import os
import subprocess
import sys

def log(message, level="INFO"):
    # ANSI escape sequences for colored output
    levels = {
        "DEBUG": "\033[34m",    # Blue
        "INFO": "\033[32m",     # Green
        "WARNING": "\033[33m",  # Yellow
        "ERROR": "\033[31m",    # Red
        "CRITICAL": "\033[35m", # Magenta
        "RESET": "\033[0m"      # Reset
    }
    color_code = levels.get(level, levels["RESET"])
    print(f"{color_code}[{level}] {message}{levels['RESET']}")

def is_executable(file_path):
    # On Windows, check if the file exists
    # On Unix-like systems, check if the file is executable
    return os.path.isfile(file_path) and (os.name == 'nt' or os.access(file_path, os.X_OK))

def read_single_line(file_path):
    with open(file_path, 'r') as file:
        line = file.readline().strip()
    return line

def get_parent_directory(path):
    return os.path.abspath(os.path.join(path, os.pardir))

def main():
    worktree_dir = subprocess.check_output(['git', 'rev-parse', '--show-toplevel']).strip().decode()
    branches_dir = get_parent_directory(worktree_dir)
    repo_dir = get_parent_directory(branches_dir)
    hooks_dir = os.path.join(repo_dir, 'hooks')

    # This works because the list of refs being pushed is passed on standard input
    if 'null' in sys.stdin.read():
        log("You really do not want to push this branch. Aborting.", "ERROR")
        sys.exit(1)

    # Check if the hook exists in the worktree hooks directory
    pre_push_hook = os.path.join(hooks_dir, 'pre-push')
    if is_executable(pre_push_hook):
        log(f"Found {pre_push_hook}. Executing.")
        # Execute the worktree hook
        os.execv(pre_push_hook, [pre_push_hook] + sys.argv[1:])
    else:
        # Execute the global hook
        log(f"Completed pre-push. No hook under {pre_push_hook} found. Exiting.")

if __name__ == "__main__":
    main()
