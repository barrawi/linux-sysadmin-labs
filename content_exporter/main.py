"""
Content Exporter
An AI Collaborating tool that transforms a directory/file structure into readable
material for AI auditing
"""

import fnmatch
import os

output_file = "content_exporter.txt"
include = {".yml", ".yaml", ".ini", ".j2", ".cfg"}  # files to include
no_include = {
    "password",
    "secret",
    "token",
    "private_key",
    "ansible_become_pass",
    "ansible-vault",
}


def ignore_gitignore():
    # reads the .gitignore and returns a list of patterns to ignore
    patterns = {".git", output_file}  # always ignore these
    if os.path.exists(".gitignore"):
        # separate lines and return uncommented ones
        with open(".gitignore", "r") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#"):
                    patterns.add(line)
    return patterns


def ignore_path(path, patterns):
    # check if a path match a pattern in the ignore list
    for pattern in patterns:
        if fnmatch.fnmatch(path, pattern) or fnmatch.fnmatch(
            os.path.basename(path), pattern
        ):
            return True
    return False


def generate_context(root_dir):
    ignore_patterns = ignore_gitignore()

    with open(output_file, "w", encoding="utf-8") as f:
        for root, dirs, files in os.walk(root_dir):
            # Filter directories to prevent checking ignore ones
            dirs[:] = [
                d
                for d in dirs
                if not ignore_path(os.path.join(root, d), ignore_patterns)
            ]

            for file in files:
                file_path = os.path.join(root, file)
                rel_path = os.path.relpath(file_path, root_dir)

                # check if file is ignore by .gitignore or worng ext
                if ignore_path(rel_path, ignore_patterns):
                    continue
                if not any(file.endswith(ext) for ext in include):
                    continue

                f.write(f"\n{'='*60}\n")
                f.write(f"FILE: {rel_path}\n")
                f.write(f"{'='*60}\n\n")

                try:
                    with open(file_path, "r", encoding="utf-8") as content:
                        for line in content:
                            # skip vault lines
                            if "$ANSIBLE_VAULT;" in line:
                                f.write("# [Encrypted vault header skipped]\n")
                                continue

                            # skip encrypted blocks
                            if (
                                all(
                                    c in "0123456789abcdefABCDEF \n"
                                    for c in line.strip()
                                )
                                and len(line.strip()) > 30
                            ):
                                continue

                            # split comment parts to avoid censoring them
                            if "#" in line:
                                code_part, comment_part = line.split("#", 1)
                                comment_part = "#" + comment_part
                            else:
                                code_part = line
                                comment_part = ""

                            # will only check code for sensitive info
                            if any(
                                key in code_part.lower() for key in no_include
                            ):
                                f.write(
                                    f"# [REMOVED FOR SECURITY] {comment_part.strip()}\n"
                                )
                            else:
                                f.write(line)
                except Exception as e:
                    f.write(f"Error: Can't read file {e}")
                f.write("\n")


if __name__ == "__main__":
    generate_context(".")
    print(f"Content exported to {output_file}. Verified against .gitignore...")
