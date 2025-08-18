#!/usr/bin/env bash
# ABOUTME: Script to show package changes between home-manager generations
# ABOUTME: Handles broken symlinks gracefully and shows meaningful diffs

set -euo pipefail

PROFILE_DIR="$HOME/.local/state/nix/profiles"
PROFILE_PATH="$PROFILE_DIR/home-manager"

# Function to get the two most recent valid generations
get_recent_generations() {
    local generations=()
    
    # Find all valid home-manager generation links, sorted by number
    for link in "$PROFILE_DIR"/home-manager-*-link; do
        if [ -e "$link" ] && [ -e "$(readlink "$link")" ]; then
            generations+=("$(readlink "$link")")
        fi
    done
    
    # Sort by modification time and get the two most recent
    if [ ${#generations[@]} -lt 2 ]; then
        return 1
    fi
    
    printf '%s\n' "${generations[@]}" | tail -2
}

# Main function to show diff
show_diff() {
    local mode="${1:-last}"
    
    case "$mode" in
        "all")
            echo "=== All Home Manager Profile Changes ==="
            if ! nix profile diff-closures --profile "$PROFILE_PATH" 2>/dev/null; then
                echo "Unable to show full profile history (some generations may be garbage collected)"
                echo "Falling back to last two generations..."
                show_diff "last"
            fi
            ;;
        "last"|*)
            echo "=== Changes Since Last Generation ==="
            
            local generations
            if ! generations=$(get_recent_generations); then
                echo "Not enough valid generations to compare"
                return 1
            fi
            
            local prev_gen current_gen
            prev_gen=$(echo "$generations" | head -1)
            current_gen=$(echo "$generations" | tail -1)
            
            if [ "$prev_gen" = "$current_gen" ]; then
                echo "No changes between generations"
                return 0
            fi
            
            echo "Comparing:"
            echo "  Previous: $(basename "$prev_gen")"
            echo "  Current:  $(basename "$current_gen")"
            echo
            
            if ! nix store diff-closures "$prev_gen" "$current_gen"; then
                echo "No package changes detected"
            fi
            ;;
    esac
}

# Handle command line arguments
case "${1:-last}" in
    "--all"|"all")
        show_diff "all"
        ;;
    "--help"|"-h"|"help")
        echo "Usage: $(basename "$0") [all|last|help]"
        echo "  all   - Show all profile changes (may fail with broken generations)"
        echo "  last  - Show changes since last generation (default)"
        echo "  help  - Show this help message"
        ;;
    *)
        show_diff "last"
        ;;
esac