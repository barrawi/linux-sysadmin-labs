# Enterprise User Management Suite
<img width="1620" height="317" alt="image" src="https://github.com/user-attachments/assets/ee1c3a3c-32fe-4fc1-ab3d-142b69d20081" />

An integrity aware Bash toolset designed for automating the user lifecycle on RHEL/CentOS systems. This suite provides a standardized, auditable framework for onboarding and offboarding users, with built-in safeguards to protect system stability and data integrity.

**Key Features**
- **Bulk & Single Processing:** Efficiently handles individual users or mass processing from external files using custom file descriptors.
- **"Strict Mode" Architecture:** Implements `set -euo pipefail` to ensure scripts fail fast on errors or undefined variables, preventing corrupted states.
- **Security-First Onboarding:** Automates standardized group assignment and shell validation.
      - Forces password change on first login (`chage -d 0`).
      - Optional automated sudoers (wheel) provisioning.
- **Safe Deprovisioning:**
      - Protection for system accounts (UID < 1000).
      - Active session detection to prevent deleting users currently logged in.
      - Automatic home directory archiving with tar compression.
      - "Force-kill" mode for terminating stubborn user processes.
- **Comprehensive Auditing:** Centralized logging at /var/log/user_administration.log, tracking the execution time, hostname, and the actual human administrator (via $SUDO_USER).

# Technical Highlights
- **Robust Input Handling with File Descriptor 3**
Unlike standard loops that read from stdin, this suite uses a dedicated File Descriptor (3) for bulk file processing.
```bash
while read -u 3 -r line; do

done 3< "$file"
```
This architectural choice prevents conflicts between the data stream (user list) and interactive user input (like y/n confirmation prompts), ensuring the script remains stable during complex bulk operations.

- **Defensive Programming & Validation**
The scripts utilize a modular function design with explicit return codes (return 0 for success, return 1 for failure).
    - Regex Validation: Usernames are validated against POSIX-compliant regex patterns before any system changes occur.
    - Binary Validation: Shells are verified for existence and execution bits (-x) before assignment.
    - Fault Tolerance: The execution sequence uses || true in bulk loops to ensure one failed creation/deletion doesn't halt the entire automation pipeline.

- **Integrated Logging Function**
```bash
log_action(){
    echo "$(date '+%Y-%m-%d %H:%M:%S') - by ${SUDO_USER:-$(whoami)} on $(hostname) - $1" >> "$logfile"
}
```
This function captures critical metadata for compliance, ensuring every action is mapped back to a specific host and user.
- **Log example:**
<img width="1509" height="614" alt="image" src="https://github.com/user-attachments/assets/cd7a993b-1883-4dd8-9318-9fef7caa28ac" />

# Usage Examples
#### User Creation:
```bash
# Individual user with sudo access and custom group
sudo ./user_creation.sh -u jdoe -g devops --sudo

# Bulk creation from a file
sudo ./user_creation.sh -f new_hires.txt
```
#### User Deprovisioning:
```bash
# Securely archive, disable, and delete a user
sudo ./user_deprovision.sh -u jdoe --backup --disable --delete

# Forcefully kill processes and delete from a file list
sudo ./user_deprovision.sh -f offboarding_list.txt --force --delete
```

# Project Structure
- `user_creation.sh`: Standardized onboarding automation.
- `user_deprovision.sh`: Secure offboarding and data archival automation.
- `users_list.txt`: Sample template for bulk processing.

# Feedback and Contributions
This project was developed as part of my **SysAdmin / DevOps Portfolio** to demonstrate technical proficiency in Linux automation and shell scripting. 
I am always looking to improve my workflows and code efficiency. If you have any feedback or suggestions, they are 100% appreciated! Feel free to reach out, constructive conversations and professional networking are always welcome.

# AI-Assisted Development & Quality Assurance
While this suite was architected and driven by me, I utilized AI as a collaborative tool for code revisioning, best practice auditing, and logic verification.
- Every AI generated suggestion was manually reviewed, tested in a sandbox environment, and investigated it implications before integration.
- AI helped identify potential edge cases, such as the "unbound variable" errors common with set -u, leading to a more resilient final product.
- The collaborative process was used to refine complex logic, such as the use of custom File Descriptor 3 for conflict free bulk processing.

# Author
Wilberth Barrantes - SysAdmin / DevOps Toolkit.
