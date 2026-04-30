# =====================================================================
# Proof of Travel — video import script
#
# Copies the user's source videos into src\assets\videos\ with the names
# the site expects. Run once whenever you have new videos to bring in.
#
# Usage:
#   1. Edit $source below to point at the folder where your video files live.
#   2. From PowerShell:
#        cd C:\develop\pot-website
#        .\scripts\import-videos.ps1
#   3. (First run only) if PowerShell blocks the script, allow it for the
#      current session:
#        Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
# =====================================================================

# ---- EDIT THIS ----
$source = "C:\Users\alexs\Videos"   # <-- folder containing your .mp4 files
# -------------------

$dest = Join-Path $PSScriptRoot "..\src\assets\videos"
$dest = (Resolve-Path $dest).Path

if (-not (Test-Path $source)) {
    Write-Host "ERROR: source folder not found: $source" -ForegroundColor Red
    Write-Host "Edit \$source at the top of this script and re-run." -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }

# Map: source filename -> destination filename
$map = @(
    @{ src = "Proof of Travel (Landscape).mp4";                          dst = "overview.mp4"        }
    @{ src = "PoT Case Study # 1.mp4";                                   dst = "case-study-1.mp4"    }
    @{ src = "Case Study # 2. Corporate Travel Audit.mp4";               dst = "case-study-2.mp4"    }
    @{ src = "Case Study #3_ When Systems Change, Proof Remains.mp4";    dst = "case-study-3.mp4"    }
    @{ src = "Case Study #4_ When Records Don't Match.mp4";              dst = "case-study-4.mp4"    }
    @{ src = "Case Study #5_ Independent Oversight.mp4";                 dst = "case-study-5.mp4"    }
    @{ src = "Consolidators at the Centre of Travel Verification.mp4";   dst = "consolidators.mp4"   }
    @{ src = "Proof of Travel_ Q&A with the Architect.mp4";              dst = "qa.mp4"              }
)

Write-Host ""
Write-Host "Source: $source"
Write-Host "Destination: $dest"
Write-Host ""

$copied = 0
$missing = @()
$totalBytes = 0

foreach ($item in $map) {
    $srcPath = Join-Path $source $item.src
    $dstPath = Join-Path $dest   $item.dst
    $resolved = $null
    $matchType = ""

    if (Test-Path -LiteralPath $srcPath) {
        $resolved  = $srcPath
        $matchType = "exact"
    } else {
        # Fallback: build a wildcard pattern by replacing characters that
        # are commonly mangled by Word/macOS smart-quote conversion
        # (apostrophe, quotes, dashes) with the single-char wildcard "?".
        $pattern = $item.src -replace "['`"‘’“”–—]", "?"
        $patternPath = Join-Path $source $pattern
        $hits = @(Get-ChildItem -Path $patternPath -ErrorAction SilentlyContinue)
        if ($hits.Count -eq 1) {
            $resolved  = $hits[0].FullName
            $matchType = "fuzzy"
        }
    }

    if ($resolved) {
        Copy-Item -LiteralPath $resolved -Destination $dstPath -Force
        $sz = (Get-Item -LiteralPath $dstPath).Length
        $totalBytes += $sz
        $sizeMB = [math]::Round($sz / 1MB, 1)
        $tag = if ($matchType -eq "fuzzy") { "OK*" } else { "OK " }
        Write-Host ("  [{0}]  {1,-22} ({2} MB)  <-  {3}" -f $tag, $item.dst, $sizeMB, (Split-Path -Leaf $resolved)) -ForegroundColor Green
        $copied++
    } else {
        Write-Host ("  [MISS] {0,-22} <-  {1}" -f $item.dst, $item.src) -ForegroundColor Yellow
        $missing += $item.src
    }
}

Write-Host ""
$totalMB = [math]::Round($totalBytes / 1MB, 1)
Write-Host "Copied $copied of $($map.Count) videos. Total size: $totalMB MB" -ForegroundColor Cyan

# Azure Static Web Apps Free-tier deployment limit is 500 MB per deployment.
if ($totalBytes -gt 500MB) {
    Write-Host "WARNING: total video size ($totalMB MB) exceeds Azure SWA Free-tier 500 MB deployment cap." -ForegroundColor Red
    Write-Host "         Compress with HandBrake (H.264, 1080p, ~2 Mbps) or move videos to Azure Blob Storage." -ForegroundColor Red
}

if ($missing.Count -gt 0) {
    Write-Host ""
    Write-Host "Files not found in source folder:" -ForegroundColor Yellow
    $missing | ForEach-Object { Write-Host "  - $_" }
    Write-Host "Check the filenames or update the `$map list at the top of this script." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Preview locally:   npx http-server src -p 8080 -c-1"
Write-Host "  2. Commit and push:   git add . ; git commit -m 'Add videos' ; git push"
