# Privacy Policy — Show My IP

_Last updated: October 16, 2026_

Show My IP is a macOS menu bar app that shows your public IP address and its country. This policy explains what the app does with data.

## The short version

- The developer does not collect, store or receive any of your data.
- The app has no accounts, analytics, advertising or tracking.
- To find your public IP, the app has to send requests to the internet services listed below. Those services see your IP address, just as any website you open does.
- Everything the app remembers stays on your Mac.

## Network requests

To show your public IP, the app connects to these services:

| Service | When | What it receives |
| --- | --- | --- |
| Cloudflare (`cloudflare.com`, `1.1.1.1`) | Always, to find your public IPv4 and IPv6 addresses and measure ping | Your IP address, as with any web request |
| ipinfo.io | If Cloudflare is unavailable (fallback), or if you turn on **City and provider** or **Map** | Your IP address |
| Akamai (`whoami.akamai.net`) and ipinfo.io | Only if you turn on **DNS check** | Your DNS resolver's IP address |
| Apple Maps | Only if you turn on **Map** | The approximate location of your IP (city level) to draw the map |

Requests contain no identifiers, names, device information or other personal data. These services process requests under their own privacy policies:

- Cloudflare: https://www.cloudflare.com/privacypolicy/
- ipinfo.io: https://ipinfo.io/privacy-policy
- Akamai: https://www.akamai.com/legal/privacy-statement
- Apple: https://www.apple.com/legal/privacy/

## Data stored on your Mac

The app stores your settings and, if enabled, a history of up to 50 recent IP changes (address, country and time). This data is kept only in the app's sandboxed storage on your Mac and is never sent anywhere. You can turn history off and clear it in **Settings → Privacy**. Deleting the app deletes this data. A CSV export is created only when you choose to save it.

## Notifications

Notifications are generated on your Mac and are not sent through any server.

## Children

The app does not knowingly collect data from anyone, including children.

## Changes

If this policy changes, the updated version will be published at this address with a new date.

## Contact

Questions about privacy: open an issue at https://github.com/pandamy619/show-my-ip/issues
