#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENCODE_TEST_CLEANUP_ENABLED="${OPENCODE_TEST_CLEANUP_ENABLED:-true}"
TEMP_DIR="/tmp/opencode-test-$(date +%s)"
INSTALL_SCRIPT="$SCRIPT_DIR/install.sh"

# Disable colors if not outputting to a terminal
if [ ! -t 1 ]; then
    RED=''
    GREEN=''
    YELLOW=''
    NC=''
fi

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Test helpers
test_passed() {
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "  ${GREEN}✓${NC} $1"
}

test_failed() {
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "  ${RED}✗${NC} $1"
}

# Cleanup function
cleanup() {
    if [ "${OPENCODE_TEST_CLEANUP_ENABLED}" = "true" ]; then
        if [ -d "$TEMP_DIR" ]; then
            log_info "Cleaning up test directory: $TEMP_DIR"
            rm -rf "$TEMP_DIR"
        fi
    else
        log_warn "Skipping cleanup. Test directory left at: $TEMP_DIR"
    fi
}

# Set up trap for cleanup on exit
trap cleanup EXIT

# Main test execution
main() {
    log_info "Starting OpenCode install script test"
    log_info "Test directory: $TEMP_DIR"
    log_info "Cleanup enabled: $OPENCODE_TEST_CLEANUP_ENABLED"
    
    # Verify install script exists
    if [ ! -f "$INSTALL_SCRIPT" ]; then
        log_error "Install script not found: $INSTALL_SCRIPT"
        exit 1
    fi
    
    # Set test install directory
    export OPENCODE_INSTALL_DIR="$TEMP_DIR"
    SKILLS_TARGET_DIR="${OPENCODE_INSTALL_DIR}/skills"
    
    # Test 1: Run install script
    echo
    log_info "Test 1: Running install script..."
    if bash "$INSTALL_SCRIPT"; then
        test_passed "Install script executed successfully"
    else
        test_failed "Install script failed"
        exit 1
    fi
    
    # Test 2: Verify skills directory was created
    echo
    log_info "Test 2: Verifying skills directory structure..."
    if [ -d "$SKILLS_TARGET_DIR" ]; then
        test_passed "Skills directory created at $SKILLS_TARGET_DIR"
    else
        test_failed "Skills directory not created at $SKILLS_TARGET_DIR"
        exit 1
    fi
    
    # Test 3: Get expected skills and verify each one
    echo
    log_info "Test 3: Verifying skill symlinks..."
    
    CONFIG_SKILLS_DIR="$SCRIPT_DIR/../config/skills"
    if [ ! -d "$CONFIG_SKILLS_DIR" ]; then
        log_error "Config skills directory not found: $CONFIG_SKILLS_DIR"
        exit 1
    fi
    
    # Get list of expected skill directories (excluding hidden files like .swp files)
    expected_skills=()
    for skill_dir in "$CONFIG_SKILLS_DIR"/*; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            expected_skills+=("$skill_name")
        fi
    done
    
    if [ ${#expected_skills[@]} -eq 0 ]; then
        log_warn "No skills found in config directory"
        test_passed "No skills to install (empty config directory)"
    else
        log_info "Found ${#expected_skills[@]} expected skills: ${expected_skills[*]}"
        
        for skill_name in "${expected_skills[@]}"; do
            symlink_path="$SKILLS_TARGET_DIR/$skill_name"
            source_path="$CONFIG_SKILLS_DIR/$skill_name"
            
            echo "  Testing skill: $skill_name"
            
            # Check symlink exists
            if [ -L "$symlink_path" ]; then
                test_passed "Symlink exists for $skill_name"
            else
                test_failed "Symlink missing for $skill_name at $symlink_path"
                continue
            fi
            
            # Check symlink points to correct source (resolve both paths for comparison)
            expected_canonical=$(cd "$(dirname "$source_path")" && pwd)/$(basename "$source_path")
            actual_target=$(readlink "$symlink_path")
            actual_canonical=$(cd "$(dirname "$actual_target")" 2>/dev/null && pwd 2>/dev/null)/$(basename "$actual_target" 2>/dev/null) || actual_target
            
            if [ "$expected_canonical" = "$actual_canonical" ]; then
                test_passed "Symlink points to correct source for $skill_name"
            else
                test_failed "Symlink points to wrong location for $skill_name"
                echo "    Expected canonical: $expected_canonical"
                echo "    Actual target: $actual_target"
                echo "    Actual canonical: $actual_canonical"
                continue
            fi
            
            # Check SKILL.md is readable through symlink
            skill_file="$symlink_path/SKILL.md"
            if [ -f "$skill_file" ] && [ -r "$skill_file" ]; then
                test_passed "SKILL.md is readable for $skill_name"
            else
                test_failed "SKILL.md not readable for $skill_name at $skill_file"
            fi
        done
    fi
    
    # Test 4: Verify no broken symlinks
    echo
    log_info "Test 4: Checking for broken symlinks..."
    broken_links=0
    for symlink in "$SKILLS_TARGET_DIR"/*; do
        if [ -L "$symlink" ] && [ ! -e "$symlink" ]; then
            broken_links=$((broken_links + 1))
            test_failed "Broken symlink found: $(basename "$symlink")"
        fi
    done
    
    if [ $broken_links -eq 0 ]; then
        test_passed "No broken symlinks found"
    fi
    
    # Final results
    echo
    log_info "Test Results:"
    echo -e "  ${GREEN}Passed:${NC} $TESTS_PASSED"
    echo -e "  ${RED}Failed:${NC} $TESTS_FAILED"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        log_info "All tests passed! ✓"
        exit 0
    else
        log_error "Some tests failed!"
        exit 1
    fi
}

# TODO: Test error conditions and edge cases
# - Test conflict scenarios (existing directories/symlinks)
# - Test missing skills directory handling
# - Test broken symlinks detection and handling
# - Test non-interactive mode conflict behavior
# - Test with missing SKILL.md files in skill directories
# - Test with empty skills directory
# - Test with invalid permissions

main "$@"