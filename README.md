# 锐捷校园网自动重连工具

一个基于 PowerShell 的锐捷校园网自动登录脚本，专为华侨大学（HAFU）校园网设计，可自动检测网络连通性并在断线时自动重新登录。

## 📋 功能特性

- 🔄 **自动重连**：持续监测网络连通性，断线时自动触发登录
- ⏱️ **实时监控**：可配置检测间隔，默认每 3 秒检测一次
- 📝 **日志记录**：详细的时间戳日志，方便追踪网络状态
- 🛠️ **易于配置**：简单的配置参数，修改用户名密码即可使用
- 💻 **双模式支持**：提供基础版和监控增强版两种运行模式

## 📂 项目文件说明

### `autoRelogin.ps1` - 核心自动登录脚本
主要功能脚本，包含完整的网络检测和自动登录逻辑：
- 定期 Ping 测试网络连通性
- 检测到断网时自动调用锐捷登录接口
- 输出带时间戳的运行日志

### `ping-monitor.ps1` - 网络监控辅助脚本
一个轻量级的网络监控脚本：
- 持续监测指定 IP 的可达性
- 检测到网络不可达时自动执行指定脚本（如 `autoRelogin.ps1`）
- 记录详细日志到本地文件

## 🚀 快速开始

### 前置要求

- Windows 操作系统（支持 Windows 7 及以上版本）
- PowerShell 3.0 或更高版本
- 校园网账号

### 安装步骤

1. **克隆或下载项目**
   ```powershell
   git clone https://github.com/ChuChenlyc/Ruijie_HAFU_Autorelogin.git
   cd Ruijie_HAFU_Autorelogin
   ```

2. **配置登录信息**
   
   打开 `autoRelogin.ps1`，修改用户配置区的参数：
   ```powershell
   # ======== 用户配置区 ========
   $pingTarget = "223.5.5.5"   # 阿里公共DNS（可保持默认）
   $loginUrl = "http://172.23.0.2/eportal/InterFace.do?method=login"  # 登录接口（校内网地址）
   $username = "你的学号"        # 修改为你的学号
   $password = "你的密码"        # 修改为你的校园网密码
   $checkInterval = 3            # 检测间隔（秒）
   # ===========================
   ```

3. **运行脚本**

   **方式一：直接运行（推荐）**
   ```powershell
   .\autoRelogin.ps1
   ```

   **方式二：使用监控模式**
   
   先修改 `ping-monitor.ps1` 中的路径配置，将 `C:\1.ps1` 改为 `autoRelogin.ps1` 的完整路径，然后运行：
   ```powershell
   .\ping-monitor.ps1
   ```

## 📖 使用说明

### 基础使用模式

直接运行 `autoRelogin.ps1`，脚本会：
1. 每隔设定的时间间隔（默认 3 秒）检测网络连通性
2. 如果 Ping 目标地址（默认阿里 DNS）失败，则判定为断网
3. 自动向锐捷登录接口发送 POST 请求进行重新登录
4. 输出详细的运行日志，包括网络状态和登录结果

### 监控增强模式

使用 `ping-monitor.ps1` 作为监控守护进程：
1. 持续监控网络状态
2. 检测到断网时立即调用登录脚本
3. 将运行日志保存到文件（默认 `C:\ping-monitor.log`）

### 日志输出示例

```
2025-11-20 10:30:15Z - Script started. Ping target: 223.5.5.5 ; Login URL: http://172.23.0.2/eportal/InterFace.do?method=login
2025-11-20 10:30:15Z - Network OK.
2025-11-20 10:30:18Z - Network OK.
2025-11-20 10:30:21Z - Network unreachable. Attempting to re-login...
2025-11-20 10:30:22Z - Re-login request sent. Status: 200
2025-11-20 10:30:22Z - Re-login success.
2025-11-20 10:30:25Z - Network OK.
```

## ⚙️ 配置参数说明

### autoRelogin.ps1 配置项

| 参数 | 说明 | 默认值 | 备注 |
|------|------|--------|------|
| `$pingTarget` | Ping 测试目标地址 | `223.5.5.5` | 阿里公共 DNS，也可改为其他可靠的公网地址 |
| `$loginUrl` | 锐捷登录接口地址 | `http://172.23.0.2/eportal/InterFace.do?method=login` | 校内网地址，一般不需修改 |
| `$username` | 校园网账号（学号） | `学号` | **必须修改** |
| `$password` | 校园网密码 | `校园网密码` | **必须修改** |
| `$checkInterval` | 网络检测间隔（秒） | `3` | 可根据需要调整，建议 1-10 秒 |

### ping-monitor.ps1 配置项

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `$ips` | 监控的 IP 地址列表 | `@('223.5.5.5')` |
| `$intervalSeconds` | 检测间隔（秒） | `1` |
| `$logFile` | 日志文件路径 | `C:\ping-monitor.log` |

## 🔧 高级用法

### 开机自动启动

1. 按 `Win + R` 打开运行对话框
2. 输入 `shell:startup` 打开启动文件夹
3. 创建脚本的快捷方式并放入该文件夹

或者使用任务计划程序设置更高级的启动选项。

### 后台运行

使用隐藏窗口模式运行：
```powershell
Start-Process powershell -ArgumentList "-WindowStyle Hidden -File .\autoRelogin.ps1"
```

### 自定义 Ping 目标

如果校园网环境特殊，可以修改 `$pingTarget` 为：
- 百度 DNS: `180.76.76.76`
- Google DNS: `8.8.8.8`（如果可访问）
- 校外任意稳定的公网 IP

## ⚠️ 注意事项

1. **账号安全**：脚本中包含明文密码，请妥善保管文件，不要上传到公共代码仓库
2. **网络环境**：脚本需要在校园网环境下运行，登录接口 `172.23.0.2` 是内网地址
3. **执行策略**：首次运行可能需要修改 PowerShell 执行策略：
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
4. **防火墙**：确保防火墙不会阻止 PowerShell 的网络请求
5. **登录接口**：如果学校更新了认证系统，可能需要调整 `$loginUrl` 和请求参数

## 🛠️ 故障排查

### 问题：脚本无法运行
- **解决方法**：检查 PowerShell 执行策略，使用管理员权限运行：
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
  ```

### 问题：登录失败
- 检查用户名和密码是否正确
- 确认登录 URL 是否正确（可在浏览器中手动测试认证页面）
- 查看脚本输出的错误信息

### 问题：一直显示网络不可达
- 检查 `$pingTarget` 地址是否可访问
- 尝试更换其他 Ping 目标地址
- 确认本机网络配置正常

### 问题：提示认证成功但无法上网
- 可能是登录接口返回格式变化，检查 `$response.Content` 的实际内容
- 尝试在浏览器中手动登录一次，观察认证流程

## 📄 许可证

本项目采用 MIT 许可证，详见 [LICENSE](LICENSE) 文件。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

如果这个项目对你有帮助，请给个 ⭐ Star 支持一下！

## 👨‍💻 作者

- GitHub: [@ChuChenlyc](https://github.com/ChuChenlyc)

## 📮 反馈与支持

如有问题或建议，请通过以下方式联系：
- 提交 [GitHub Issue](https://github.com/ChuChenlyc/Ruijie_HAFU_Autorelogin/issues)
- 发起 [Pull Request](https://github.com/ChuChenlyc/Ruijie_HAFU_Autorelogin/pulls)

---

**声明**：本项目仅供学习交流使用，请遵守学校网络使用规定。