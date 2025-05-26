<#
.SYNOPSIS
    Advanced performance optimization module for dotfiles management
.DESCRIPTION
    Provides advanced parallel processing, recursive optimization, and performance monitoring
    for dotfiles operations. Implements PowerShell runspace pools and advanced Git optimizations.
.NOTES
    Author: kjanat
    Version: 2.0 - Advanced Performance Edition
#>

# Advanced parallel processing using runspace pools
function Invoke-ParallelGitOperations {
    <#
    .SYNOPSIS
        Execute Git operations in parallel using PowerShell runspace pools
    .PARAMETER Operations
        Array of Git operations to execute in parallel
    .PARAMETER MaxThreads
        Maximum number of concurrent threads (default: CPU cores)
    #>
    param(
        [Parameter(Mandatory)]
        [array]$Operations,
        [int]$MaxThreads = [Environment]::ProcessorCount
    )
    
    $runspacePool = [runspacefactory]::CreateRunspacePool(1, $MaxThreads)
    $runspacePool.Open()
    $jobs = @()
    
    try {
        foreach ($operation in $Operations) {
            $powershell = [powershell]::Create()
            $powershell.RunspacePool = $runspacePool
            
            $scriptBlock = {
                param($op)
                & git --git-dir="$env:USERPROFILE\.dotfiles" --work-tree="$env:USERPROFILE" @op
            }
            
            $null = $powershell.AddScript($scriptBlock)
            $null = $powershell.AddArgument($operation)
            
            $jobs += [PSCustomObject]@{
                PowerShell = $powershell
                Handle = $powershell.BeginInvoke()
            }
        }
        
        # Wait for all jobs to complete and collect results
        $results = @()
        foreach ($job in $jobs) {
            $results += $job.PowerShell.EndInvoke($job.Handle)
            $job.PowerShell.Dispose()
        }
        
        return $results
    }
    finally {
        $runspacePool.Close()
        $runspacePool.Dispose()
    }
}

function Get-DotfilesPerformanceMetrics {
    <#
    .SYNOPSIS
        Collect and display performance metrics for dotfiles operations
    .DESCRIPTION
        Monitors and reports on Git repository performance, cache utilization, and optimization status
    #>
    Write-Host "🔍 Dotfiles Performance Analysis" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    
    # Repository size and objects
    $repoPath = "$env:USERPROFILE\.dotfiles"
    if (Test-Path $repoPath) {
        $repoSize = (Get-ChildItem $repoPath -Recurse -Force | Measure-Object Length -Sum).Sum
        $objectCount = (& git --git-dir="$repoPath" count-objects -v | Select-String "count").ToString().Split()[1]
        
        Write-Host "Repository Size: $([math]::Round($repoSize / 1MB, 2)) MB" -ForegroundColor Green
        Write-Host "Git Objects: $objectCount" -ForegroundColor Green
    }
    
    # Performance settings audit
    Write-Host "`nPerformance Settings:" -ForegroundColor Yellow
    $settings = @(
        "core.untrackedCache",
        "core.preloadindex",
        "core.fsmonitor",
        "pack.threads",
        "index.threads",
        "checkout.workers",
        "fetch.parallel",
        "feature.manyFiles"
    )
    
    foreach ($setting in $settings) {
        try {
            $value = & git --git-dir="$repoPath" config --get $setting 2>$null
            $status = if ($value) { "✓ $value" } else { "✗ Not set" }
            Write-Host "  $setting`: $status" -ForegroundColor $(if ($value) { "Green" } else { "Red" })
        }
        catch {
            Write-Host "  $setting`: ✗ Error checking" -ForegroundColor Red
        }
    }
    
    # Cache information
    Write-Host "`nCache Information:" -ForegroundColor Yellow
    try {
        $untracked = & git --git-dir="$repoPath" config --get core.untrackedCache
        if ($untracked -eq "true") {
            Write-Host "  Untracked cache: ✓ Enabled" -ForegroundColor Green
        }
        
        $indexCacheExists = Test-Path "$repoPath\index"
        Write-Host "  Index cache: $(if ($indexCacheExists) { '✓ Present' } else { '✗ Missing' })" -ForegroundColor $(if ($indexCacheExists) { "Green" } else { "Yellow" })
    }
    catch {
        Write-Host "  Cache status: ✗ Unable to determine" -ForegroundColor Red
    }
}

