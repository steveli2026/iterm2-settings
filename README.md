# iTerm2 Settings

This repository contains a portable, public-safe backup of my iTerm2 settings. It preserves profiles, color schemes, fonts, key bindings, the Hotkey Window, appearance, and interaction preferences. It also includes scripts for restoring and safely exporting the settings.

## Restore on a New Mac

Install and launch iTerm2 at least once, then quit it completely:

```bash
git clone https://github.com/steveli2026/iterm2-settings.git
cd iterm2-settings
./install.sh
open -a iTerm
```

Before importing the repository settings, the installer backs up any existing iTerm2 preferences to:

```text
~/Library/Application Support/iTerm2/Settings Backups/
```

Use `./install.sh --yes` for a non-interactive installation.

## Update the Repository from the Current Mac

```bash
./scripts/export.sh
git diff -- settings/com.googlecode.iterm2.plist
git add settings/com.googlecode.iterm2.plist
git commit -m "Update iTerm2 settings"
git push
```

`export.sh` reads the current settings from the macOS preferences database, converts them to readable XML, and automatically removes:

- Window positions, recent items, installation IDs, and `NoSync*` runtime state
- Machine-specific absolute Home paths, normalized to `~`
- iTerm2 and Sparkle version or updater runtime state
- References to other custom preferences folders

The export process also scans for common tokens, private keys, credential-bearing URLs, email addresses, and `user@host` identities. If it detects suspicious content, it refuses to update the destination plist.

## Intentionally Excluded from This Public Repository

This is not a complete iTerm2 "Export All Settings and Data" archive. The following data may contain private information or credentials and is intentionally excluded:

- Password Manager and macOS Keychain credentials
- AI Chat databases and secure settings
- Shell, command, directory, and clipboard history
- SavedState, scrollback content, and running sessions
- Python API scripts, shell integration files, and other application data

iTerm2 also supports loading settings from a custom folder or URL. This repository uses explicit `export.sh` and `install.sh` commands so every public update can be sanitized and reviewed first. See the [iTerm2 General Preferences documentation](https://iterm2.com/documentation-preferences-general.html).

## Requirements

- Restore: macOS, iTerm2, and the built-in `defaults` and `plutil` commands
- Export: the restore requirements plus `python3`

## License

[MIT](LICENSE)
