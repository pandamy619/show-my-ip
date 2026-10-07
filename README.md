<p align="center">
  <img src="ShowMyIP/Assets.xcassets/AppIcon.appiconset/icon_256.png" width="128" alt="Show My IP">
</p>

<h1 align="center">Show My IP</h1>

<p align="center">Your country flag and public IP in the macOS menu bar.</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-0.1.0-blue" alt="Version 0.1.0">
  <img src="https://img.shields.io/badge/macOS-14%2B-black" alt="macOS 14+">
  <img src="https://img.shields.io/badge/Swift-6-orange" alt="Swift 6">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="MIT License">
</p>

<p align="center"><a href="README.ru.md">Русская версия</a></p>

<!-- Screenshots: compact menu bar, full menu bar, open menu, notification -->

## Features

- **Flag and IP in the menu bar,** with a compact mode for small screens.
- **Always current.** Rechecks on network changes, VPN on/off and every 5 minutes.
- **Details on click.** Country, public IP, city and provider when available, local addresses. Click an address to copy it.
- **Notifications.** Country change, IP change, connection loss, and a warning when traffic leaves through your home country — VPN may be off.
- **Launch at login.**
- **Private by design.** No analytics, no third-party dependencies, sandboxed.

## Installation

1. Download `ShowMyIP.dmg` from [Releases](https://github.com/pandamy619/show-my-ip/releases).
2. Drag **Show My IP** to **Applications**.
3. Launch it. The app is not signed by Apple, so macOS blocks the first launch: open **System Settings → Privacy & Security** and click **Open Anyway**. This is needed once.

## Usage

- Click the flag to see details and copy addresses.
- **Settings** (⌘,):
  - **General** — launch at login, display mode (Automatic / Compact / Full), compact style.
  - **Notifications** — what to notify about and your home country.
- **Home country alert:** turn off your VPN, open Settings → Notifications and pick the country you are in. You will be warned whenever your traffic goes out through it.

## FAQ

**The IP differs from what website X shows.**
Your VPN probably uses split tunneling: different sites go through different routes.

**No city or provider in the menu.**
They come from the backup service and appear only when it was used.

**Only a flag, no IP.**
That is the compact mode. Change it in Settings → General.

**No Dock icon.**
By design — the app lives in the menu bar. Quit from its menu (⌘Q).

**How do I uninstall?**
Quit the app and move it from Applications to the Trash.

## Privacy

The app makes two kinds of HTTPS requests and nothing else:

| Service | When | Data received |
|---|---|---|
| `www.cloudflare.com/cdn-cgi/trace` | every refresh | IP, country |
| `ipinfo.io/json` | only if Cloudflare fails | IP, country, city, provider |

Responses are validated before use. The IP is logged as private and never appears in system logs in plain text. The app runs in the App Sandbox with Hardened Runtime and only the outgoing network entitlement.

## For developers

Requirements: Xcode 26+, macOS 14+.

```sh
git clone https://github.com/pandamy619/show-my-ip.git
cd show-my-ip
open ShowMyIP.xcodeproj
```

| Command | Description |
|---|---|
| `make test` | unit tests (Swift Testing) |
| `make lint` | SwiftLint + swift-format, strict |
| `make format` | auto-format |
| `make hooks` | run lint before every commit |

`make lint` needs SwiftLint: `brew install swiftlint`.

```
ShowMyIP/
  App/            app state, refresh logic, logging
  Domain/         validated models: IP address, country code, IP info
  Services/       HTTP client, IP providers, network monitor
  Notifications/  notification rules and delivery
  Settings/       settings window, launch at login
  UI/             menu bar label, menu, display modes
ShowMyIPTests/    tests mirroring the app structure
```

The app icon is generated from `design/logo.jpg` with `scripts/make_app_icon.py`.

## License

[MIT](LICENSE)
