
# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}
Set-ExecutionPolicy -ExecutionPolicy unrestricted -Force

$porta=58910
#Checks for free port
$check=(netstat -aon | findStr $porta)
while($check)
 {
	$global:porta++;
    $check=(netstat -aon | findStr $porta)
 }
#Firewall rule for new port
New-NetFirewallRule -DisplayName "Remote Desktop - User Mode (TCP-In) " -Direction Inbound -Protocol TCP -Profile Any -LocalPort @($porta) -Action Allow
New-NetFirewallRule -DisplayName "Remote Desktop - User Mode (UDP-In) " -Direction Inbound -Protocol UDP -Profile Any -LocalPort @($porta) -Action Allow

#Enable Network Discovery
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes

#Set as RDP port
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Terminal*Server\WinStations\RDP-TCP\ -Name PortNumber -Value $porta

#Enable RDP
Set-ItemProperty ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\‘ -Name “fDenyTSConnections” -Value 0

#Enable Network Level Authentication
Set-ItemProperty ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\‘ -Name “UserAuthentication” -Value 1


$IP=(Test-Connection -ComputerName (hostname) -Count 1  | Select IPV4Address |findstr [0-9])
$adresa=$IP.Split()[-1]

#Prints socket for RDP
Write-host "$($adresa):$($porta)"

New-Item C:\Users\$env:USERNAME\Desktop\RDP.rdp -type file
#Creates RDP file 
Add-Content C:\Users\$env:USERNAME\Desktop\RDP.rdp "screen mode id:i:2
use multimon:i:0
desktopwidth:i:1280
desktopheight:i:1024
session bpp:i:32
winposstr:s:0,1,2085,140,2885,802
compression:i:1
keyboardhook:i:2
audiocapturemode:i:0
videoplaybackmode:i:1
connection type:i:7
networkautodetect:i:1
bandwidthautodetect:i:1
displayconnectionbar:i:1
enableworkspacereconnect:i:0
disable wallpaper:i:0
allow font smoothing:i:0
allow desktop composition:i:0
disable full window drag:i:1
disable menu anims:i:1
disable themes:i:0
disable cursor setting:i:0
bitmapcachepersistenable:i:1
full address:s:$($adresa):$($porta)
audiomode:i:0
redirectprinters:i:1
redirectcomports:i:0
redirectsmartcards:i:1
redirectclipboard:i:1
redirectposdevices:i:0
autoreconnection enabled:i:1
authentication level:i:2
prompt for credentials:i:0
negotiate security layer:i:1
remoteapplicationmode:i:0
alternate shell:s:
shell working directory:s:
gatewayhostname:s:
gatewayusagemethod:i:4
gatewaycredentialssource:i:4
gatewayprofileusagemethod:i:0
promptcredentialonce:i:0
gatewaybrokeringtype:i:0
use redirection server name:i:0
rdgiskdcproxy:i:0
kdcproxyname:s:
drivestoredirect:s:
"
Write-Warning "For the changes to take effect is required to reboot the computer"
$read = Read-Host "Would you like to do it now (y/n): ?"
switch($read){
    "y" {Restart-Computer}
}
