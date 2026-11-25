# OneClick Gallery

Ready-made custom items. Download a pack and open it from **Settings › Custom › ⋯ › Import…**. OneClick shows every command before adding anything.

| Pack | Items |
|---|---|
| [developer.json](developer.json) | Docker (toggle), Kill Port 3000, Clean DerivedData, Copy UUID |
| [network.json](network.json) | Wi-Fi (toggle), Flush DNS (as administrator), Public IP (info), Local IP (info) |
| [system.json](system.json) | Battery (info), Uptime (info), Lock Screen, Eject All Disks |

## Single items as links

A `oneclick://add?…` link adds one item. Paste it in Safari's address bar, or run it with `open` in Terminal:

```bash
open 'oneclick://add?name=Public%20IP&kind=info&symbol=globe&on=curl%20-s%20https://api.ipify.org&group=Network&timeout=10&refresh=300'
```

```bash
open 'oneclick://add?name=Local%20IP&kind=info&symbol=network&on=ipconfig%20getifaddr%20en0%20%7C%7C%20echo%20Offline&group=Network&refresh=60'
```

```bash
open 'oneclick://add?name=Lock%20Screen&kind=action&symbol=lock&on=pmset%20displaysleepnow&group=System'
```

To share one of your items, right-click it in **Settings › Custom** and choose **Copy Link** or **Export…**.

### Link parameters

| Parameter | Meaning |
|---|---|
| `name` | Name shown on the tile (required) |
| `kind` | `toggle`, `action` or `info` |
| `symbol` | Any SF Symbol name |
| `on` | Command for buttons, info tiles and turning a toggle on (required) |
| `off` | Command for turning a toggle off (required for toggles) |
| `status` | Optional status check for toggles |
| `group` | Heading in the panel |
| `admin=1` | Run as administrator |
| `confirm=1` | Click twice to run |
| `copy=1` | Copy the button's output to the clipboard |
| `timeout` | Seconds before the command is stopped |
| `refresh` | Seconds between info tile refreshes |

## Contributing

Add your item to a pack (or a new `.json` file) and open a pull request. Keep commands readable and avoid anything destructive without `"requiresConfirmation": true`.
