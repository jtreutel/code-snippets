#-------------------------------------------
# Continuous Port Checking Script
#-------------------------------------------

$wait_time_in_ms  = "5000"
$path_to_log_file = "C:\Windows\Temp\portcheck.log"
$port_to_test     = "443"
$server_address   = "203.0.113.123"

while(1)
{
    $status = Test-NetConnection $server_address -Port $port_to_test | Select-Object -ExpandProperty TCPTestSucceeded
    
	function Get-TimeStamp {
        return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
    }

    Write-Output "$(Get-TimeStamp) Connection to port $port_to_test status: $status" | Out-file $path_to_log_file -append
    Start-Sleep -milliseconds $wait_time_in_ms
}

#-------------------------------------------
# Install Various Programs
#-------------------------------------------

#NOTE: On some versions of Windows Server you may need to force TLS1.2 to get some of these to work:
#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Notepad++
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest "http://download.notepad-plus-plus.org/repository/7.x/7.8.9/npp.7.8.9.Installer.exe" -Outfile "$env:TEMP\npp.exe"; & "$env:TEMP\npp.exe" /S

#Putty
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest "https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.73-installer.msi" -OutFile C:/Windows/Temp/putty.msi; C:/Windows/Temp/putty.msi /q

#Chrome
$LocalTempDir = $env:TEMP; $ChromeInstaller = "ChromeInstaller.exe"; (new-object    System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', "$LocalTempDir\$ChromeInstaller"); & "$LocalTempDir\$ChromeInstaller" /silent /install; $Process2Monitor =  "ChromeInstaller"; Do { $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name; If ($ProcessesFound) { "Still running: $($ProcessesFound -join ', ')" | Write-Host; Start-Sleep -Seconds 2 } else { rm "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose } } Until (!$ProcessesFound)




#-------------------------------------------
# Create Some Local Admin Test Accts on a Nonprod Server
#-------------------------------------------

$Password = ConvertTo-SecureString -String "SomeRandomPassword123!@#" -AsPlainText -Force
New-LocalUser "foo.bar" -Password $Password
New-LocalUser "bar.baz" -Password $Password
New-LocalUser "baz.bat" -Password $Password
Add-LocalGroupMember -Group "Administrators" -Member "foo.bar", "bar.baz", "baz.bat"



#-------------------------------------------
# Get All Product IDs for Installed Applications
#-------------------------------------------

get-wmiobject Win32_Product | Format-Table IdentifyingNumber, Name, LocalPackage -AutoSize


#-------------------------------------------
# tail -f, Powershell style
#-------------------------------------------

Get-Content -Path 'path_to_file' -Tail 10 -Wait


#-------------------------------------------
# Open IIS10 Mgmt Console
#-------------------------------------------

%SystemRoot%\System32\Inetsrv\Inetmgr.exe

#-------------------------------------------
# Install ADUC on a Server
#-------------------------------------------

Install-WindowsFeature RSAT-ADDS
