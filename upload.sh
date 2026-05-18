#!/usr/bin/env bash
# =============================================================================
#  upload.sh – Automated Git Push Script
#  Project  : Recommendation System (UNIX Environment & Tools Course)
#  Shell    : Bash (run via Git Bash on Windows / MINGW64)
#
#  Usage    : bash upload.sh
#  Requires : Git installed and accessible in PATH
# =============================================================================

# ── Strict mode ───────────────────────────────────────────────────────────────
# -e  : exit immediately on any error
# -u  : treat unset variables as errors
# -o pipefail : catch errors inside pipes (cmd1 | cmd2)
set -euo pipefail

# =============================================================================
# SECTION 1 – COLOR PALETTE
# Uses ANSI escape codes for a professional terminal look.
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'   # Resets all formatting

# =============================================================================
# SECTION 2 – HELPER FUNCTIONS
# =============================================================================

# Print a styled section header
print_header() {
    echo ""
    echo -e "${BLUE}${BOLD}╔══════════════════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}${BOLD}║       🚀  Git Auto-Upload Script  🚀             ║${RESET}"
    echo -e "${BLUE}${BOLD}║       UNIX Environment & Tools – Project         ║${RESET}"
    echo -e "${BLUE}${BOLD}╚══════════════════════════════════════════════════╝${RESET}"
    echo ""
}

# Log helpers – prefix every message with a timestamp
log_info()    { echo -e "${CYAN}[INFO]${RESET}    $1"; }
log_success() { echo -e "${GREEN}[✔ SUCCESS]${RESET} $1"; }
log_warn()    { echo -e "${YELLOW}[⚠ WARNING]${RESET} $1"; }
log_error()   { echo -e "${RED}[✖ ERROR]${RESET}   $1"; }
log_step()    { echo -e "\n${BOLD}${BLUE}──── STEP: $1 ────${RESET}"; }

# Pause and ask the user whether to continue after a warning
confirm_continue() {
    echo -e "${YELLOW}Do you want to continue anyway? [y/N]:${RESET} \c"
    read -r answer
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        log_error "Aborted by user."
        exit 1
    fi
}

# =============================================================================
# SECTION 3 – PRE-FLIGHT CHECKS
# =============================================================================

check_git_installed() {
    log_step "Checking prerequisites"
    if ! command -v git &>/dev/null; then
        log_error "Git is not installed or not in PATH."
        log_error "Please install Git from https://git-scm.com and try again."
        exit 1
    fi
    local git_version
    git_version=$(git --version)
    log_success "Git is available → ${git_version}"
}

check_git_repo() {
    log_step "Validating Git repository"

    if git rev-parse --is-inside-work-tree &>/dev/null; then
        local repo_root
        repo_root=$(git rev-parse --show-toplevel)
        log_success "Inside a Git repository → ${repo_root}"
    else
        log_warn "Current directory is NOT a Git repository."
        echo -e "${YELLOW}Do you want to initialize a new Git repository here? [y/N]:${RESET} \c"
        read -r init_answer
        if [[ "$init_answer" =~ ^[Yy]$ ]]; then
            git init
            log_success "Git repository initialized successfully."
        else
            log_error "Cannot proceed without a Git repository. Exiting."
            exit 1
        fi
    fi
}

check_remote() {
    log_step "Checking remote origin"

    if git remote get-url origin &>/dev/null; then
        local remote_url
        remote_url=$(git remote get-url origin)
        log_success "Remote 'origin' is set → ${remote_url}"
    else
        log_warn "No remote 'origin' found."
        echo -e "${CYAN}Please enter the remote repository URL (e.g. https://github.com/user/repo.git):${RESET} "
        read -r remote_url
        if [[ -z "$remote_url" ]]; then
            log_error "Remote URL cannot be empty. Exiting."
            exit 1
        fi
        git remote add origin "$remote_url"
        log_success "Remote 'origin' added → ${remote_url}"
    fi
}

# =============================================================================
# SECTION 4 – SHOW GIT STATUS SUMMARY
# =============================================================================

show_status() {
    log_step "Current repository status"

    local branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    log_info "Active branch : ${BOLD}${branch}${RESET}"

    local author_name author_email
    author_name=$(git config user.name  2>/dev/null || echo "Not configured")
    author_email=$(git config user.email 2>/dev/null || echo "Not configured")
    log_info "Commit author : ${BOLD}${author_name}${RESET} <${author_email}>"

    echo ""
    log_info "Files changed (git status --short):"
    echo -e "${YELLOW}"
    git status --short || true
    echo -e "${RESET}"

    # Warn if nothing is changed
    if git diff --quiet && git diff --cached --quiet && \
       [[ -z "$(git ls-files --others --exclude-standard)" ]]; then
        log_warn "No changes detected in the working tree."
        confirm_continue
    fi
}

# =============================================================================
# SECTION 5 – SAFETY GUARDS
# Check that sensitive/large files won't be accidentally staged.
# =============================================================================

