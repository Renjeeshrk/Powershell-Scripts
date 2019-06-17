
 # Script info    :  Network Switch Automated Backup using SSH and TFTP
# Script          :  Network_switch_auto_backup.ps1
# Verified on     :  Cisco(iOS)
# Version         :  V-1.0
# Last Modified   :  5/12/2019
# The Script can be used for the configuration backup of network devices which are accessible via ssh.
# .SYNOPSIS
################################################################################
#import posh-ssh
Import-Module -name posh-ssh
 
# Globals
$today = Get-Date -Format "ddMMyyy"
$month = Get-Date -Format MMMM
$year = Get-Date -Format "yyyy"
$tftp_server = "xx.xx.xx.xx"
 
# create a folder for every year
Get-Item "C:\Users\Test\Desktop\RK\$year\" -ErrorAction SilentlyContinue
if (!$?)
    {
    New-Item "C:\Users\Test\Desktop\RK\$year\" -ItemType Directory
    }
 
# create a folder for every month
Get-Item "C:\Users\Test\Desktop\RK\$year\$month\" -ErrorAction SilentlyContinue
if (!$?)
    {
    New-Item "C:\Users\Test\Desktop\RK\$year\$month\" -ItemType Directory
    }
 
# create a folder for every day
Get-Item "C:\Users\Test\Desktop\RK\$year\$month\$today\" -ErrorAction SilentlyContinue
if (!$?)
    {
    New-Item "C:\Users\Test\Desktop\RK\$year\$month\$today\" -ItemType Directory
    }
 
# simple credential handling
$username = "hgcadmin"
$username1 = ""
$pwfile = "C:\Users\Test\Desktop\RK\password.txt"
$Credentials=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, (Get-Content $pwfile | ConvertTo-SecureString)
# put all the devices in this array
$switches_array = @()
$switches_array = Get-Content -Path "C:\Users\test\Desktop\RK\switches.txt"
 
foreach ($switch in $switches_array)
    {
    # create a folder for every device
    Get-Item "C:\Users\test\Desktop\RK\$year\$month\$today\$switch" -ErrorAction SilentlyContinue
    if (!$?)
        {
        New-Item "C:\Users\test\Desktop\RK\$year\$month\$today\$switch" -ItemType Directory
        }
    # start the SSH Session
    New-SSHSession -ComputerName $switch -Credential $Credentials -AcceptKey:$true
    $session = Get-SSHSession -Index 0
    # usual SSH won't work, we need a shell stream for the procurve
    $stream = $session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)
    # send a "space" for the "Press any key to continue" and wait before you issue the next command
    $stream.Write("`n")
    Sleep 5
    # Change to Enable mode
    $stream.Write("enable`n")
    $stream.Write("%password%`n")
    # copy startup-config and wait before you issue the next command
    $stream.Write("copy startup-config tftp:`n")
    $stream.Write("$tftp_server`n")
    $stream.Write("\$year\$month\$today\$switch\Startup-config`n")
    Sleep 10
    # copy running-config and wait before you issue the next command
    $stream.Write("copy running-config tftp:`n")
    $stream.Write("$tftp_server`n")
    $stream.Write("\$year\$month\$today\$switch\Running-config`n")
    Sleep 10
    # disconnect from host
    Remove-SSHSession -SessionId 0
    
    }
