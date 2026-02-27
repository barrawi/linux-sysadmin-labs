# Ansible Context Exporter

An integrity aware Python utility designed to transform complex directory structures and file contents into a sanitized, readable format for AI-assisted auditing and collaboration. This tool ensures that the "full picture" of a project can be shared with LLMs while maintaining a strict security posture by redacting sensitive data.

## Key Features

* **Git-Aware Filtering:** Automatically synchronizes with your `.gitignore` to prevent exporting environment-specific files like `venv/` or sensitive logs.
* **Security-First Redaction:** Implements proactive "code vs comment" scrubbing. It identifies and removes lines containing sensitive keywords (e.g., `password`, `ansible_become_pass`) **only** if they appear in the functional code, preserving helpful developer comments.
* **Ansible Vault Protection:** Detects and automatically skips the heavy ciphertext blocks of `$ANSIBLE_VAULT` files, ensuring only structural metadata or decrypted logic is shared.
* **Recursive Structure Mapping:** Generates a unified `.txt` file with clear visual delimiters (`=======`), mapping relative file paths to their content for seamless AI context loading.

## Technical Highlights

### Smart Line Splitting & Scrubbing
The exporter uses specialized logic to distinguish between functional code and developer notes. This prevents "false positive" redactions where a comment might mention a sensitive word without actually containing a secret.

```python
# Logic for comments vs code
if '#' in line:
    code_part, comment_part = line.split('#', 1)
    comment_part = '#' + comment_part
else:
    code_part = line

if any(key in code_part.lower() for key in no_include):
    f.write(f"# [REMOVED FOR SECURITY] {comment_part.strip()}\n")
```
### Recursive Directory Pruning
To ensure the output remains within AI context window limits, the script prunes its search tree in real time, preventing the traversal of massive folders like .git or __pycache__.

### Validation & Error Handling
The utility wraps file operations in try/except blocks to ensure that a single unreadable or binary file does not halt the entire export process, providing clear error markers in the final output.

## Usage
### Running the Export
Run the script from your project root to generate the audit file:

```python
python3 content_exporter/main.py
```
### Output
The tool generates a file named `context_exporter.txt`. This file is formatted for easy copy pasting into LLM interfaces for code review, debugging, or role based analysis.

### Multi-Model Benchmarking
I manually verified the script's output with **Gemini**, **DeepSeek**, and **ChatGPT** to ensure:
* **Context Preservation:** All models correctly identified the Ansible role structure despite the single file flat format.
* **Redaction Logic:** Verified that all models were unable to "guess" or recover scrubbed sensitive data.
* **Token Efficiency:** The output was optimized to fit within standard context windows without losing critical logic.

#### Cross-Model Comparison
| Gemini | DeepSeek | ChatGPT |
| :--- | :--- | :--- |
| ![Gemini Test](/mnt/caracol/Documentation/context-exporter/gemini.png) | ![DeepSeek Test](/mnt/caracol/Documentation/context-exporter/deepseek.png) | ![ChatGPT Test](/mnt/caracol/Documentation/context-exporter/chatgpt.png) |

## AI-Assisted Development & QA
Consistent with a collaborative DevOps workflow, this tool was developed as a joint effort between human architecture and AI logic:

* **Refinement**: AI assisted in developing the specific logic to split lines at the `#` character to protect comments while scrubbing code.
* **Security Auditing**: Every redaction keyword and Vault detection check was manually verified to ensure no plain-text secrets were leaked during the export process.
* **Troubleshooting**: Utilized AI to debug `ModuleNotFoundError` issues related to internal IDE type-hinting to ensure the script remains dependency free.

## Author 
Wilberth Barrantes — SysAdmin / DevOps Portfolio project
