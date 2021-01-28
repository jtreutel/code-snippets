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