<#
autoRelogin.ps1
---------------------------------
用途:
    自动检测网络连通性（通过 ping 指定目标），当检测到不可达时，向锐捷校园网的登录接口发送 POST 请求尝试自动登录。

快速说明:
    - 修改“用户配置区”内的参数以匹配你的环境（用户名/密码/登录接口/检测目标等）。
    - 适合在 Windows 环境下用 PowerShell 直接运行或作为计划任务/服务运行。

安全提示:
    - 脚本内包含明文密码示例。不要将真实密码提交到远程仓库。建议使用系统凭据管理或环境变量来存储敏感信息。

示例运行:
    PowerShell -NoProfile -ExecutionPolicy Bypass -File .\autoRelogin.ps1

注意: 本脚本只在检测到网络不可达时尝试登录，未实现更复杂的会话管理或重复登录限速。如果需要，请在发布前完善。
#>

# ======== 用户配置区 ========
$pingTarget = "223.5.5.5"   # 阿里公共DNS
$loginUrl = "http://172.23.0.2/eportal/InterFace.do?method=login"
$username = "学号"
$password = "校园网密码"
$checkInterval = 3         # 每次检测间隔（秒）
# ===========================

# 输出时间标签函数
function Timestamp { return (Get-Date).ToString("yyyy-MM-dd HH:mm:ssZ") }

Write-Output "$(Timestamp) - Script started. Ping target: $pingTarget ; Login URL: $loginUrl"

while ($true) {
    # 1. 检测网络连通性
    $ping = Test-Connection -ComputerName $pingTarget -Count 1 -Quiet -ErrorAction SilentlyContinue
    if (-not $ping) {
        Write-Output "$(Timestamp) - Network unreachable. Attempting to re-login..."

        try {
            # 2. 组装登录数据（根据锐捷接口格式）
            $body = @{
                userId = $username
                password = $password
                service = ""
                queryString = ""
                operatorPwd = ""
                operatorUserId = ""
                validcode = ""
                passwordEncrypt = "false"
            }

            # 3. 发送 POST 请求
            $response = Invoke-WebRequest -Uri $loginUrl -Method POST -Body $body -UseBasicParsing -ErrorAction Stop
            Write-Output "$(Timestamp) - Re-login request sent. Status: $($response.StatusCode)"

            # 4. 检查返回内容是否包含成功标志
            if ($response.Content -match "success|OK|login_ok|认证成功") {
                Write-Output "$(Timestamp) - Re-login success."
            }
            else {
                Write-Output "$(Timestamp) - Re-login may have failed. Response: $($response.Content.Substring(0, [Math]::Min(200, $response.Content.Length)))"
            }
        }
        catch {
            Write-Output "$(Timestamp) - Error during re-login: $($_.Exception.Message)"
        }
    }
    else {
        Write-Output "$(Timestamp) - Network OK."
    }

    Start-Sleep -Seconds $checkInterval
}
