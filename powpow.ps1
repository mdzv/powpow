# A program that displays the parts of your computer

function Get-SystemHardware {
    Write-Host "`n`nPowPow`n" 

    # Network
    $hostname = $env:COMPUTERNAME
    $ip = (Test-Connection -ComputerName $hostname -Count 1).IPv4Address.IPAddressToString
    Write-Host "Network"
    Write-Host "Hostname: $hostname"
    Write-Host "IP Address: $ip`n"

    # OS
    $os = Get-CimInstance Win32_OperatingSystem
    Write-Host "OS"
    Write-Host "Name: $($os.Caption)"
    Write-Host "Version: $($os.Version)"
    if ([Environment]::Is64BitOperatingSystem) {
        $arch = "64-bit"
    } else {
        $arch = "32-bit"
    }
    Write-Host "Architecture: $arch`n"

    # CPU
    $cpu = Get-CimInstance Win32_Processor
    $cpuUsage = Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average
    Write-Host "CPU"
    Write-Host "Name: $($cpu.Name)"
    Write-Host "Cores: $($cpu.NumberOfCores)"
    Write-Host "Logical Processors: $($cpu.NumberOfLogicalProcessors)"
    Write-Host "Max Clock Speed: $($cpu.MaxClockSpeed) MHz"
    Write-Host "Current Usage: $cpuUsage %`n"

    # Motherboard
    $mb = Get-CimInstance Win32_BaseBoard
    Write-Host "Motherboard"
    Write-Host "Manufacturer: $($mb.Manufacturer)"
    Write-Host "Product: $($mb.Product)"
    Write-Host "Serial Number: $($mb.SerialNumber)`n"

    # RAM
    $ram = Get-CimInstance Win32_PhysicalMemory
    $osRam = Get-CimInstance Win32_OperatingSystem
    $freeRAM = [math]::Round($osRam.FreePhysicalMemory / 1MB,2)
    $totalRAM = 0
    Write-Host "RAM"
    foreach ($stick in $ram) {
        $sizeGB = [math]::Round($stick.Capacity / 1GB,2)
        $totalRAM += $sizeGB
        Write-Host "Slot: $($stick.DeviceLocator) | Capacity: $sizeGB GB | Speed: $($stick.Speed) MHz"
    }
    $usedRAM = [math]::Round($totalRAM - $freeRAM,2)
    $usedRAMPercent = [math]::Round(($usedRAM / $totalRAM) * 100,2)
    Write-Host "Total Installed RAM: $totalRAM GB | Used RAM: $usedRAM GB | Current Usage: $usedRAMPercent %`n"

    # GPU
    $gpus = Get-CimInstance Win32_VideoController
    Write-Host "GPU"
    if ($gpus.Count -eq 0) {
        Write-Host "No GPU found"
    } else {
        foreach ($gpu in $gpus) {
            Write-Host "Name: $($gpu.Name)"
            Write-Host "VRAM Total: $([math]::Round($gpu.AdapterRAM/1MB,2)) MB"
            Write-Host "Driver Version: $($gpu.DriverVersion)`n"
        }
    }

    # Storage
    $disks = Get-CimInstance Win32_DiskDrive
    Write-Host "Storage"
    foreach ($disk in $disks) {
        $sizeGB = [math]::Round($disk.Size/1GB,2)
        Write-Host "Model: $($disk.Model) | Size: $sizeGB GB | Interface: $($disk.InterfaceType)"
    }
    Write-Host ""

    # Disk Partitions
    $partitions = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
    Write-Host "Disk"
    foreach ($part in $partitions) {
        $total = [math]::Round($part.Size / 1GB,2)
        $free = [math]::Round($part.FreeSpace / 1GB,2)
        $used = [math]::Round($total - $free,2)
        $usagePercent = [math]::Round(($used/$total)*100,2)
        Write-Host "Drive: $($part.DeviceID) | Total: $total GB | Used: $used GB | Free: $free GB | Usage: $usagePercent %"
    }
    Write-Host ""

    # Display / Monitor
    $monitors = Get-CimInstance WmiMonitorBasicDisplayParams -Namespace root\wmi
    Write-Host "Display"
    foreach ($mon in $monitors) {
        Write-Host "Monitor: $($mon.InstanceName) | Max Horizontal: $($mon.MaxHorizontalImageSize) cm | Max Vertical: $($mon.MaxVerticalImageSize) cm"
    }
    Write-Host ""
}

# Run the tool
Get-SystemHardware
