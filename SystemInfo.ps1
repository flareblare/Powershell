# Script for basic system information

$computerMotherboard=Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer, Product
$computerCPU = Get-CimInstance CIM_Processor
$RAM= (systeminfo | Select-String 'Total Physical Memory:').ToString().Split(':')[1].Trim()
Clear-Host

Write-Output "System Information for:  $env:USERNAME"                                                       >> C:\Users\$env:USERNAME\Desktop\$env:USERNAME.txt

"MB: " + $computerMotherboard.Manufacturer.Split(' ')[0]  + " " + $computerMotherboard.Product+";" + " "  +  "CPU: " + $computerCPU.Name+";"  + " " + "RAM: " + $RAM.ToString().Split(',')[0].Trim()+"GB;"  >> C:\Users\$env:USERNAME\Desktop\$env:USERNAME.txt 
Get-PhysicalDisk | Select @{L='HDD: ';E={"{0:N2}GB" -f ($_.Size/1GB)}}                             >> C:\Users\$env:USERNAME\Desktop\$env:USERNAME.txt


