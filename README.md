# Automated Windows Update Task Setup

## What is `setup-daily-windows-update-task.ps1`?

`setup-daily-windows-update-task.ps1` is a self-contained PowerShell script that automates the process of scheduling daily Windows and application updates on your system. When run as an administrator, it:

- Creates a folder at `C:\scripts` (if it doesn't already exist).
- Writes a comprehensive update script (`install-windows-updates-no-reboot.ps1`) into that folder.
- Registers a Windows Scheduled Task named `DailyWindowsUpdateNoReboot` to run the update script every day at 5:00 AM as the SYSTEM user, with the highest privileges.

## Why is this Useful?

- **Automated Maintenance:** Ensures your system and applications are kept up to date without manual intervention.
- **Comprehensive Updates:** Not only keeps Windows itself up to date, but also upgrades many third-party applications available through the Windows Package Manager (`winget`).
- **No Forced Reboots:** Installs updates without automatically rebooting, so you maintain control over when reboots occur.
- **Modern Compatibility:** Uses PowerShell and Windows-native tools, compatible with Windows 10, 11, and modern Windows Server versions.
- **Best Practices:** Runs as SYSTEM with highest privileges for reliability, and stores scripts in a dedicated folder for easy management.

## How to Use

### 1. Prerequisites
- You must have administrator privileges to run the setup script and register scheduled tasks.
- PowerShell 5.1 or later (default on Windows 10/11/Server 2016+).

### 2. Setup Steps
1. **Open PowerShell as Administrator**
   - Search for "PowerShell" in the Start menu, right-click, and select "Run as administrator".
2. **Navigate to the Script Directory**
   - Use `cd` to change to the directory containing `setup-daily-windows-update-task.ps1`.
3. **Run the Setup Script**
   ```powershell
   .\setup-daily-windows-update-task.ps1
   ```
4. **Verify the Task**
   - Open Task Scheduler and confirm the `DailyWindowsUpdateNoReboot` task exists, is set to run as SYSTEM, and is configured to run with highest privileges.
   - The script will be located at `C:\scripts\install-windows-updates-no-reboot.ps1`.

### 3. How it Works
- Every day at 5:00 AM (local system time), the scheduled task runs the update script.
- The script:
  - Ensures secure download protocols and trusted repositories.
  - Installs or updates the NuGet provider, PowerShell Gallery, and `winget` if needed.
  - **Upgrades all applications available via `winget`, including many popular third-party apps (e.g., browsers, editors, utilities), in addition to Microsoft Store apps.**
  - Installs the `PSWindowsUpdate` module if missing.
  - Checks for and installs Windows Updates (without rebooting).

### 4. Best Practices
- **Monitor Update Results:** Review the output of the script or Task Scheduler history to ensure updates are being applied.
- **Manual Reboots:** Plan for manual reboots after critical updates, as the script does not force a reboot.
- **Update the Script:** If you modify the update logic, re-run the setup script to deploy the latest version to `C:\scripts` and update the scheduled task.
- **Time Zone:** The task runs at 5:00 AM local system time. Adjust the time in the script if you need a different schedule.

## Troubleshooting
- **Permissions:** Ensure you run the setup script as an administrator.
- **Task Not Running:** Check Task Scheduler for errors or review the script output for issues with module installation or update commands.
- **Compatibility:** The script is designed for Windows 10, 11, and modern Windows Server versions. For older systems, manual adjustments may be required.

---

For further customization or automation, you can edit the script or scheduled task as needed. This setup provides a robust, hands-off approach to keeping your Windows system and applications up to date. 
