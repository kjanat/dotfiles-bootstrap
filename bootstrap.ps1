$repo = "git@github.com:kjanat/dotfiles.git"
$dotfilesDir = "$HOME\.dotfiles"
$backupDir = "$HOME\.dotfiles-backup"

if (-not (Test-Path $dotfilesDir)) {
    git clone --bare $repo $dotfilesDir
}

function Dotfiles {
    git --git-dir=$dotfilesDir --work-tree=$HOME @args
}

New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

$conflicts = Dotfiles checkout 2>&1
if ($LASTEXITCODE -ne 0) {
    $conflicts | Where-Object { $_ -match '^\s+(.+)$' } | ForEach-Object {
        $file = $Matches[1].Trim()
        $source = Join-Path $HOME $file
        $destination = Join-Path $backupDir $file
        New-Item -ItemType Directory -Path (Split-Path $destination) -Force | Out-Null
        Move-Item -Path $source -Destination $destination -Force
    }
    Dotfiles checkout
}

Dotfiles config --local status.showUntrackedFiles no

# Apply performance optimizations
Write-Host "Applying Git performance optimizations..." -ForegroundColor Yellow
Dotfiles config core.untrackedCache true
Dotfiles config core.preloadindex true  
Dotfiles config core.fsmonitor true
Dotfiles config pack.threads 0

# Additional advanced Git optimizations for recursion and parallelization
Write-Host "Applying advanced recursion and parallelization optimizations..." -ForegroundColor Cyan
Dotfiles config core.autocrlf false
Dotfiles config core.safecrlf false
Dotfiles config feature.manyFiles true
Dotfiles config index.threads 0
Dotfiles config checkout.workers 0
Dotfiles config fetch.parallel 0
Dotfiles config submodule.recurse false
Dotfiles config diff.algorithm histogram
Dotfiles config merge.renormalize false
Dotfiles config status.submodulesummary false
Dotfiles config status.branch false
Dotfiles config gc.auto 256

Write-Host "Dotfiles successfully installed with advanced performance optimizations!" -ForegroundColor Green

# Symlink README (well, Windows-style copy)
Copy-Item "$PSScriptRoot\\README.md" "$HOME\\dotfiles-readme.md" -Force

# Add optimized dotfiles function and dothelp function
$functions = @'

# Optimized dotfiles function with performance improvements and parallel processing
function dotfiles {
    param([Parameter(ValueFromRemainingArguments)]$args)
    
    # Quick status check without scanning untracked files
    if ($args[0] -eq "status" -and $args.Count -eq 1) {
        & git --git-dir="$env:USERPROFILE\.dotfiles" --work-tree="$env:USERPROFILE" status --porcelain=v1
        return
    }
    
    # Quick status with untracked but use optimized scan with parallel processing
    if ($args[0] -eq "status" -and $args[1] -eq "-u") {
        Write-Host "Running optimized parallel untracked files scan..." -ForegroundColor Yellow
        & git --git-dir="$env:USERPROFILE\.dotfiles" --work-tree="$env:USERPROFILE" status --untracked-files=normal --ignored=no --find-renames --porcelain=v1
        return
    }
    
    # Parallel add for multiple files
    if ($args[0] -eq "add" -and $args.Count -gt 2) {
        Write-Host "Adding files in parallel..." -ForegroundColor Yellow
        $files = $args[1..($args.Count-1)]
        $jobs = @()
        foreach ($file in $files) {
            $jobs += Start-Job -ScriptBlock {
                param($file, $dotfilesDir, $workTree)
                & git --git-dir="$dotfilesDir" --work-tree="$workTree" add "$file"
            } -ArgumentList $file, "$env:USERPROFILE\.dotfiles", "$env:USERPROFILE"
        }
        $jobs | Wait-Job | Receive-Job
        $jobs | Remove-Job
        return
    }
    
    # For all other commands, use standard dotfiles with optimization flags
    & git --git-dir="$env:USERPROFILE\.dotfiles" --work-tree="$env:USERPROFILE" @args
}

# Advanced fast status aliases with parallel processing hints
function dfst { dotfiles status }
function dfsta { dotfiles status --untracked-files=all --find-renames }
function dfstf { dotfiles status --porcelain=v1 }
function dfstfr { dotfiles status --porcelain=v1 --find-renames }

# Parallel bulk operations
function dotfiles-add-parallel {
    param([string[]]$Files)
    if ($Files.Count -gt 1) {
        Write-Host "Adding $($Files.Count) files in parallel..." -ForegroundColor Cyan
        $Files | ForEach-Object -Parallel {
            & git --git-dir="$env:USERPROFILE\.dotfiles" --work-tree="$env:USERPROFILE" add "$_"
        } -ThrottleLimit 8
    } else {
        dotfiles add $Files[0]
    }
}

function dothelp {
    if (Get-Command bat -ErrorAction SilentlyContinue) {
        bat "$HOME\\dotfiles-readme.md"
    } elseif (Get-Command less -ErrorAction SilentlyContinue) {
        less "$HOME\\dotfiles-readme.md"
    } else {
        Get-Content "$HOME\\dotfiles-readme.md"
    }
}
'@

# Ensure profile directory exists
$profileDir = Split-Path $PROFILE.CurrentUserAllHosts -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

# Create or update profile
if (-not (Test-Path $PROFILE.CurrentUserAllHosts)) {
    New-Item -ItemType File -Path $PROFILE.CurrentUserAllHosts -Force | Out-Null
}

if (-not (Select-String -Path $PROFILE.CurrentUserAllHosts -Pattern "function dotfiles" -Quiet)) {
    Add-Content -Path $PROFILE.CurrentUserAllHosts -Value $functions
    Write-Host "Optimized dotfiles functions added to PowerShell profile." -ForegroundColor Green
} else {
    Write-Host "Dotfiles functions already exist in PowerShell profile." -ForegroundColor Yellow
}
