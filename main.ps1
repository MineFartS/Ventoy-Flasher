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

git.exe submodule update --init --recursive --remote

#===========================================================================================================
# Install Ventoy on USB Drive

& "ventoy\run.ps1" /I /g /y /PhyDrive:$DriveNum

#===========================================================================================================

$Letter = (Get-Disk -Number $DriveNum | Get-Partition | Select-Object -First 1 | Get-Volume).DriveLetter

$ISOs = @(
    "rescuezilla-*.iso"
    $dialog.FileName
)

$ISOs | ForEach-Object {

    $ISO = (Resolve-Path $_).ProviderPath
    
    robocopy.exe `
        (Split-Path $ISO) `
        "$Letter`:\" `
        (Split-Path $ISO -Leaf) `
        /Z /R:5 /W:3

}

#===========================================================================================================
