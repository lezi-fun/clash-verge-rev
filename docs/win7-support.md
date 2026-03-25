# Windows 7 support (win7-support branch)

本分支目标：**尽可能让应用在 Windows 7 上可启动/可用**（不保证所有功能 100% 正常）。

背景：Tauri Windows 端依赖 WebView2。Win7 环境下经常因为系统无法安装/缺失 WebView2 Runtime 导致启动失败，因此本分支优先走 **Fixed WebView2 Runtime（随安装包/便携包一起带上）** 这条路线。

---

## 1) 构建推荐：Fixed WebView2 Runtime 版

### 1.1 在 Windows 本机构建（推荐）

1) 准备 fixed runtime（PowerShell）：

```powershell
# x64（默认版本 133.0.3065.92）
powershell -ExecutionPolicy Bypass -File .\scripts\windows\prepare-fixed-webview2.ps1 -Arch x64

# x86
powershell -ExecutionPolicy Bypass -File .\scripts\windows\prepare-fixed-webview2.ps1 -Arch x86

# arm64
powershell -ExecutionPolicy Bypass -File .\scripts\windows\prepare-fixed-webview2.ps1 -Arch arm64
```

> 如果 Win7 上启动失败，可以尝试**回退 WebView2 版本**（示例）：
>
> ```powershell
> powershell -ExecutionPolicy Bypass -File .\scripts\windows\prepare-fixed-webview2.ps1 -Arch x64 -Version "109.0.1518.78"
> ```
>
> （具体用哪个版本需要实机验证；思路是“越老越可能兼容 Win7”，但也可能带来安全/兼容性问题。）

2) 正常构建：

```powershell
pnpm i
pnpm run prebuild x86_64-pc-windows-msvc
pnpm tauri build --target x86_64-pc-windows-msvc
```

### 1.2 通过 GitHub Actions 构建（手动触发）

workflow：`.github/workflows/win7-build.yml`

- 手动触发并选择：
  - `arch`: x64 / x86 / arm64
  - `webview2_version`: 默认为 `133.0.3065.92`，可改成更老版本
- 构建完成会上传 artifacts（NSIS 安装包），并尝试生成 portable fixed_webview2 包。

---

## 2) Win7 机器上如何验证

建议按这个顺序：

1) **先验证“能启动”**：双击运行 `Clash Verge.exe` 是否出现窗口/托盘图标
2) 如果无界面：
   - 打开任务管理器看进程是否一闪而过
   - 先关闭杀软/加白名单（部分杀软会拦 WebView2 runtime 文件）
3) **确认 fixed runtime 是否随包存在**：
   - 便携版：目录内应包含 `Microsoft.WebView2.FixedVersionRuntime.<ver>.<arch>/` 文件夹
   - 安装版：安装目录应包含同名 runtime 文件夹

如果你能在 Win7 上复现失败，请把以下信息发我（越全越好）：
- Windows 版本（Win7 SP1? x64/x86?）
- 运行方式（安装版/便携版）
- 是否弹出错误框 / 错误码 / 截图
- `Clash Verge` 日志（如果有）

---

## 3) 已知限制 / 风险

- “Tauri 支持 Windows 7 and above” 是框架层面声明；但具体项目依赖（插件、WebView2 版本、windows-rs API）可能仍导致 Win7 上运行失败。
- fixed WebView2 runtime 体积较大；同时不同 WebView2 版本对 Win7 的兼容性差异需要通过实机验证。

