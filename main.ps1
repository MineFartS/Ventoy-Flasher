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

Set-PSDebug -Trace 1

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
# Prompt for the Output Drive

$dialog = New-Object System.Windows.Forms.FolderBrowserDialog
$dialog.Description = 'Select a Drive for Ventoy to be installed on'
$dialog.RootFolder = [System.Environment+SpecialFolder]::MyComputer
$dialog.ShowDialog() | Out-Null

$OutDrive = (Get-Partition -DriveLetter $dialog.SelectedPath[0] | Get-Disk)

#===========================================================================================================
# Init Submodules

git.exe submodule update --init --recursive

#===========================================================================================================

Push-Location "./ventoy"

.\Ventoy2Disk.exe VTOYCLI /I /g /y /ly /PhyDrive:$($OutDrive.Number)

Pop-Location

#===========================================================================================================

Set-PSDebug -Off
