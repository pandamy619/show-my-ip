# Changelog

## Unreleased

- Optional map of the IP location at the top of the menu (Apple Maps, off by default).
- IPv6 leak warning: the menu and a notification tell you when IPv6 goes through another country than IPv4, a sign that IPv6 bypasses the VPN.

## [0.2.0] — 2026-10-08

- Privacy mode: ⌥-click the menu bar icon to hide the IP in the menu bar, menu and notifications, with an animated spoiler or other styles.
- Russian localization.
- Public IPv4 and IPv6 at the same time; choose which one the menu bar shows.
- Optional city and provider for every connection via ipinfo.io (off by default).
- History of the last public IP changes in the menu, stored only on this Mac.
- Redesigned settings window with a sidebar; clearer notification permission flow.
- Network responses are now cut off as soon as they exceed the size limit instead of being downloaded in full.

## [0.1.0] — 2026-10-07

First release.

- Country flag and public IP in the menu bar, with a compact mode for small screens.
- Automatic refresh of the IP and flag.
- Menu with country, public IP, city, provider and local addresses; click to copy.
- Notifications: country change, IP change, connection loss, home country alert.
- Settings window, launch at login.
- Cloudflare as the primary IP source, ipinfo.io as a fallback.
