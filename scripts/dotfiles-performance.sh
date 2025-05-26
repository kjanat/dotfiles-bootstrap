#!/usr/bin/env bash
# Advanced performance optimization script for Unix-like systems
# Provides parallel processing, recursive optimization, and performance monitoring

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="$HOME/.dotfiles"
MAX_PARALLEL_JOBS=${MAX_PARALLEL_JOBS:-$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)}

# Utility functions
print_header() {
    echo -e "${CYAN}🔧 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if dotfiles repository exists
check_dotfiles_repo() {
    if [ ! -d "$DOTFILES_DIR" ]; then
        print_error "Dotfiles repository not found at $DOTFILES_DIR"
        exit 1
    fi
}

# Advanced Git performance configuration
apply_advanced_git_optimizations() {
    print_header "Applying Advanced Git Optimizations"

    check_dotfiles_repo

    # Core performance settings
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config core.untrackedCache true
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config core.preloadindex true
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config core.fscache true

    # Parallel processing settings
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config pack.threads 0
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config index.threads 0
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config checkout.workers 0
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config fetch.parallel 0
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config submodule.fetchJobs 0

    # Advanced optimizations
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config feature.manyFiles true
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config diff.algorithm histogram
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config merge.renormalize false
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config status.submodulesummary false
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config status.branch false
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config gc.auto 256
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config core.splitIndex true
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config core.untrackedCacheTimeout 300

    # Pack optimizations
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config pack.window 16
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config pack.depth 128
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config pack.windowMemory "2g"
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config core.deltaBaseCacheLimit "2g"

    # Recursive optimization
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config diff.renameLimit 999999
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config merge.renameLimit 999999
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config log.abbrevCommit true
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config log.decorate short

    print_success "Advanced Git optimizations applied"
}

# Parallel file operations using GNU parallel or xargs
parallel_operation() {
    local operation="$1"
    shift
    local files=("$@")

    if [ ${#files[@]} -eq 0 ]; then
        return 0
    fi

    if command -v parallel &>/dev/null; then
        printf '%s\n' "${files[@]}" | parallel -j "$MAX_PARALLEL_JOBS" "$operation" {}
    else
        printf '%s\n' "${files[@]}" | xargs -P "$MAX_PARALLEL_JOBS" -I {} bash -c "$operation {}"
    fi
}

# Performance metrics collection
get_performance_metrics() {
    print_header "Dotfiles Performance Analysis"

    check_dotfiles_repo

    # Repository size and objects
    local repo_size
    repo_size=$(du -sh "$DOTFILES_DIR" 2>/dev/null | cut -f1)
    local object_count
    object_count=$(git --git-dir="$DOTFILES_DIR" count-objects -v | grep "^count" | awk '{print $2}')

    echo "Repository Size: $repo_size"
    echo "Git Objects: $object_count"

    # Performance settings audit
    echo
    print_info "Performance Settings:"
    local settings=(
        "core.untrackedCache"
        "core.preloadindex"
        "core.fscache"
        "pack.threads"
        "index.threads"
        "checkout.workers"
        "fetch.parallel"
        "feature.manyFiles"
    )

    for setting in "${settings[@]}"; do
        local value
        value=$(git --git-dir="$DOTFILES_DIR" config --get "$setting" 2>/dev/null)
        if [ -n "$value" ]; then
            print_success "$setting: $value"
        else
            print_warning "$setting: Not set"
        fi
    done

    # Cache information
    echo
    print_info "Cache Information:"
    local untracked_cache
    untracked_cache=$(git --git-dir="$DOTFILES_DIR" config --get core.untrackedCache 2>/dev/null)
    if [ "$untracked_cache" = "true" ]; then
        print_success "Untracked cache: Enabled"
    else
        print_warning "Untracked cache: Disabled"
    fi

    if [ -f "$DOTFILES_DIR/index" ]; then
        print_success "Index cache: Present"
    else
        print_warning "Index cache: Missing"
    fi
}

# Recursive optimization for deep directory structures
optimize_recursive_performance() {
    print_header "Recursive Performance Optimization"

    check_dotfiles_repo

    # Analyze directory depth
    print_info "Analyzing directory structure..."
    local max_depth=10
    local depth_analysis
    depth_analysis=$(find "$HOME" -maxdepth "$max_depth" -type f 2>/dev/null |
        awk -F'/' '{print NF-'$(echo "$HOME" | tr -cd '/' | wc -c)'-1}' |
        sort -n | uniq -c | sort -nr)

    echo "Directory Depth Analysis:"
    echo "$depth_analysis" | head -10

    # Apply recursive optimizations
    print_info "Applying recursive optimizations..."

    # Long path support (where applicable)
    if [[ "$OSTYPE" == "cygwin"* ]] || [[ "$OSTYPE" == "msys"* ]]; then
        git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config core.longpaths true
    fi

    # Optimize for large numbers of files
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config status.ahead-behind false
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config diff.renames copies
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config diff.renameLimit 999999
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config merge.renameLimit 999999

    # Garbage collection optimization for large repositories
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config gc.auto 1024
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config gc.autopacklimit 128
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config repack.usedeltabaseoffset true

    print_success "Recursive optimization completed"
}

# Parallel dotfiles synchronization
parallel_sync() {
    print_header "Parallel Dotfiles Synchronization"

    check_dotfiles_repo

    # Create temporary files for parallel operations
    local temp_dir
    temp_dir=$(mktemp -d)
    local fetch_log="$temp_dir/fetch.log"
    local gc_log="$temp_dir/gc.log"
    local status_log="$temp_dir/status.log"

    # Run operations in parallel
    {
        git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" fetch --all --prune >"$fetch_log" 2>&1 &
        local fetch_pid=$!

        git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" gc --auto >"$gc_log" 2>&1 &
        local gc_pid=$!

        git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" status --porcelain=v1 >"$status_log" 2>&1 &
        local status_pid=$!

        # Wait for all operations to complete
        wait $fetch_pid && print_success "Fetch completed" || print_warning "Fetch had issues"
        wait $gc_pid && print_success "Garbage collection completed" || print_warning "GC had issues"
        wait $status_pid && print_success "Status check completed" || print_warning "Status check had issues"
    }

    # Show results
    if [ -s "$status_log" ]; then
        echo "Status changes detected:"
        cat "$status_log"
    else
        print_success "Repository is clean"
    fi

    # Cleanup
    rm -rf "$temp_dir"

    print_success "Parallel synchronization completed"
}

# Enhanced dotfiles function with parallel processing
create_enhanced_dotfiles_function() {
    print_header "Creating Enhanced Dotfiles Function"

    local shell_config
    case "$SHELL" in
    */bash) shell_config="$HOME/.bashrc" ;;
    */zsh) shell_config="$HOME/.zshrc" ;;
    */fish) shell_config="$HOME/.config/fish/config.fish" ;;
    *) shell_config="$HOME/.profile" ;;
    esac

    if [ ! -f "$shell_config" ]; then
        touch "$shell_config"
    fi

    # Add enhanced dotfiles function if not present
    if ! grep -q "dotfiles_parallel" "$shell_config" 2>/dev/null; then
        cat >>"$shell_config" <<'EOF'

