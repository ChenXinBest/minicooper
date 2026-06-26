# minicooper Scoop Bucket 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 `ChenXinBest/minicooper` 仓库初始化为个人 Scoop bucket，收录 4 个 manifest（netcatty / opencode CLI / opencode-desktop / open-code-review），支持 x64 + ARM64 双架构，并配置 GitHub Actions + Excavator 每 4 小时自动检查上游版本。

**Architecture:** 精简 BucketTemplate 骨架 + Excavator 自动更新。所有 manifest 使用 `architecture` 字段同时声明 `64bit` 和 `arm64`。CI 用 Pester 5 静态校验 manifest 格式与 hash。

**Tech Stack:**
- ScoopInstaller/Scoop（运行时 + Pester 测试框架）
- ScoopInstaller/BucketTemplate（参考模板，Unlicense）
- ScoopInstaller/Excavator（自动更新工具，v0 beta）
- Pester 5.2.0（manifest 静态校验）
- BuildHelpers 2.0.1（Pester 依赖）
- GitHub Actions windows-latest runner
- PowerShell 5.1

**Spec:** `docs/superpowers/specs/2026-06-26-minicooper-bucket-design.md`

---

## Global Constraints

- **仓库路径**：`ChenXinBest/minicooper`（已存在远程仓库，本地工作目录为 `C:\Users\cx646\Documents\Projects\minicooper`）
- **bucket 根目录**：仓库根的 `bucket/`，所有 manifest 在此直接放置
- **目标平台**：Windows only（x64 + ARM64）
- **许可证**：Unlicense 继承自 BucketTemplate（仅适用于 bucket 仓库自身的 LICENSE）
- **manifest 许可证字段**：使用 SPDX 标识符（`GPL-3.0` / `MIT` / `Apache-2.0`）
- **manifest hash 算法**：sha256（前缀 `sha256:`）
- **版本号约定**：manifest 的 `version` 不含 `v` 前缀（如 `"1.1.45"` 而非 `"v1.1.45"`）
- **架构字段**：上游 tag 的 `x64`/`amd64` → Scoop 的 `64bit`；上游的 `arm64` → Scoop 的 `arm64`
- **CI 平台**：windows-latest runner only
- **依赖外部**：`ChenXinBest/minicooper` 仓库、`GH_PAT` secret
- **Excavator cron**：`0 */4 * * *`（每 4 小时）
- **GitHub Actions permissions**：workflow 默认 `read`；写操作通过 `secrets.GH_PAT` token

---

## Task 1: 仓库骨架

**Files:**
- Create: `.gitignore`
- Create: `.editorconfig`
- Create: `.gitattributes`
- Create: `LICENSE`
- Create: `README.md`
- Create: `deprecated/.gitkeep`

**Interfaces:**
- Consumes: 无
- Produces: 仓库根级配置文件骨架

- [ ] **Step 1: 创建 `.gitignore`**

写入仓库根目录 `.gitignore`，内容：

```gitignore
# Build outputs
*.exe
*.zip
*.tar.gz
*.dmg
*.AppImage
*.deb
*.rpm
*.pacman
*.msi

# PowerShell
*.ps1.bak

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
desktop.ini

# Scoop cache
*.download
*.extract
```

- [ ] **Step 2: 创建 `.editorconfig`**

写入仓库根目录 `.editorconfig`，内容：

```ini
root = true

[*]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.{json,yml,yaml}]
indent_size = 2

[*.ps1]
indent_size = 4
```

- [ ] **Step 3: 创建 `.gitattributes`**

写入仓库根目录 `.gitattributes`，内容：

```gitattributes
* text=auto eol=lf

*.json text eol=lf
*.yml text eol=lf
*.yaml text eol=lf
*.md text eol=lf

*.exe binary
*.zip binary
*.gz binary
```

- [ ] **Step 4: 创建 `LICENSE`**

写入仓库根目录 `LICENSE`，内容（Unlicense，继承自 BucketTemplate）：

```
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <https://unlicense.org>
```

- [ ] **Step 5: 创建 `README.md`**

写入仓库根目录 `README.md`，内容：

````markdown
# minicooper - Personal Scoop Bucket

