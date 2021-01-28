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
