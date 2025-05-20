# ---------------------- SETTINGS ----------------------
$quarantineFolderName = "Quarantine"
$logPath = "$env:USERPROFILE\usb_shield_log.txt"
$suspiciousExtensions = @(".exe", ".vbs", ".bat", ".cmd", ".scr", ".pif", ".msi")
$maxSafeFileSizeMB = 100
$minFileSizeKB = 1
$autoDeleteAutorun = $true
# ------------------------------------------------------

function Write-Log {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logPath -Value "$timestamp | $Message"
}

function Get-FileHashSHA256 {
    param ([string]$FilePath)
    try {
        return (Get-FileHash -Path $FilePath -Algorithm SHA256).Hash
    } catch {
        Write-Log "ERROR: Cannot compute hash for $FilePath"
        return $null
    }
}

function Play-AlertSound {
    [console]::beep(1000, 300)
}

function Quarantine-File {
    param (
        [string]$FilePath,
        [string]$QuarantinePath
    )
    try {
        $destination = Join-Path $QuarantinePath (Split-Path $FilePath -Leaf)
        Move-Item -Path $FilePath -Destination $destination -Force
        Write-Host ">> Quarantined: $FilePath" -ForegroundColor Yellow
        Write-Log "Moved to quarantine: $FilePath"
    } catch {
        Write-Log "ERROR: Failed to quarantine $FilePath"
    }
}

function Scan-USBDrive {
    param ([string]$DriveLetter)

    Write-Host "`nScanning USB Drive: $DriveLetter..." -ForegroundColor Cyan
    Write-Log "=== Scan started on drive $DriveLetter ==="

    $quarantinePath = Join-Path $DriveLetter $quarantineFolderName
    if (-not (Test-Path $quarantinePath)) {
        New-Item -ItemType Directory -Path $quarantinePath | Out-Null
    }

    # Remove/rename autorun.inf
    $autorunFile = Join-Path $DriveLetter "autorun.inf"
    if (Test-Path $autorunFile) {
        if ($autoDeleteAutorun) {
            Remove-Item $autorunFile -Force
            Write-Log "Deleted autorun.inf"
            Write-Host ">> Deleted autorun.inf" -ForegroundColor Red
        } else {
            Rename-Item -Path $autorunFile -NewName "autorun_backup.inf"
            Write-Log "Renamed autorun.inf"
        }
    }

    $files = Get-ChildItem -Path "$DriveLetter\" -Recurse -File -ErrorAction SilentlyContinue

    foreach ($file in $files) {
        $hash = Get-FileHashSHA256 -FilePath $file.FullName
        $sizeMB = [math]::Round($file.Length / 1MB, 2)
        $sizeKB = [math]::Round($file.Length / 1KB, 2)
        $isSuspicious = $false

        # Check for suspicious extension
        if ($suspiciousExtensions -contains $file.Extension.ToLower()) {
            $isSuspicious = $true
            Write-Host "!! Suspicious extension: $($file.FullName)" -ForegroundColor Red
            Write-Log "Suspicious extension: $($file.FullName)"
        }

        # Check for abnormal file sizes
        if ($sizeMB -gt $maxSafeFileSizeMB -or $sizeKB -lt $minFileSizeKB) {
            $isSuspicious = $true
            Write-Host "!! Suspicious file size: $($file.FullName) ($sizeMB MB)" -ForegroundColor DarkRed
            Write-Log "Suspicious file size: $($file.FullName) ($sizeMB MB)"
        }

        # Quarantine if suspicious
        if ($isSuspicious) {
            Play-AlertSound
            Quarantine-File -FilePath $file.FullName -QuarantinePath $quarantinePath
        }

        # Log all file hashes
        Write-Log "Scanned: $($file.FullName) | Size: $sizeMB MB | SHA256: $hash"
    }

    Write-Log "=== Scan completed on drive $DriveLetter ===`n"
    Write-Host "✅ Scan completed for $DriveLetter. Logs saved at $logPath"
}

# Detect all removable drives
$usbDrives = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 }

if ($usbDrives.Count -eq 0) {
    Write-Host "❌ No USB drives detected. Insert a drive and run again." -ForegroundColor Gray
    Write-Log "No USB detected during scan."
    exit
}

foreach ($drive in $usbDrives) {
    Scan-USBDrive -DriveLetter $drive.DeviceID
}