function Optimize-DotfilesRecursive {
    <#
    .SYNOPSIS
        Perform recursive optimization of dotfiles repository structure
    .DESCRIPTION
        Analyzes directory structure and optimizes Git performance for deep recursion
    #>
    param(
        [switch]$DeepScan,
        [int]$MaxDepth = 10
    )
    
    Write-Host "🔧 Recursive Dotfiles Optimization" -ForegroundColor Cyan
    
    $repoPath = "$env:USERPROFILE\.dotfiles"
    if (-not (Test-Path $repoPath)) {
        Write-Warning "Dotfiles repository not found"
        return
    }
    
    # Analyze directory depth and file distribution
    $homeFiles = Get-ChildItem $env:USERPROFILE -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer -eq $false }
    $depths = @{}
    
    foreach ($file in $homeFiles) {
        $depth = ($file.FullName.Replace($env:USERPROFILE, "").Split([IO.Path]::DirectorySeparatorChar) | Where-Object { $_ }).Count
        if ($depth -le $MaxDepth) {
            $depths[$depth] = ($depths[$depth] ?? 0) + 1
        }
    }
    
    Write-Host "Directory Depth Analysis:" -ForegroundColor Yellow
    foreach ($depth in ($depths.Keys | Sort-Object)) {
        Write-Host "  Depth $depth`: $($depths[$depth]) files" -ForegroundColor Green
    }
    
    # Configure Git for optimal recursive performance
    Write-Host "`nApplying recursive optimizations..." -ForegroundColor Yellow
    
    $optimizations = @{
        "core.longpaths" = "true"
        "core.protectNTFS" = "false"
        "core.fscache" = "true"
        "status.ahead-behind" = "false"
        "diff.renameLimit" = "999999"
        "merge.renameLimit" = "999999"
        "log.abbrevCommit" = "true"
        "log.decorate" = "short"
    }
    
    foreach ($setting in $optimizations.GetEnumerator()) {
        & git --git-dir="$repoPath" config $setting.Key $setting.Value
        Write-Host "  Set $($setting.Key) = $($setting.Value)" -ForegroundColor Green
    }
    
    # Optimize Git garbage collection for large recursions
    & git --git-dir="$repoPath" config gc.auto 1024
    & git --git-dir="$repoPath" config gc.autopacklimit 128
    & git --git-dir="$repoPath" config repack.usedeltabaseoffset true
    
    Write-Host "✅ Recursive optimization completed!" -ForegroundColor Green
}

function Start-ParallelDotfilesSync {
    <#
    .SYNOPSIS
        Synchronize multiple aspects of dotfiles in parallel
    .DESCRIPTION
        Performs fetch, status check, and repository maintenance in parallel for maximum efficiency
    #>
    Write-Host "🚀 Parallel Dotfiles Synchronization" -ForegroundColor Cyan
    
    $operations = @(
        @("fetch", "--all", "--prune"),
        @("gc", "--auto"),
        @("status", "--porcelain=v1")
    )
    
    $results = Invoke-ParallelGitOperations -Operations $operations
    
    Write-Host "✅ Parallel sync completed" -ForegroundColor Green
    return $results
}

function Enable-DotfilesParallelProcessing {
    <#
    .SYNOPSIS
        Enable all parallel processing optimizations for dotfiles
    .DESCRIPTION
        Configures the repository for maximum parallel processing performance
    #>
    Write-Host "⚡ Enabling Parallel Processing Optimizations" -ForegroundColor Cyan
    
    $repoPath = "$env:USERPROFILE\.dotfiles"
    
    # Core parallel settings
    & git --git-dir="$repoPath" config pack.threads 0               # Use all CPU cores
    & git --git-dir="$repoPath" config index.threads 0              # Parallel index operations
    & git --git-dir="$repoPath" config checkout.workers 0           # Parallel checkout
    & git --git-dir="$repoPath" config fetch.parallel 0             # Parallel fetch
    & git --git-dir="$repoPath" config submodule.fetchJobs 0        # Parallel submodule fetch
    & git --git-dir="$repoPath" config pack.window 16               # Optimize pack window
    & git --git-dir="$repoPath" config pack.depth 128               # Optimize pack depth
    & git --git-dir="$repoPath" config core.deltaBaseCacheLimit "2g" # Large delta cache
    
    Write-Host "✅ Parallel processing optimizations enabled!" -ForegroundColor Green
}

# Export all functions
Export-ModuleMember -Function @(
    'Invoke-ParallelGitOperations',
    'Get-DotfilesPerformanceMetrics',
    'Optimize-DotfilesRecursive',
    'Start-ParallelDotfilesSync',
    'Enable-DotfilesParallelProcessing'
)
