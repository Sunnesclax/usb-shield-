# USB Shield Pro – Real-Time USB Drive Security Script (PowerShell)

# Overview
USB Shield Pro is a robust PowerShell script that adds an extra layer of security to any USB flash drive connected to a Windows computer. It scans all files in real time, detects suspicious behavior, blocks malicious autorun actions, computes secure SHA256 hashes, and safely quarantines harmful files.

This tool is ideal for IT administrators, cyber-aware users, educators, and security enthusiasts looking to protect sensitive devices from USB-borne malware, spyware, and auto-executing viruses.

# Features
✅ Real-time USB detection

✅ SHA256 file hashing for fingerprinting each file

✅ Malicious extension detection (e.g., .exe, .vbs, .bat, etc.)

✅ Abnormal file size detection

✅ Auto-delete or rename of autorun.inf

✅ Quarantine system to isolate risky files

✅ Sound alert when threats are found

✅ Detailed logging of every action

✅ Fully customizable settings

# Why This Script Matters
90% of malware attacks on physical systems are delivered via infected USB devices
— Kaspersky USB Threat Report, 2023

In environments where antivirus may not automatically scan USB devices (e.g., schools, cybercafés, or government offices), this script serves as a portable defense mechanism that users can carry and run from any system without installing additional software.

# How It Works
Detects all USB drives connected to the system.

Scans every file for:

Risky file extensions

Suspicious file sizes (e.g., 0 KB or >100MB)

Hidden autorun.inf scripts

Computes SHA256 hash for digital fingerprinting of files.

Quarantines flagged files in a separate folder (/Quarantine).

Logs all activity to a secure log file.

Alerts user through console and sound if threats are found.

# Who Is This For?
Cybersecurity students & professionals

School or office IT teams

Cybercafés and shared computing environments

Users managing USB drives with confidential data

# Requirements
PowerShell 5.1 or later (default on Windows 10/11)

Admin privileges (for full access to drives)

# How to Use
Download or clone the repository.

Save the script as usb_shield_pro.ps1.

Run PowerShell as Administrator.

Execute the script:

.\usb_shield_pro.ps1

Insert a USB drive and let the script do the rest.

# Logs and Quarantine
All actions are saved to:
C:\Users\<YourName>\usb_shield_log.txt

Suspicious files are moved to a protected:
/Quarantine folder on the USB drive.
