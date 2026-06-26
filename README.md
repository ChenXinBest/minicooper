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