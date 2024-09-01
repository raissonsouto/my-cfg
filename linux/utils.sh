#!/bin/bash

# Log colors
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

function echo_session {
    local text="$1"
    local text_length=${#text}
    local line_length=$((text_length + 8))

    local line=$(printf "%${line_length}s" | tr ' ' '-')

    echo ""
    echo -e "${YELLOW}${line}${NC}"
    echo -e "${YELLOW}   ${text}   ${NC}"
    echo -e "${YELLOW}${line}${NC}"
    echo ""
}

function echo_topic {
    echo -e "${YELLOW}[*]${NC} $1"
}

function echo_subtopic {
    echo -e "${YELLOW} |_${NC} $1"
}

function echo_error {
    echo -e "${RED}ERROR: $1${NC}"
    exit 1
}
