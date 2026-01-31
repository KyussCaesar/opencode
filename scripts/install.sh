#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/config"
INSTALL_DIR="${OPENCODE_INSTALL_DIR:-${HOME}/.config/opencode}"
OPENCODE_DIR="${INSTALL_DIR}"
SKILLS_TARGET_DIR="${OPENCODE_DIR}/skills"

# Detect if running interactively
if ! tty -s 2>/dev/null; then
    INTERACTIVE=false
else
    INTERACTIVE=true
fi

# Disable colors if not outputting to a terminal
if [ ! -t 1 ]; then
    RED=''
    GREEN=''
    YELLOW=''
    NC=''
fi

# Create target directory if it doesn't exist
echo -e "${GREEN}Creating ${SKILLS_TARGET_DIR}...${NC}"
mkdir -p "${SKILLS_TARGET_DIR}"

# Check if skills directory exists and has content
if [ ! -d "${CONFIG_DIR}/skills" ]; then
    echo -e "${RED}Error: Skills directory not found at ${CONFIG_DIR}/skills${NC}" >&2
    exit 1
fi

if [ -z "$(ls -A "${CONFIG_DIR}/skills" 2>/dev/null)" ]; then
    echo -e "${RED}Error: Skills directory is empty${NC}" >&2
    exit 1
fi

# Install skills
echo -e "${GREEN}Installing skills...${NC}"
for skill_dir in "${CONFIG_DIR}/skills"/*; do
    if [ -d "${skill_dir}" ]; then
        skill_name=$(basename "${skill_dir}")
        target_skill_dir="${SKILLS_TARGET_DIR}/${skill_name}"
        source_skill_file="${skill_dir}/SKILL.md"

        # Check if source SKILL.md exists
        if [ ! -f "${source_skill_file}" ]; then
            echo -e "${YELLOW}Warning: ${source_skill_file} not found, skipping${NC}"
            continue
        fi

        # Check for conflicts
        if [ -e "${target_skill_dir}" ]; then
            echo -e "${YELLOW}Conflict detected for skill '${skill_name}'${NC}"
            echo "Target exists: ${target_skill_dir}"

            # Check if it's already a symlink to our source
            if [ -L "${target_skill_dir}" ]; then
                current_target=$(readlink "${target_skill_dir}")
                if [ "${current_target}" = "${skill_dir}" ]; then
                    echo -e "${GREEN}  Already correctly linked, skipping${NC}"
                    continue
                fi
            fi

            # Prompt user for action
            if [ "${INTERACTIVE}" = "false" ]; then
                echo -e "${RED}Error: Conflict detected for skill '${skill_name}' but script is non-interactive${NC}" >&2
                exit 1
            fi

            echo "What would you like to do?"
            echo "  [s]kip - leave existing directory in place"
            echo "  [o]verwrite - replace with symlink"
            echo "  [b]ackup - backup existing directory, then symlink"
            read -r -p "Your choice [s/o/b]: " choice

            case "${choice}" in
                [Ss]*)
                    echo -e "${YELLOW}  Skipping ${skill_name}${NC}"
                    continue
                    ;;
                [Oo]*)
                    rm -rf "${target_skill_dir}"
                    ;;
                [Bb]*)
                    backup_name="${target_skill_dir}.backup.$(date +%Y%m%d%H%M%S)"
                    mv "${target_skill_dir}" "${backup_name}"
                    echo -e "${GREEN}  Backed up to ${backup_name}${NC}"
                    ;;
                *)
                    echo -e "${YELLOW}  Invalid choice, skipping ${skill_name}${NC}"
                    continue
                    ;;
            esac
        fi

        # Symlink the entire skill directory
        ln -sf "${skill_dir}" "${target_skill_dir}"
        echo -e "${GREEN}  Linked ${skill_name}${NC}"
    fi
done

echo -e "${GREEN}Installation complete!${NC}"