safety_check() {
    log_step "Safety checks – scanning for sensitive files"

    local found_issues=0

    # List of patterns that should NEVER be committed
    local dangerous_files=(".env" "*.env" "node_modules" "*.pem" "*.key" "*.p12")

    for pattern in "${dangerous_files[@]}"; do
        # Check if git would stage any matching file
        if git ls-files --others --exclude-standard | grep -qE "${pattern}" 2>/dev/null; then
            log_warn "Untracked sensitive file detected matching pattern: '${pattern}'"
            found_issues=1
        fi
        if git ls-files --cached | grep -qE "${pattern}" 2>/dev/null; then
            log_warn "Tracked sensitive file detected matching pattern: '${pattern}'"
            found_issues=1
        fi
    done

    # Warn about node_modules directory specifically
    if [[ -d "node_modules" ]] || [[ -d "backend/node_modules" ]]; then
        if ! grep -q "node_modules" .gitignore 2>/dev/null; then
            log_warn "node_modules/ found but NOT listed in .gitignore!"
            log_warn "Add 'node_modules/' to .gitignore before continuing."
            found_issues=1
        else
            log_success "node_modules/ is listed in .gitignore → will NOT be uploaded."
        fi
    fi

    if [[ $found_issues -eq 1 ]]; then
        echo ""
        log_warn "Potential issues found above. Review them carefully."
        confirm_continue
    else
        log_success "Safety checks passed – no sensitive files detected."
    fi
}

# =============================================================================
# SECTION 6 – STAGE CHANGES
# =============================================================================

stage_changes() {
    log_step "Staging all changes (git add .)"

    git add .

    local staged_count
    staged_count=$(git diff --cached --name-only | wc -l)
    log_success "${staged_count} file(s) staged for commit."

    if [[ "$staged_count" -gt 0 ]]; then
        log_info "Staged files:"
        echo -e "${CYAN}"
        git diff --cached --name-only
        echo -e "${RESET}"
    fi
}

# =============================================================================
# SECTION 7 – INTERACTIVE COMMIT MESSAGE
# =============================================================================

get_commit_message() {
    log_step "Commit message"

    local commit_msg=""

    # Keep prompting until the user provides a non-empty message
    while [[ -z "$commit_msg" ]]; do
        echo -e "${CYAN}Enter your commit message (cannot be empty):${RESET}"
        echo -e "${YELLOW}> ${RESET}\c"
        read -r commit_msg

        if [[ -z "$commit_msg" ]]; then
            log_error "Commit message cannot be empty. Please try again."
        fi
    done

    # Echo back for confirmation
    echo ""
    log_info "Commit message: \"${BOLD}${commit_msg}${RESET}\""
    echo -e "${YELLOW}Confirm and proceed? [Y/n]:${RESET} \c"
    read -r confirm

    # Default is Yes (pressing Enter = confirm)
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        log_warn "Let's re-enter the commit message."
        get_commit_message   # recursive call to retry
        return
    fi

    # Export so it's accessible outside the function
    COMMIT_MESSAGE="$commit_msg"
}

# =============================================================================
# SECTION 8 – COMMIT
# =============================================================================

do_commit() {
    log_step "Committing changes"

    if git diff --cached --quiet; then
        log_warn "Nothing to commit (staging area is empty)."
        log_warn "This can happen if all files are already up to date."
        confirm_continue
        return
    fi

    git commit -m "$COMMIT_MESSAGE"
    log_success "Commit created successfully!"
}

# =============================================================================
# SECTION 9 – PUSH TO REMOTE
# =============================================================================

do_push() {
    log_step "Pushing to remote (origin/main)"

    local branch
    branch=$(git rev-parse --abbrev-ref HEAD)

    log_info "Pushing branch '${branch}' → origin/${branch} ..."

    # --set-upstream handles first-time pushes where tracking isn't set yet
    if git push --set-upstream origin "$branch"; then
        log_success "Code pushed successfully to origin/${branch} 🎉"
    else
        log_error "Push failed! Common causes:"
        log_error "  • You are not authenticated (check GitHub credentials / SSH key)"
        log_error "  • Remote has changes you don't have locally (run: git pull)"
        log_error "  • No internet connection"
        exit 1
    fi
}

# =============================================================================
# SECTION 10 – PRINT FINAL SUMMARY
# =============================================================================

print_summary() {
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD)
    local remote_url
    remote_url=$(git remote get-url origin 2>/dev/null || echo "N/A")
    local last_commit
    last_commit=$(git log -1 --oneline 2>/dev/null || echo "N/A")

    echo ""
    echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}${BOLD}║           ✅  Upload Complete!                   ║${RESET}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════╝${RESET}"
    echo -e "  ${BOLD}Branch  :${RESET} ${branch}"
    echo -e "  ${BOLD}Remote  :${RESET} ${remote_url}"
    echo -e "  ${BOLD}Commit  :${RESET} ${last_commit}"
    echo ""
}

# =============================================================================
# MAIN – Orchestrates all steps in order
# =============================================================================

main() {
    print_header
    check_git_installed
    check_git_repo
    check_remote
    show_status
    safety_check
    stage_changes
    get_commit_message
    do_commit
    do_push
    print_summary
}

# ── Entry point ───────────────────────────────────────────────────────────────
main
