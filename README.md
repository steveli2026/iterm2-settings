# iTerm2 Settings

这是一份可公开、可迁移的 iTerm2 配置备份。仓库保留 Profiles、配色、字体、快捷键、Hotkey Window、外观与交互设置，并提供一键恢复脚本。

## 在新 Mac 上恢复

先安装并至少启动一次 iTerm2，然后退出 iTerm2：

```bash
git clone https://github.com/steveli2026/iterm2-settings.git
cd iterm2-settings
./install.sh
open -a iTerm
```

脚本会先把新 Mac 上已有的 iTerm2 配置备份到：

```text
~/Library/Application Support/iTerm2/Settings Backups/
```

如需无交互执行，可用 `./install.sh --yes`。

## 从当前 Mac 更新仓库

```bash
./scripts/export.sh
git diff -- settings/com.googlecode.iterm2.plist
git add settings/com.googlecode.iterm2.plist
git commit -m "Update iTerm2 settings"
git push
```

`export.sh` 会把 macOS preferences database 中的当前设置导出、转成可读 XML，并自动清理：

- 窗口位置、最近记录、安装 ID 和 `NoSync*` 运行状态
- 写死的本机 Home 路径（归一化为 `~`）
- iTerm2 / Sparkle 的版本和更新运行状态
- 指向其他自定义 preferences folder 的路径

导出时还会扫描常见 token、私钥、带密码 URL、邮箱及 `user@host` 形式的身份信息；发现可疑内容时会拒绝更新目标 plist。

## 有意不纳入 public repo 的内容

这不是 iTerm2 的“Export All Settings and Data”完整镜像。以下内容可能包含隐私或密钥，因此不会进入本仓库：

- Password Manager / macOS Keychain 中的密码
- AI Chat 数据库和 secure settings
- Shell、命令、目录、剪贴板历史
- SavedState、滚屏内容与正在运行的 session
- Python API scripts、shell integration 和其他应用数据

iTerm2 官方也支持从自定义文件夹或 URL 加载设置；本仓库选择显式的 `export.sh` + `install.sh`，让每次公开发布前都经过清理和审阅。参见 [iTerm2 General Preferences](https://iterm2.com/documentation-preferences-general.html)。

## 要求

- 恢复：macOS、iTerm2，以及系统自带的 `defaults` 和 `plutil`
- 更新导出：另需 `python3`

## License

[MIT](LICENSE)
