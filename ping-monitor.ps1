<#
ping-monitor.ps1
---------------------------------
用途:
    简单的 ping 监控脚本。定期 ping 一组目标 IP，若全部不可达则触发本地脚本（示例中为 C:\1.ps1）。

快速说明:
    - 修改 $ips、$intervalSeconds、$logFile 以匹配你的环境。
    - 当检测到不可达时，脚本会尝试运行 `C:\1.ps1`（可替换为任何本地处理脚本）。

安全与注意事项:
    - 请勿在脚本中硬编码敏感信息。
    - 确保被调用的脚本（如 C:\1.ps1）来自可信来源并且有合适的权限。

示例运行:
    PowerShell -NoProfile -ExecutionPolicy Bypass -File .\ping-monitor.ps1
#>

# C:\ping-monitor.ps1
$ips = @('223.5.5.5')
$intervalSeconds = 1
$logFile = 'C:\ping-monitor.log'

$failCount = 0
$down = $false

function Log {
    param([string]$msg)
    $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $line = "$ts  $msg"
    Write-Output $line
    try { Add-Content -Path $logFile -Value $line } catch {}
}

Log "Ping monitor started (instant trigger mode). Targets: $($ips -join ', ')"

while ($true) {
    $reachable = $false
    foreach ($ip in $ips) {
        if (Test-Connection -ComputerName $ip -Count 1 -Quiet -ErrorAction SilentlyContinue) {
            $reachable = $true
            $lastGood = $ip
            break
        }
    }

    if ($reachable) {
        Log "OK: Reachable $lastGood"
    } else {
        Log "Network unreachable, running C:\1.ps1"
        try {
            & 'C:\1.ps1'
            Log "Executed C:\1.ps1 successfully."
        } catch {
            Log "Error running C:\1.ps1: $_"
        }
    }

    Start-Sleep -Seconds $intervalSeconds
}