# Enhanced dotfiles function with parallel processing
dotfiles_parallel() {
    local repo_dir="$HOME/.dotfiles"
    local work_tree="$HOME"
    
    case "$1" in
        "add-parallel")
            shift
            if [ $# -gt 1 ] && command -v parallel &>/dev/null; then
                echo "Adding $# files in parallel..."
                printf '%s\n' "$@" | parallel git --git-dir="$repo_dir" --work-tree="$work_tree" add {}
            else
                git --git-dir="$repo_dir" --work-tree="$work_tree" add "$@"
            fi
            ;;
        "status-fast")
            git --git-dir="$repo_dir" --work-tree="$work_tree" status --porcelain=v1 --find-renames
            ;;
        "sync-parallel")
            # Parallel fetch and status
            {
                git --git-dir="$repo_dir" --work-tree="$work_tree" fetch --all --prune &
                git --git-dir="$repo_dir" --work-tree="$work_tree" status --porcelain=v1 &
                wait
            }
            ;;
        *)
            git --git-dir="$repo_dir" --work-tree="$work_tree" "$@"
            ;;
    esac
}

# Aliases for common parallel operations
alias dfp='dotfiles_parallel'
alias dfast='dotfiles_parallel status-fast'
alias dsync='dotfiles_parallel sync-parallel'
alias dadd='dotfiles_parallel add-parallel'
EOF
        print_success "Enhanced dotfiles function added to $shell_config"
    else
        print_info "Enhanced dotfiles function already exists"
    fi
}

# Main execution
main() {
    case "${1:-help}" in
    "optimize" | "opt")
        apply_advanced_git_optimizations
        optimize_recursive_performance
        ;;
    "metrics" | "perf")
        get_performance_metrics
        ;;
    "sync")
        parallel_sync
        ;;
    "enhance" | "setup")
        create_enhanced_dotfiles_function
        ;;
    "all")
        apply_advanced_git_optimizations
        optimize_recursive_performance
        create_enhanced_dotfiles_function
        print_success "All optimizations applied!"
        ;;
    "help" | *)
        echo "Usage: $0 {optimize|metrics|sync|enhance|all}"
        echo ""
        echo "Commands:"
        echo "  optimize  - Apply advanced Git and recursive optimizations"
        echo "  metrics   - Display performance metrics and analysis"
        echo "  sync      - Perform parallel synchronization"
        echo "  enhance   - Create enhanced shell functions"
        echo "  all       - Apply all optimizations"
        ;;
    esac
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
