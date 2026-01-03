#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if organization name is provided
if [ -z "$1" ]; then
  echo -e "${RED}Error: Organization name required${NC}"
  echo "Usage: $0 <organization> [target_directory]"
  exit 1
fi

ORG="$1"
TARGET_DIR="${2:-.}"

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
  echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
  echo "Install it from: https://cli.github.com/"
  exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
  echo -e "${RED}Error: Not authenticated with GitHub CLI${NC}"
  echo "Run: gh auth login"
  exit 1
fi

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

echo -e "${BLUE}Fetching repository list for organization: ${GREEN}$ORG${NC}"

# Get list of repositories
REPOS=$(gh repo list "$ORG" --limit 4000 --json name,sshUrl,isArchived --jq '.[] | "\(.name)|\(.sshUrl)|\(.isArchived)"')

if [ -z "$REPOS" ]; then
  echo -e "${RED}Error: No repositories found or unable to access organization${NC}"
  exit 1
fi

TOTAL=$(echo "$REPOS" | wc -l)
CURRENT=0
CLONED=0
SKIPPED=0
ARCHIVED=0

echo -e "${BLUE}Found ${GREEN}$TOTAL${BLUE} repositories${NC}"
echo ""

# Clone each repository
while IFS='|' read -r name ssh_url is_archived; do
  CURRENT=$((CURRENT + 1))

  # Skip archived repos with a note
  if [ "$is_archived" = "true" ]; then
    echo -e "${YELLOW}[$CURRENT/$TOTAL]${NC} Skipping archived repo: ${YELLOW}$name${NC}"
    ARCHIVED=$((ARCHIVED + 1))
    continue
  fi

  # Check if repo already exists
  if [ -d "$name" ]; then
    echo -e "${YELLOW}[$CURRENT/$TOTAL]${NC} Already exists, skipping: ${YELLOW}$name${NC}"
    SKIPPED=$((SKIPPED + 1))
  else
    echo -e "${BLUE}[$CURRENT/$TOTAL]${NC} Cloning: ${GREEN}$name${NC}"
    if gh repo clone "$ORG/$name" "$name" -- --quiet; then
      CLONED=$((CLONED + 1))
    else
      echo -e "${RED}Failed to clone: $name${NC}"
    fi
  fi
done <<< "$REPOS"

echo ""
echo -e "${GREEN}Done!${NC}"
echo -e "  Cloned: ${GREEN}$CLONED${NC}"
echo -e "  Skipped (already exists): ${YELLOW}$SKIPPED${NC}"
echo -e "  Skipped (archived): ${YELLOW}$ARCHIVED${NC}"
echo -e "  Total: $TOTAL"
