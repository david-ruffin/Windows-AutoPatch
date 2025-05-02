 # Create C:\scripts if it doesn't exist
$scriptFolder = "C:\scripts"
if (-not (Test-Path $scriptFolder)) {
    New-Item -Path $scriptFolder -ItemType Directory | Out-Null
}

# Write the update script to C:\scripts\install-windows-updates-no-reboot.ps1
$updateScriptPath = "$scriptFolder\install-windows-updates-no-reboot.ps1"
$updateScriptContent = @'
# Check and install Windows Updates without rebooting
# Requires: PSWindowsUpdate module

# Set TLS 1.2 to ensure secure connections for downloading resources (required by PSGallery)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# --- Ensure NuGet Provider is Installed Non-Interactively ---
try {
    $nuget = Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction Stop
} catch {
    Write-Output "NuGet provider not found. Installing..."
    Install-PackageProvider -Name NuGet -MinimumVersion '2.8.5.201' -Force -Scope CurrentUser
    Import-PackageProvider -Name NuGet -MinimumVersion '2.8.5.201' -Force
}

# --- Set PSGallery Repository as Trusted ---
try {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction Stop
} catch {
    Write-Output "Unable to set PSGallery trust. Registering PSGallery repository manually..."
    Register-PSRepository -Name PSGallery -SourceLocation "https://www.powershellgallery.com/api/v2" -InstallationPolicy Trusted
}

# --- Check for winget and Install if Needed ---
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Output "winget not found. Installing winget-install script..."
    Install-Script -Name winget-install -Force -Scope CurrentUser
    $scriptCommand = Get-Command winget-install -ErrorAction SilentlyContinue
    if ($scriptCommand) {
        & $scriptCommand.Source
    } else {
        Write-Error "winget-install script not found after installation."
        exit 1
    }
} else {
    Write-Output "winget is already installed."
}

# --- Refresh the PATH Variable ---
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")

# --- Run winget Upgrade Command ---
Write-Output "Running winget upgrade for all packages..."
winget upgrade --all --silent --accept-source-agreements --accept-package-agreements

# --- Ensure PSWindowsUpdate module is installed ---
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Write-Output "PSWindowsUpdate module not found. Installing..."
    Install-Module -Name PSWindowsUpdate -Force -AllowClobber -Scope CurrentUser
}
Import-Module PSWindowsUpdate

# --- Check for available Windows Updates ---
Write-Output "Checking for available Windows Updates..."
$updates = Get-WindowsUpdate -AcceptAll -IgnoreReboot

if ($updates) {
    Write-Output "Updates found. Installing updates..."
    Install-WindowsUpdate -AcceptAll -IgnoreReboot -AutoReboot:$false -Confirm:$false
    Write-Output "Updates installed. No reboot will be performed."
} else {
    Write-Output "No updates available."
}
'@
Set-Content -Path $updateScriptPath -Value $updateScriptContent -Force

# Remove any existing scheduled task with the same name
if (Get-ScheduledTask -TaskName "DailyWindowsUpdateNoReboot" -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName "DailyWindowsUpdateNoReboot" -Confirm:$false
}

# Create the scheduled task to run daily at 5am as SYSTEM with highest privileges
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$updateScriptPath`""
$Trigger = New-ScheduledTaskTrigger -Daily -At 5:00am
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName "DailyWindowsUpdateNoReboot" -Action $Action -Trigger $Trigger -Principal $Principal

Write-Output "Task 'DailyWindowsUpdateNoReboot' created to run daily at 5am as SYSTEM with highest privileges. Script is located at $updateScriptPath."  
