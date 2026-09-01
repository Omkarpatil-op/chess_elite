# Environment Configuration

Chess Elite supports isolated configurations for `development`, `staging`, and `production`.

---

## 🔑 Environment Variables

| Variable | Description | Default (Local) |
| :--- | :--- | :--- |
| `API_BASE_URL` | Base HTTP endpoint for REST services | `https://api.chesselite.com/v1` |
| `WEBSOCKET_URL` | Authoritative WebSocket game server endpoint | `wss://realtime.chesselite.com/ws` |
| `ENVIRONMENT` | Runtime environment mode (`development`, `staging`, `production`) | `development` |
| `ANALYTICS_ENABLED`| Toggle telemetry collection | `true` |
| `LOG_LEVEL` | Minimum log severity (`DEBUG`, `INFO`, `WARNING`, `ERROR`) | `DEBUG` |

---

## 🛠️ Usage with Dart Defines

Compile or run with environment flags:

```bash
flutter run --dart-define=ENVIRONMENT=production \
            --dart-define=API_BASE_URL=https://api.chesselite.com/v1 \
            --dart-define=WEBSOCKET_URL=wss://realtime.chesselite.com/ws
```