个人 [Scoop](https://scoop.sh) bucket，用于在 Windows 上快速安装下列软件。

## 收录列表

| App                | 用途                                          |
| ------------------ | --------------------------------------------- |
| `netcatty`         | AI 驱动的终端 + SSH 客户端                    |
| `opencode`         | AI 编程代理（CLI）                            |
| `opencode-desktop` | AI 编程代理（桌面应用）                       |
| `open-code-review` | 阿里巴巴 AI 代码审查 CLI                      |

## 安装

```powershell
scoop bucket add minicooper https://github.com/ChenXinBest/minicooper
scoop install minicooper/netcatty
scoop install minicooper/opencode
scoop install minicooper/opencode-desktop
scoop install minicooper/open-code-review
```

## 架构支持

所有 manifest 同时支持 `x64` 和 `arm64` 架构，Scoop 会自动选择匹配版本。

## 自动更新

通过 GitHub Actions + [Excavator](https://github.com/ScoopInstaller/Excavator) 每 4 小时检查上游版本，有新版本会自动开 PR。详见 `.github/workflows/excavator.yml`。

## 贡献

本仓库仅收录个人维护的 3 个软件（4 个 manifest）。如需添加其他软件，请 fork 后自行管理。
````

- [ ] **Step 6: 创建 `deprecated/` 占位目录**

```powershell
New-Item -ItemType Directory -Path "deprecated" -Force
New-Item -ItemType File -Path "deprecated\.gitkeep" -Force
```

- [ ] **Step 7: 提交**

```bash
git add .gitignore .editorconfig .gitattributes LICENSE README.md deprecated/
git commit -m "chore: initialize bucket scaffold"
```

---

## Task 2: Pester 测试套件 + bin/test.ps1

**Files:**
- Create: `Scoop-Bucket.Tests.ps1`
- Create: `bin/test.ps1`

**Interfaces:**
- Consumes: `bucket/*.json`（后续任务创建的 manifest）
- Produces: 
  - Pester 测试套件，针对 `bucket/` 目录运行
  - `bin/test.ps1` 是 Pester 入口，由 CI 调用

- [ ] **Step 1: 创建 `bin/` 目录**

```powershell
New-Item -ItemType Directory -Path "bin" -Force
```

- [ ] **Step 2: 创建 `bin/test.ps1`**

写入 `bin/test.ps1`，内容：

```powershell
#Requires -Version 5.1

$env:SCOOP_HOME = "$(Convert-Path '.\scoop_core')"

$pesterConfig = New-PesterConfiguration -Hashtable @{
    Run    = @{
        Path     = "$PSScriptRoot/.."
        PassThru = $true
    }
    Output = @{
        Verbosity = 'Detailed'
    }
}
$result = Invoke-Pester -Configuration $pesterConfig
exit $result.FailedCount
```

- [ ] **Step 3: 创建 `Scoop-Bucket.Tests.ps1`**

写入仓库根目录 `Scoop-Bucket.Tests.ps1`，内容（精简自 BucketTemplate，去掉了 deprecated 兼容性测试和 signature 检查，因为本仓库无历史包袱）：

```powershell
#Requires -Version 5.1

BeforeAll {
    $BucketName = 'minicooper'
    $BucketDir  = Join-Path $PSScriptRoot 'bucket'
    $Manifests  = Get-ChildItem -Path $BucketDir -Filter '*.json' -File
}

Describe 'Manifest JSON syntax' {
    It 'has at least one manifest' {
        $Manifests.Count | Should -BeGreaterThan 0
    }

    It 'all manifests parse as valid JSON' -TestCases @(@{ Name = 'manifest' }) -ForEach $Manifests {
        (Get-Content -Raw $Name.FullName) | ConvertFrom-Json -ErrorAction Stop | Out-Null
    }
}

Describe 'Manifest required fields' {
    BeforeAll {
        $RequiredTopLevel = @('version', 'description', 'homepage', 'license')
    }

    It '<_> has all required fields' -ForEach $Manifests {
        $json = Get-Content -Raw $_.FullName | ConvertFrom-Json
        foreach ($field in $RequiredTopLevel) {
            $json.PSObject.Properties.Name | Should -Contain $field -Because "manifest must declare $field"
        }
    }
}

Describe 'Manifest architecture coverage' {
    It '<_> declares both 64bit and arm64' -ForEach $Manifests {
        $json = Get-Content -Raw $_.FullName | ConvertFrom-Json
        $json.architecture.PSObject.Properties.Name | Should -Contain '64bit'
        $json.architecture.PSObject.Properties.Name | Should -Contain 'arm64'
    }

    It '<_> has url and hash for both architectures' -ForEach $Manifests {
        $json = Get-Content -Raw $_.FullName | ConvertFrom-Json
        foreach ($arch in @('64bit', 'arm64')) {
            $json.architecture.$arch.url  | Should -Not -BeNullOrEmpty
            $json.architecture.$arch.hash | Should -Not -BeNullOrEmpty
        }
    }
}

Describe 'License is SPDX identifier' {
    It '<_> uses SPDX license id' -ForEach $Manifests {
        $json = Get-Content -Raw $_.FullName | ConvertFrom-Json
        $json.license | Should -Match '^[A-Za-z0-9\-\.\+]+$'
    }
}

Describe 'checkver and autoupdate are present' {
    It '<_> has checkver field' -ForEach $Manifests {
        $json = Get-Content -Raw $_.FullName | ConvertFrom-Json
        $json.PSObject.Properties.Name | Should -Contain 'checkver'
    }

    It '<_> has autoupdate field' -ForEach $Manifests {
        $json = Get-Content -Raw $_.FullName | ConvertFrom-Json
        $json.PSObject.Properties.Name | Should -Contain 'autoupdate'
    }
}

Describe 'URLs are reachable' -Skip:(-not $env:RUN_URL_CHECK) {
    It '<_> <_.architecture.64bit.url> returns 200' -ForEach $Manifests {
        $url = (Get-Content -Raw $_.FullName | ConvertFrom-Json).architecture.'64bit'.url
        (Invoke-WebRequest -Uri $url -UseBasicParsing -Method Head -MaximumRedirection 5).StatusCode | Should -Be 200
    }

    It '<_> <_.architecture.arm64.url> returns 200' -ForEach $Manifests {
        $url = (Get-Content -Raw $_.FullName | ConvertFrom-Json).architecture.arm64.url
        (Invoke-WebRequest -Uri $url -UseBasicParsing -Method Head -MaximumRedirection 5).StatusCode | Should -Be 200
    }
}
```

- [ ] **Step 4: 提交**

```bash
git add bin/test.ps1 Scoop-Bucket.Tests.ps1
git commit -m "test: add Pester bucket test suite"
```

- [ ] **Step 5: 验证 Pester 套件能被发现（但因 bucket/ 为空所以至少 "has at least one manifest" 会失败，这一步是预期失败）**

```powershell
# 在 PowerShell 中执行（如已装 Pester 5）
.\bin\test.ps1
```

Expected: 失败，错误信息类似 `Expected 0 to be greater than 0`。这是预期，因为 `bucket/` 还没有 manifest。修复在后续任务。

---

## Task 3: bucket/netcatty.json

**Files:**
- Create: `bucket/netcatty.json`

**Interfaces:**
- Consumes: GitHub Release `v1.1.45` 资产（Netcatty-1.1.45-win-x64.exe, Netcatty-1.1.45-win-arm64.exe）
- Produces: 通过 Task 2 Pester 套件的所有检查

- [ ] **Step 1: 下载 x64 资产并计算 sha256**

```powershell
$url = "https://github.com/binaricat/Netcatty/releases/download/v1.1.45/Netcatty-1.1.45-win-x64.exe"
$tmp = "$env:TEMP\netcatty-x64.exe"
Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
$hash = (Get-FileHash -Path $tmp -Algorithm SHA256).Hash.ToLower()
"sha256:$hash"
```

Expected output: `sha256:66b91fb6c012d02a67bc4f50ca8661f6baeb444f025b162aa696e585258656fe`（注意：`Get-FileHash` 输出的是裸 hex，需要包成 `sha256:hex` 形式）

- [ ] **Step 2: 下载 arm64 资产并计算 sha256**

```powershell
$url = "https://github.com/binaricat/Netcatty/releases/download/v1.1.45/Netcatty-1.1.45-win-arm64.exe"
$tmp = "$env:TEMP\netcatty-arm64.exe"
Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
$hash = (Get-FileHash -Path $tmp -Algorithm SHA256).Hash.ToLower()
"sha256:$hash"
```

Expected output: `sha256:dad037d38e482f495554c18d596ea02885f19170f8558b252021e2e43145cd4c`

- [ ] **Step 3: 编写 `bucket/netcatty.json`**

将 Step 1 和 Step 2 的 hash 填入对应位置：

```json
{
    "version": "1.1.45",
    "description": "AI-powered terminal and SSH client with built-in agent support",
    "homepage": "https://github.com/binaricat/Netcatty",
    "license": "GPL-3.0",
    "architecture": {
        "64bit": {
            "url": "https://github.com/binaricat/Netcatty/releases/download/v1.1.45/Netcatty-1.1.45-win-x64.exe",
            "hash": "sha256:66b91fb6c012d02a67bc4f50ca8661f6baeb444f025b162aa696e585258656fe",
            "installer": {
                "file": "Netcatty-1.1.45-win-x64.exe"
            }
        },
        "arm64": {
            "url": "https://github.com/binaricat/Netcatty/releases/download/v1.1.45/Netcatty-1.1.45-win-arm64.exe",
            "hash": "sha256:dad037d38e482f495554c18d596ea02885f19170f8558b252021e2e43145cd4c",
            "installer": {
                "file": "Netcatty-1.1.45-win-arm64.exe"
            }
        }
    },
    "bin": "Netcatty.exe",
    "shortcuts": [
        [
            "Netcatty.exe",
            "Netcatty.lnk",
            "Netcatty",
            ""
        ]
    ],
    "checkver": {
        "url": "https://api.github.com/repos/binaricat/Netcatty/releases/latest",
        "jsonpath": "$.tag_name",
        "regex": "v([\\d.]+)"
    },
    "autoupdate": {
        "architecture": {
            "64bit": {
                "url": "https://github.com/binaricat/Netcatty/releases/download/v$version/Netcatty-$version-win-x64.exe"
            },
            "arm64": {
                "url": "https://github.com/binaricat/Netcatty/releases/download/v$version/Netcatty-$version-win-arm64.exe"
            }
        }
    }
}
```

- [ ] **Step 4: 运行 Pester 验证（仅基础检查，跳过 URL 检查）**

```powershell
$env:RUN_URL_CHECK = $false
.\bin\test.ps1
```

Expected: netcatty 的所有非 URL 测试通过；URL 测试被 `-Skip` 跳过；无失败。

- [ ] **Step 5: 提交**

```bash
git add bucket/netcatty.json
git commit -m "feat(bucket): add netcatty manifest"
```

---

## Task 4: bucket/opencode.json (CLI)

**Files:**
- Create: `bucket/opencode.json`

**Interfaces:**
- Consumes: GitHub Release `v1.17.11` 资产（opencode-windows-x64.zip, opencode-windows-arm64.zip）
- Produces: 通过 Task 2 Pester 套件

- [ ] **Step 1: 下载 x64 CLI zip 并计算 sha256**

```powershell
$url = "https://github.com/anomalyco/opencode/releases/download/v1.17.11/opencode-windows-x64.zip"
$tmp = "$env:TEMP\opencode-cli-x64.zip"
Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
$hash = (Get-FileHash -Path $tmp -Algorithm SHA256).Hash.ToLower()
"sha256:$hash"
```

Expected: `sha256:` + 64 hex chars（实际值在执行时确认；因为 release 资产可能更新，记录实际计算结果）

- [ ] **Step 2: 下载 arm64 CLI zip 并计算 sha256**

```powershell
$url = "https://github.com/anomalyco/opencode/releases/download/v1.17.11/opencode-windows-arm64.zip"
$tmp = "$env:TEMP\opencode-cli-arm64.zip"
Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
$hash = (Get-FileHash -Path $tmp -Algorithm SHA256).Hash.ToLower()
"sha256:$hash"
```

- [ ] **Step 3: 编写 `bucket/opencode.json`**

将 Step 1 和 Step 2 的 hash 填入：

```json
{
    "version": "1.17.11",
    "description": "AI coding agent (CLI)",
    "homepage": "https://github.com/anomalyco/opencode",
    "license": "MIT",
    "architecture": {
        "64bit": {
            "url": "https://github.com/anomalyco/opencode/releases/download/v1.17.11/opencode-windows-x64.zip",
            "hash": "sha256:<x64-hash-from-step-1>",
            "extract": "opencode.exe"
        },
        "arm64": {
            "url": "https://github.com/anomalyco/opencode/releases/download/v1.17.11/opencode-windows-arm64.zip",
            "hash": "sha256:<arm64-hash-from-step-2>",
            "extract": "opencode.exe"
        }
    },
    "bin": "opencode.exe",
    "persist": ".opencode",
    "checkver": {
        "url": "https://api.github.com/repos/anomalyco/opencode/releases/latest",
        "jsonpath": "$.tag_name",
        "regex": "v([\\d.]+)"
    },
    "autoupdate": {
        "architecture": {
            "64bit": {
                "url": "https://github.com/anomalyco/opencode/releases/download/v$version/opencode-windows-x64.zip"
            },
            "arm64": {
                "url": "https://github.com/anomalyco/opencode/releases/download/v$version/opencode-windows-arm64.zip"
            }
        }
    }
}
```

- [ ] **Step 4: 运行 Pester 验证**

```powershell
$env:RUN_URL_CHECK = $false
.\bin\test.ps1
```

Expected: netcatty + opencode 的所有非 URL 测试通过。

- [ ] **Step 5: 提交**

```bash
git add bucket/opencode.json
git commit -m "feat(bucket): add opencode CLI manifest"
```

---

## Task 5: bucket/opencode-desktop.json

**Files:**
- Create: `bucket/opencode-desktop.json`

**Interfaces:**
- Consumes: GitHub Release `v1.17.11` 资产（opencode-desktop-win-x64.exe, opencode-desktop-win-arm64.exe）
- Produces: 通过 Task 2 Pester 套件

- [ ] **Step 1: 下载 x64 Desktop 安装器并计算 sha256**

```powershell
$url = "https://github.com/anomalyco/opencode/releases/download/v1.17.11/opencode-desktop-win-x64.exe"
$tmp = "$env:TEMP\opencode-desktop-x64.exe"
Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
$hash = (Get-FileHash -Path $tmp -Algorithm SHA256).Hash.ToLower()
"sha256:$hash"
```

- [ ] **Step 2: 下载 arm64 Desktop 安装器并计算 sha256**

```powershell
$url = "https://github.com/anomalyco/opencode/releases/download/v1.17.11/opencode-desktop-win-arm64.exe"
$tmp = "$env:TEMP\opencode-desktop-arm64.exe"
Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
$hash = (Get-FileHash -Path $tmp -Algorithm SHA256).Hash.ToLower()
"sha256:$hash"
```

- [ ] **Step 3: 编写 `bucket/opencode-desktop.json`**

```json
{
    "version": "1.17.11",
    "description": "AI coding agent (Desktop app)",
    "homepage": "https://github.com/anomalyco/opencode",
    "license": "MIT",
    "architecture": {
        "64bit": {
            "url": "https://github.com/anomalyco/opencode/releases/download/v1.17.11/opencode-desktop-win-x64.exe",
            "hash": "sha256:<x64-hash-from-step-1>",
            "installer": {
                "file": "opencode-desktop-win-x64.exe"
            }
        },
        "arm64": {
            "url": "https://github.com/anomalyco/opencode/releases/download/v1.17.11/opencode-desktop-win-arm64.exe",
            "hash": "sha256:<arm64-hash-from-step-2>",
            "installer": {
                "file": "opencode-desktop-win-arm64.exe"
            }
        }
    },
    "bin": "opencode.exe",
    "shortcuts": [
        [
            "opencode.exe",
            "opencode.lnk",
            "opencode",
            ""
        ]
    ],
    "checkver": {
        "url": "https://api.github.com/repos/anomalyco/opencode/releases/latest",
        "jsonpath": "$.tag_name",
        "regex": "v([\\d.]+)"
    },
    "autoupdate": {
        "architecture": {
            "64bit": {
                "url": "https://github.com/anomalyco/opencode/releases/download/v$version/opencode-desktop-win-x64.exe"
            },
            "arm64": {
                "url": "https://github.com/anomalyco/opencode/releases/download/v$version/opencode-desktop-win-arm64.exe"
            }
        }
    }
}
```

- [ ] **Step 4: 运行 Pester 验证**

```powershell
$env:RUN_URL_CHECK = $false
.\bin\test.ps1
```

- [ ] **Step 5: 提交**

```bash
git add bucket/opencode-desktop.json
git commit -m "feat(bucket): add opencode-desktop manifest"
```

---

## Task 6: bucket/open-code-review.json

**Files:**
- Create: `bucket/open-code-review.json`

**Interfaces:**
- Consumes: GitHub Release `v1.6.1` 资产（opencodereview-windows-amd64.exe, opencodereview-windows-arm64.exe）+ `sha256sum.txt`
- Produces: 通过 Task 2 Pester 套件

- [ ] **Step 1: 下载 amd64 exe 并计算 sha256**

```powershell
$url = "https://github.com/alibaba/open-code-review/releases/download/v1.6.1/opencodereview-windows-amd64.exe"
$tmp = "$env:TEMP\ocr-amd64.exe"
Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
$hash = (Get-FileHash -Path $tmp -Algorithm SHA256).Hash.ToLower()
"sha256:$hash"
```

- [ ] **Step 2: 下载 arm64 exe 并计算 sha256**

```powershell
$url = "https://github.com/alibaba/open-code-review/releases/download/v1.6.1/opencodereview-windows-arm64.exe"
$tmp = "$env:TEMP\ocr-arm64.exe"
Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
$hash = (Get-FileHash -Path $tmp -Algorithm SHA256).Hash.ToLower()
"sha256:$hash"
```

- [ ] **Step 3: 编写 `bucket/open-code-review.json`**

```json
{
    "version": "1.6.1",
    "description": "AI-powered code review CLI by Alibaba",
    "homepage": "https://github.com/alibaba/open-code-review",
    "license": "Apache-2.0",
    "architecture": {
        "64bit": {
            "url": "https://github.com/alibaba/open-code-review/releases/download/v1.6.1/opencodereview-windows-amd64.exe",
            "hash": "sha256:<amd64-hash-from-step-1>",
            "rename": {
                "opencodereview-windows-amd64.exe": "opencodereview.exe"
            }
        },
        "arm64": {
            "url": "https://github.com/alibaba/open-code-review/releases/download/v1.6.1/opencodereview-windows-arm64.exe",
            "hash": "sha256:<arm64-hash-from-step-2>",
            "rename": {
                "opencodereview-windows-arm64.exe": "opencodereview.exe"
            }
        }
    },
    "bin": "opencodereview.exe",
    "persist": ".opencodereview",
    "checkver": {
        "url": "https://api.github.com/repos/alibaba/open-code-review/releases/latest",
        "jsonpath": "$.tag_name",
        "regex": "v([\\d.]+)"
    },
    "autoupdate": {
        "architecture": {
            "64bit": {
                "url": "https://github.com/alibaba/open-code-review/releases/download/v$version/opencodereview-windows-amd64.exe"
            },
            "arm64": {
                "url": "https://github.com/alibaba/open-code-review/releases/download/v$version/opencodereview-windows-arm64.exe"
            }
        }
    }
}
```

- [ ] **Step 4: 运行 Pester 验证（所有非 URL 测试）**

```powershell
$env:RUN_URL_CHECK = $false
.\bin\test.ps1
```

Expected: 4 个 manifest 全部通过非 URL 测试。

- [ ] **Step 5: 提交**

```bash
git add bucket/open-code-review.json
git commit -m "feat(bucket): add open-code-review manifest"
```

---

## Task 7: 启用 URL 真实可达性测试

**Files:**
- Modify: `Scoop-Bucket.Tests.ps1`（无需修改，跳过 URL 测试需要环境变量）

**Interfaces:**
- Consumes: `RUN_URL_CHECK=$true` 环境变量
- Produces: 端到端 URL 验证

- [ ] **Step 1: 运行 URL 验证**

```powershell
$env:RUN_URL_CHECK = $true
.\bin\test.ps1
```

Expected: 所有 4 个 manifest × 2 架构 = 8 个 URL 测试通过，状态码 200。如果某个 URL 失败，检查：
- 网络代理设置
- GitHub Release 是否被墙（需配置 `Invoke-WebRequest` 的 `-Proxy` 参数，或使用镜像）

- [ ] **Step 2: 修复任何失败（按需）**

如果某个 manifest 的 URL 返回 404：
1. 访问 https://github.com/alibaba/open-code-review/releases/tag/v1.6.1 确认资产名称
2. 修正 manifest 中的 `url` 字段
3. 重跑 `.\bin\test.ps1`

- [ ] **Step 3: 提交（如有修改）**

```bash
git add bucket/*.json
git commit -m "fix(bucket): correct URLs to match upstream assets"
```

---

## Task 8: CI workflow (.github/workflows/ci.yml)

**Files:**
- Create: `.github/workflows/ci.yml`

**Interfaces:**
- Consumes: Task 2 的 `bin/test.ps1`
- Produces: GitHub Actions workflow 文件

- [ ] **Step 1: 创建 `.github/workflows/` 目录**

```powershell
New-Item -ItemType Directory -Path ".github\workflows" -Force
```

- [ ] **Step 2: 编写 `.github/workflows/ci.yml`**

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

- [ ] **Step 3: 提交**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: add Pester validation workflow"
```

- [ ] **Step 4: 推送后验证 CI**

```bash
git push origin master
```

然后访问 https://github.com/ChenXinBest/minicooper/actions → CI workflow → 确认运行成功。如果失败，下载 log 排查：
- `scoop_core` 路径解析失败 → 检查 `bin/test.ps1` 中的 `Convert-Path '.\scoop_core'`
- Pester 模块缺失 → 检查 `potatoqualitee/psmodulecache` 配置

---

## Task 9: Excavator workflow (excavator.yml + bin/auto-pr.ps1)

**Files:**
- Create: `.github/workflows/excavator.yml`
- Create: `bin/auto-pr.ps1`

**Interfaces:**
- Consumes: Task 3-6 的 manifest 中 `checkver` / `autoupdate` 字段
- Produces: 每 4 小时自动检查上游版本，发现新版自动开 PR

- [ ] **Step 1: 编写 `bin/auto-pr.ps1`**

精简自 BucketTemplate，去掉 PR template 和 merge 重试：

```powershell
#Requires -Version 5.1
#Requires -Modules @{ ModuleName = 'BuildHelpers'; ModuleVersion = '2.0.1' }
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.2.0' }

[CmdletBinding()]
param(
    [switch]$Push
)

$ErrorActionPreference = 'Stop'

$env:SCOOP_HOME = "$(Convert-Path '.\scoop_core')"
$ExcavatorModule = Join-Path $PSScriptRoot '..\excavator\Excavator.psm1'
Import-Module $ExcavatorModule -Force

$repo = $env:SCOOP_BUCKET_REPO
if (-not $repo) {
    throw "SCOOP_BUCKET_REPO env var is required"
}

$token = $env:GH_TOKEN
if (-not $token) {
    throw "GH_TOKEN env var is required"
}

$dir = Resolve-Path "$PSScriptRoot\.."
$manifests = Get-ChildItem -Path "$dir\bucket" -Filter '*.json' -File

foreach ($manifest in $manifests) {
    Write-Host "Checking $($manifest.Name)..."
    try {
        $update = Invoke-BucketUpdate -ManifestPath $manifest.FullName -Outdated -ErrorAction Stop
        if ($update) {
            Write-Host "Update available for $($manifest.Name)"
            if ($Push) {
                $branch = "auto/$([System.IO.Path]::GetFileNameWithoutExtension($manifest.Name))-$($update.Version)"
                $title = "[$([System.IO.Path]::GetFileNameWithoutExtension($manifest.Name))] Update to $($update.Version)"
                $body = "Auto-updated by Excavator.`n`nDiff: https://github.com/$repo/compare/master...$branch"

                git config user.name "github-actions[bot]"
                git config user.email "github-actions[bot]@users.noreply.github.com"
                git checkout -B $branch
                git add $manifest.FullName
                git commit -m $title
                git push origin $branch --force

                $prPayload = @{
                    title = $title
                    head  = $branch
                    base  = "master"
                    body  = $body
                } | ConvertTo-Json

                $headers = @{
                    Authorization = "Bearer $token"
                    Accept        = "application/vnd.github+json"
                }
                Invoke-RestMethod -Method Post -Uri "https://api.github.com/repos/$repo/pulls" -Headers $headers -Body $prPayload -ContentType 'application/json'
            }
        }
    } catch {
        Write-Warning "Failed to update $($manifest.Name): $_"
    }
}
```

- [ ] **Step 2: 编写 `.github/workflows/excavator.yml`**

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

- [ ] **Step 3: 提交**

```bash
git add .github/workflows/excavator.yml bin/auto-pr.ps1
git commit -m "ci: add Excavator auto-update workflow"
```

---

## Task 10: 推送完整仓库到 GitHub

**Files:**
- Modify: 无（仅推送）

- [ ] **Step 1: 检查状态**

```bash
git status
```

Expected: 无未提交改动；如有，按预期提交。

- [ ] **Step 2: 推送到远程**

```bash
git push origin master
```

Expected: 推送成功，远程仓库现在含：
- 4 个 manifest in `bucket/`
- CI workflow 已在 `.github/workflows/`
- Excavator workflow 已在 `.github/workflows/`
- 完整文档骨架

- [ ] **Step 3: 在 GitHub 配置 Secrets**

1. 创建 PAT（如果还没有）：
   - 访问 https://github.com/settings/tokens/new?type=beta
   - Repository access：仅 `ChenXinBest/minicooper`
   - Permissions：
     - Contents: Read and write
     - Pull requests: Read and write
     - Metadata: Read-only（自动）
   - 生成并复制 token

2. 在 `https://github.com/ChenXinBest/minicooper/settings/secrets/actions/new` 添加：
   - Name: `GH_PAT`
   - Value: 刚才复制的 token

- [ ] **Step 4: 在 GitHub 配置 Actions 权限**

1. 访问 `https://github.com/ChenXinBest/minicooper/settings/actions`
2. **Actions permissions**: 选 `Allow all actions and reusable workflows`
3. **Workflow permissions**: 选 `Read and write permissions`
4. 保存

---

## Task 11: 端到端验证

**Files:**
- 无（纯验证步骤）

- [ ] **Step 1: 验证 CI workflow 触发并通过**

1. 访问 `https://github.com/ChenXinBest/minicooper/actions/workflows/ci.yml`
2. 确认最近的 `push: master` 触发了 workflow
3. 状态应为 ✅

如果失败：
- 查看 log
- 常见问题：`scoop_core` 路径错误 → 检查 `bin/test.ps1` 第 6 行的 `Convert-Path`

- [ ] **Step 2: 验证 Excavator workflow（手动触发）**

1. 访问 `https://github.com/ChenXinBest/minicooper/actions/workflows/excavator.yml`
2. 点击 `Run workflow` → 选择 master → 确认
3. 等待运行完成（首次约 1-2 分钟）
4. 确认无报错，即使没有发现可更新的版本也属正常

如果失败：
- 检查 `GH_PAT` 是否正确设置
- 检查 `SCOOP_BUCKET_REPO` 环境变量值是否为 `ChenXinBest/minicooper`

- [ ] **Step 3: （可选）Windows 端到端测试**

如用户有 Windows 环境：
```powershell
scoop bucket add minicooper https://github.com/ChenXinBest/minicooper
scoop install minicooper/netcatty
scoop install minicooper/opencode
scoop install minicooper/opencode-desktop
scoop install minicooper/open-code-review
```

每条命令应成功无错误；安装后命令（如 `netcatty --version`）应可执行。

- [ ] **Step 4: 最终提交（如有 README 调整）**

如果 Step 3 发现任何需要修正的地方，修复后：
```bash
git add -A
git commit -m "docs: update README after e2e verification"
git push origin master
```

---

## 自审记录

执行了以下自审检查（与 writing-plans 技能要求的清单对应）：

1. **Spec coverage**: 
   - §1 目标与背景 → Task 1（README）+ Task 3-6（4 manifest）
   - §2 范围与非目标 → 全部任务都在范围内
   - §3 仓库结构 → Task 1（脚手架）+ Task 2（test）+ Task 8（workflows）
   - §4 Manifest 设计 → Task 3-6
   - §5 GitHub Actions 工作流 → Task 8 + Task 9
   - §6 GitHub 仓库配置 → Task 10
   - §7 测试与验证 → Task 2 + Task 7 + Task 11
   - §8 README → Task 1
   - ✅ 完整覆盖

2. **Placeholder scan**: 无 TBD/TODO；hash 占位符 `<x64-hash-from-step-1>` 等明确指向 Step 1 的输出；不算占位符而是"运行时填入"指令。

3. **Type consistency**: 
   - `architecture.64bit` / `architecture.arm64` 在 Task 3-6 一致
   - `bin` / `shortcuts` / `persist` 字段命名一致
   - `checkver.url` 全部用 `https://api.github.com/repos/...` 一致
   - `autoupdate.architecture.<arch>.url` 模板用 `$version` 一致
   - ✅ 无命名漂移