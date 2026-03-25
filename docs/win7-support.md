# Windows 7 support (win7-support branch)

> 说明：本分支目标是**尽可能让应用在 Windows 7 上可启动/可用**。
>
> 关键点：Tauri Windows 端使用 WebView2。Win7 环境下更建议使用 **Fixed WebView2 Runtime**（随安装包/便携版一起分发），避免用户系统缺失/无法安装 WebView2 Runtime。

## 构建 Win7/老系统推荐包（Fixed WebView2 Runtime）

### 方式 A：在 Windows 上执行准备脚本（推荐）

在仓库根目录执行（PowerShell）：

```powershell
# x64
powershell -ExecutionPolicy Bypass -File .\scripts\windows\prepare-fixed-webview2.ps1 -Arch x64

# x86
powershell -ExecutionPolicy Bypass -File .\scripts\windows\prepare-fixed-webview2.ps1 -Arch x86

# arm64
powershell -ExecutionPolicy Bypass -File .\scripts\windows\prepare-fixed-webview2.ps1 -Arch arm64
```

脚本会：
1) 下载 WebView2 FixedVersionRuntime CAB
2) 解压到 `src-tauri/`
3) 将 `src-tauri/tauri.windows.conf.json` 替换为对应的 `src-tauri/webview2.<arch>.json`

然后照常构建：

```powershell
pnpm i
pnpm run prebuild x86_64-pc-windows-msvc
pnpm tauri build --target x86_64-pc-windows-msvc
```

### 方式 B：参考 CI（GitHub Actions）

本仓库的 `release.yml / autobuild.yml / alpha.yml` 已包含相同逻辑（下载 CAB + 替换 config）。

## 已知限制 / 风险

- “Tauri 支持 Windows 7 and above” 是框架层面声明；具体项目依赖（插件、WebView2 版本、windows-rs API）仍可能导致 Win7 上运行失败。
- 需要在真实 Win7 环境中验证：能否启动、WebView2 是否可正常加载、托盘/通知/自启等功能是否工作。

