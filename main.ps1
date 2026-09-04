#===========================================================================================================
# Force Elevation

# Check and run the script as admin if required
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
if (! $myWindowsPrincipal.IsInRole($adminRole)) {
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;
    $newProcess.Verb = "runas";
    [System.Diagnostics.Process]::Start($newProcess) | Out-Null
    exit
}

#===========================================================================================================
# Prepare the Terminal

$Host.UI.RawUI.WindowTitle = "MineFartS' Ventoy Flasher"

$ErrorActionPreference = "Stop"

Clear-Host

Set-Location $PSScriptRoot

#===========================================================================================================
# Prompt for the Image File

Add-Type -AssemblyName System.Windows.Forms

$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog.Title = 'Select an ISO file to mount'
$dialog.InitialDirectory = [System.Environment+SpecialFolder]::MyComputer
$dialog.Filter = 'Disk Images (*.iso; *.vhd)|*.iso;*.vhd'
$dialog.ShowDialog() | Out-Null

$SourceFile = $dialog.FileName

#===========================================================================================================
# Prompt for the USB Drive Number

Get-Disk | Where-Object BusType -eq "USB" | Select-Object @(
    "Number",
    "FriendlyName",
    @{Name="Size"; Expression={"{0:N2} GB" -f ($_.Size / 1GB)}}
) | Format-Table | Out-Host

$DriveNum = Read-Host "Enter the Drive Number"

#===========================================================================================================
# Init Submodules

git.exe submodule update --init --recursive

#===========================================================================================================
# Install Ventoy on USB Drive

Push-Location "./ventoy"

.\Ventoy2Disk.exe VTOYCLI /I /g /y /PhyDrive:$DriveNum

Pop-Location

#===========================================================================================================

