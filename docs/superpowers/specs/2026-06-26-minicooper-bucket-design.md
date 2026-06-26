# minicooper - 个人 Scoop Bucket 设计规范

**日期**: 2026-06-26
**状态**: 待用户审阅
**作者**: 由 brainstorming 流程生成

---

## 1. 目标与背景

将本地空仓库 `ChenXinBest/minicooper` 初始化为个人 [Scoop](https://scoop.sh) bucket，用于通过 Windows 命令行安装下列 3 个软件（其中 opencode 拆分为两个 manifest）：

| Manifest | 软件 | 用途 |
|---|---|---|
| `netcatty` | binaricat/Netcatty | AI 驱动的终端 + SSH 客户端（Electron） |
| `opencode` | anomalyco/opencode (CLI) | AI 编程代理命令行工具 |
| `opencode-desktop` | anomalyco/opencode (Desktop) | AI 编程代理桌面应用（Electron） |
| `open-code-review` | alibaba/open-code-review | 阿里巴巴 AI 代码审查 CLI |

**核心约束**：
- 参考 [ScoopInstaller/Extras](https://github.com/ScoopInstaller/Extras) 的清单规范与质量标准
- 支持 GitHub Actions 自动检查上游版本并提交 PR
- 每个 manifest 同时支持 x64 和 ARM64 架构
- 仓库根目录布局采用 [ScoopInstaller/BucketTemplate](https://github.com/ScoopInstaller/BucketTemplate) 的精简版

---

## 2. 范围与非目标

### 2.1 在范围内

- 仓库初始化（添加 `.gitignore`、`.editorconfig`、`.gitattributes`、`LICENSE`、`README.md`）
- 4 个 manifest JSON 文件（含 hash、checkver、autoupdate 字段）
- `.github/workflows/ci.yml`（Pester 静态校验）
- `.github/workflows/excavator.yml`（每 4 小时自动检查新版本）
- `bin/test.ps1`（Pester 入口）
- `bin/auto-pr.ps1`（Excavator 包装脚本）
- `Scoop-Bucket.Tests.ps1`（Pester 测试套件）
- `deprecated/` 占位目录
- 在 GitHub 仓库设置中说明 secrets（`GH_PAT`）和 Actions 权限要求

### 2.2 不在范围内

- 编写超出 BucketTemplate 标准能力的自定义 PowerShell 工具
- 维护 BucketTemplate 仓库本身（issue handlers、checkurls.ps1 等被精简删除）
- 集成第三方 bucket（如官方 extras、versions）的 manifest
- 包含非 Windows 平台（macOS、Linux）的 Scoop 安装支持（Scoop 是 Windows-only）
- 在 macOS/Linux 上执行任何 PowerShell 测试（windows-latest runner 限制）

---

## 3. 仓库结构

```
ChenXinBest/minicooper/
├── .github/
│   └── workflows/
│       ├── ci.yml               # PR + push + workflow_dispatch 触发 Pester
│       └── excavator.yml        # cron 每 4h + workflow_dispatch 触发自动更新
├── bin/
│   ├── test.ps1                 # Pester 入口（基于 BucketTemplate 精简）
│   └── auto-pr.ps1              # Excavator 包装脚本
├── bucket/
│   ├── netcatty.json
│   ├── opencode.json            # CLI 版本（默认）
│   ├── opencode-desktop.json    # Desktop 应用
│   └── open-code-review.json
├── deprecated/                  # 占位目录，用于未来弃用 manifest
├── .editorconfig
├── .gitattributes               # JSON 强制 LF
├── .gitignore
├── LICENSE                      # Unlicense（继承 BucketTemplate）
├── README.md                    # bucket 介绍与安装命令
└── Scoop-Bucket.Tests.ps1       # Pester 测试套件
```

**与 BucketTemplate 的差异**：
- 删除 `.vscode/`、`scripts/`、`checkurls.ps1`、`bucket/*.json.template`、`.markdownlint.json`
- 不使用 BucketTemplate 的 `my_bucket/` 路径别名，所有路径基于 `bucket/`
- `bin/test.ps1` 直接指向 `$PSScriptRoot/..`，依赖 SCOOP_HOME 环境变量

---

## 4. Manifest 详细设计

### 4.1 通用字段规范

所有 manifest 共享以下规范：

```json
{
  "version": "x.y.z",           // 不含 'v' 前缀
  "description": "...",         // 单行简介
  "homepage": "https://github.com/<owner>/<repo>",
  "license": "<SPDX-id>",       // 如 "MIT"、"GPL-3.0"、"Apache-2.0"
  "architecture": {
    "64bit": {
      "url": "...",
      "hash": "sha256:...",
      "bin": "...",
      "shortcuts": [...]
    },
    "arm64": {
      "url": "...",
      "hash": "sha256:...",
      "bin": "...",
      "shortcuts": [...]
    }
  },
  "checkver": {
    "url": "https://api.github.com/repos/<owner>/<repo>/releases/latest",
    "jsonpath": "$.tag_name",
    "regex": "v([\\d.]+)"
  },
  "autoupdate": {
    "architecture": {
      "64bit": {
        "url": "https://github.com/<owner>/<repo>/releases/download/v$version/...win-x64.exe"
      },
      "arm64": {
        "url": "https://github.com/<owner>/<repo>/releases/download/v$version/...win-arm64.exe"
      }
    }
  }
}
```

### 4.2 `bucket/netcatty.json`

| 字段 | 值 |
|---|---|
| version | `1.1.45` |
| description | AI-powered terminal and SSH client with built-in agent support |
| homepage | `https://github.com/binaricat/Netcatty` |
| license | `GPL-3.0` |
| x64 url | `https://github.com/binaricat/Netcatty/releases/download/v1.1.45/Netcatty-1.1.45-win-x64.exe` |
| arm64 url | `https://github.com/binaricat/Netcatty/releases/download/v1.1.45/Netcatty-1.1.45-win-arm64.exe` |
| installer | NSIS（electron-builder，Scoop 默认静默安装） |
| bin | `Netcatty.exe` |
| shortcuts | `["Netcatty", "Netcatty.lnk"]` |
| hash 源 | `latest.yml`（electron-builder 发布） |

### 4.3 `bucket/opencode.json`（CLI，默认）

| 字段 | 值 |
|---|---|
| version | `1.17.11` |
| description | AI coding agent (CLI) |
| homepage | `https://github.com/anomalyco/opencode` |
| license | `MIT` |
| x64 url | `https://github.com/anomalyco/opencode/releases/download/v1.17.11/opencode-windows-x64.zip` |
| arm64 url | `https://github.com/anomalyco/opencode/releases/download/v1.17.11/opencode-windows-arm64.zip` |
| format | zip |
| bin | `opencode.exe` |
| persist | `~/.opencode` |

### 4.4 `bucket/opencode-desktop.json`

| 字段 | 值 |
|---|---|
| version | `1.17.11` |
| description | AI coding agent (Desktop app) |
| homepage | `https://github.com/anomalyco/opencode` |
| license | `MIT` |
| x64 url | `https://github.com/anomalyco/opencode/releases/download/v1.17.11/opencode-desktop-win-x64.exe` |
| arm64 url | `https://github.com/anomalyco/opencode/releases/download/v1.17.11/opencode-desktop-win-arm64.exe` |
| installer | NSIS（electron-builder） |
| bin | `opencode.exe` |
| shortcuts | `["opencode", "opencode.lnk"]` |

### 4.5 `bucket/open-code-review.json`

| 字段 | 值 |
|---|---|
| version | `1.6.1` |
| description | AI-powered code review CLI by Alibaba |
| homepage | `https://github.com/alibaba/open-code-review` |
| license | `Apache-2.0` |
| x64 url | `https://github.com/alibaba/open-code-review/releases/download/v1.6.1/opencodereview-windows-amd64.exe` |
| arm64 url | `https://github.com/alibaba/open-code-review/releases/download/v1.6.1/opencodereview-windows-arm64.exe` |
| 性质 | 裸 .exe 二进制（非安装器），下载后改名放入 `bin/` |
| bin | `opencodereview.exe` |
| persist | `~/.opencodereview` |
| hash 源 | 上游 `sha256sum.txt`（直接解析） |

### 4.6 关键设计决策

1. **NSIS 自动安装器**（netcatty、opencode-desktop）：`installer.script` 留空，使用 Scoop 默认 NSIS 静默安装参数 `/S`。
2. **zip 提取**（opencode）：声明 `"format": "zip"`，Scoop 自动调用内置 `7zip` 解压。
3. **裸 exe**（open-code-review）：直接重命名为 `opencodereview.exe` 放到 `bin/` 目录，Scoop 自动添加 PATH。
4. **无外部依赖**：所有 manifest 不依赖其他 package。
5. **persist 目录**：CLI 类工具持久化用户配置目录，卸载时保留。
6. **checkver/autoupdate**：每个 manifest 必须包含完整字段，供 Excavator 准确识别新版与生成新 manifest。
7. **架构映射**：上游 tag 中的 `x64` 对应 Scoop 的 `64bit`；`arm64` 对应 `arm64`。
8. **命名决策**：用户明确要求 `opencode.json` 表示 CLI（命令行的"默认"形态），Desktop 单独使用 `opencode-desktop.json`。

---

## 5. GitHub Actions 工作流

### 5.1 `.github/workflows/ci.yml`

```yaml
name: CI
on:
  pull_request:
  push:
    branches: [master]
  workflow_dispatch:

permissions:
  contents: read
  pull-requests: read

jobs:
  test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 2
      - uses: actions/checkout@v4
        with:
          repository: ScoopInstaller/Scoop
          path: scoop_core
      - uses: potatoqualitee/psmodulecache@v1
        with:
          modules-to-cache: BuildHelpers, Pester
      - name: Run tests
        run: .\bin\test.ps1
```

**作用**：每次 PR 改动触发，自动跑 Pester 检查 manifest 格式、URL 可达性、hash 正确性。
（`SCOOP_HOME` 在 `bin/test.ps1` 内部基于 `scoop_core` 相对路径自动设置。）

### 5.2 `.github/workflows/excavator.yml`

```yaml
name: Excavator
on:
  schedule:
    - cron: '0 */4 * * *'
  workflow_dispatch:

permissions:
  contents: read
  pull-requests: read

jobs:
  auto-update:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.GH_PAT }}
      - uses: actions/checkout@v4
        with:
          repository: ScoopInstaller/Scoop
          path: scoop_core
      - uses: actions/checkout@v4
        with:
          repository: ScoopInstaller/Excavator
          path: excavator
      - uses: potatoqualitee/psmodulecache@v1
        with:
          modules-to-cache: BuildHelpers, Pester
      - name: Run Excavator
        run: .\bin\auto-pr.ps1 -Push
        env:
          GH_TOKEN: ${{ secrets.GH_PAT }}
          SCOOP_BUCKET_REPO: ChenXinBest/minicooper
```

**作用**：每 4 小时调用 `auto-pr.ps1` 扫描所有 manifest 的上游版本号；发现新版后自动开 PR。

### 5.3 `bin/auto-pr.ps1`

精简自 BucketTemplate，核心逻辑：
- 调用 `Excavator\Invoke-BucketUpdate` 遍历每个 manifest
- 用 `checkver` 字段获取上游最新版
- 对比当前 manifest 的 `version` 字段
- 如果有新版：生成新的 manifest 内容（含新 url、hash），提交到分支 `auto/<app>-<newver>`
- 用 PAT 创建 PR，标题格式 `[<app>] Update to <newver>`

**精简部分**：删除 BucketTemplate 中的 PR template（README 引导）、merge conflict 自动重试逻辑、多个 -WhatIf 分支。

### 5.4 `bin/test.ps1`

```powershell
#Requires -Version 5.1

$env:SCOOP_HOME = "$(Convert-Path '.\scoop_core')"

$pesterConfig = New-PesterConfiguration -Hashtable @{
    Run    = @{ Path = "$PSScriptRoot/.."; PassThru = $true }
    Output = @{ Verbosity = 'Detailed' }
}
$result = Invoke-Pester -Configuration $pesterConfig
exit $result.FailedCount
```

> 注：`#Requires -Modules` 精确版本已被移除。`potatoqualitee/psmodulecache@v1` 默认安装最新版本的 BuildHelpers / Pester，精确版本约束（如 `ModuleVersion = '2.0.1'`）会因模块版本漂移导致脚本启动失败。BucketTemplate 的精简变体不依赖精确版本契约。

---

## 6. 必需的 GitHub 仓库配置

### 6.1 Secrets

在 `Settings → Secrets and variables → Actions → New repository secret` 添加：

| Name | Value | 用途 |
|---|---|---|
| `GH_PAT` | GitHub Personal Access Token（`repo` scope） | Excavator 创建 PR |

**PAT 创建步骤**：
1. https://github.com/settings/tokens/new?type=beta
2. Repository access：仅 `ChenXinBest/minicooper`
3. Permissions：Repository permissions → Contents: Read and write, Pull requests: Read and write
4. 复制 token（仅显示一次）

### 6.2 Actions 权限

- `Settings → Actions → General → Actions permissions` → 选 **Allow all actions and reusable workflows**
- `Settings → Actions → General → Workflow permissions` → 选 **Read and write permissions**

### 6.3 （可选）分支保护

- `Settings → Branches → Add rule`
- Branch name pattern: `master`
- ✅ Require a pull request before merging
- ✅ Require status checks to pass before merging → 选 `test`

---

## 7. 测试与验证

### 7.1 单元与集成测试

| 测试层 | 工具 | 检查内容 |
|---|---|---|
| 静态测试 | `Scoop-Bucket.Tests.ps1`（Pester 5） | JSON 格式、必填字段、架构覆盖、SPDX 许可、hash 匹配、URL 200 OK |
| 端到端 | `bin/test.ps1` | 触发所有 manifest 的本地 `scoop install` 流程（windows-latest runner） |
| 自动更新 | Excavator 手动触发 | workflow_dispatch 启动一次 `auto-pr.ps1`，模拟 4 小时一次的扫描 |

### 7.2 验收标准（每个 manifest 必须满足）

- [ ] JSON 合法，可被 Scoop 解析
- [ ] `version` 与上游 GitHub Release 一致（去掉 `v`）
- [ ] `homepage`、`license`（SPDX 标识符）、`description` 完整
- [ ] `architecture` 块同时包含 `64bit` 和 `arm64`
- [ ] 每个架构的 `url` 可达（HTTP 200）
- [ ] 每个架构的 `hash`（sha256）与下载文件一致
- [ ] `checkver` 字段能正确返回上游最新版
- [ ] `autoupdate` 字段能正确生成新 manifest
- [ ] 本地 `scoop install <bucket>/<app>` 在 Windows 上成功
- [ ] 安装后可执行文件路径加入 PATH
- [ ] `scoop uninstall <app>` 干净卸载

### 7.3 部署流程

```powershell
# 1. 本地验证（如已装 Pester）
.\bin\test.ps1

# 2. 推送
git add . ; git commit -m "feat: initial bucket with 4 manifests"
git push origin master

# 3. GitHub 配置
#    - Settings → Secrets → 添加 GH_PAT
#    - Settings → Actions → 启用 Allow all + Read/write permissions

# 4. 验证 CI
#    - 任意小 PR 触发 ci.yml，确认 Pester 通过

# 5. 验证 Excavator
#    - Actions → Excavator → Run workflow
#    - 确认日志无报错

# 6. 端到端验证（可选）
scoop bucket add minicooper https://github.com/ChenXinBest/minicooper
scoop install minicooper/netcatty
scoop install minicooper/opencode
scoop install minicooper/opencode-desktop
scoop install minicooper/open-code-review
```

### 7.4 错误处理

| 失败场景 | 处理 |
|---|---|
| 上游 Release 资产命名变更 | Excavator 报 404；手动更新 manifest 中的 `url` 模板 |
| Excavator 自身故障 | workflow 日志可见，邮件告警；可手动触发重试 |
| PAT 过期/失效 | Excavator PR 创建失败；更新 PAT 后手动重跑 workflow |
| hash 不匹配 | CI 失败；上游某资产被替换或回滚，重新下载并核对 |
| windows-latest runner 资源不足 | GitHub Actions 自动重试 3 次；持续失败考虑启用缓存 |

---

## 8. README 内容（最小集）

```markdown
# minicooper - Personal Scoop Bucket

收录以下软件：

| App | 用途 |
|---|---|
| netcatty | AI 驱动的终端 + SSH 客户端 |
| opencode | AI 编程代理（CLI） |
| opencode-desktop | AI 编程代理（桌面应用） |
| open-code-review | 阿里巴巴 AI 代码审查 CLI |

## 安装

    scoop bucket add minicooper https://github.com/ChenXinBest/minicooper
    scoop install minicooper/netcatty
    scoop install minicooper/opencode
    scoop install minicooper/opencode-desktop
    scoop install minicooper/open-code-review

## 自动更新

通过 GitHub Actions + [Excavator](https://github.com/ScoopInstaller/Excavator) 每 4 小时检查上游版本，
有新版本会自动开 PR。详见 `.github/workflows/excavator.yml`。

## 架构

所有 manifest 同时支持 x64 和 ARM64。
```

---

## 9. 风险与限制

| 风险 | 影响 | 缓解 |
|---|---|---|
| Excavator 仍处 v0 beta | 偶发误判（如纯补丁版本被识别为新版） | 误判产生的 PR 可一键关闭 |
| 上游 electron-builder 资产命名变更 | 自动更新失效 | checkver 失败会触发 CI 报错 |
| windows-latest runner 价格变动 | 月度分钟数成本 | 4 小时一次的 cron 可接受（约 15 次/天） |
| GitHub Actions 政策变更 | workflow 暂停 | 关注 GitHub 公告；本地保留 Pester 备份 |

---

## 10. 验收（项目交付前必须通过）

1. **本地验证**：
   - 4 个 manifest 通过 Pester 检查（`bin/test.ps1`）
   - 4 个 manifest 的所有架构 URL 返回 200
   - 4 个 manifest 的 hash 与最新 release 匹配

2. **CI 验证**：
   - 推送到 master 触发 ci.yml，全绿
   - 手动触发 excavator.yml，模拟一次更新流程（即使没更新也无报错）

3. **端到端验证**（可选但推荐）：
   - 在 Windows 机器上 `scoop bucket add minicooper ...`
   - `scoop install <bucket>/<app>` 成功
   - 运行命令验证可执行
   - `scoop uninstall <app>` 干净卸载

---

## 附录 A：上游资源链接

- [ScoopInstaller/Extras](https://github.com/ScoopInstaller/Extras) — 参考规范
- [ScoopInstaller/BucketTemplate](https://github.com/ScoopInstaller/BucketTemplate) — 模板来源
- [ScoopInstaller/Excavator](https://github.com/ScoopInstaller/Excavator) — 自动更新工具
- [ScoopInstaller/Scoop](https://github.com/ScoopInstaller/Scoop) — Scoop 主仓库
- [Scoop Wiki - Buckets](https://github.com/ScoopInstaller/Scoop/wiki/Buckets) — bucket 文档
- [Scoop Wiki - App Manifests](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests) — manifest 字段说明
- [Scoop Wiki - App Manifest Autoupdate](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifest-Autoupdate) — autoupdate 字段说明

## 附录 B：上游应用链接

- [binaricat/Netcatty](https://github.com/binaricat/Netcatty) — v1.1.45 (GPL-3.0)
- [anomalyco/opencode](https://github.com/anomalyco/opencode) — v1.17.11 (MIT)
- [alibaba/open-code-review](https://github.com/alibaba/open-code-review) — v1.6.1 (Apache-2.0)