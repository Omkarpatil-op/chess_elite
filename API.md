# API & Real-time Protocol Specification

Chess Elite communicates with the backend through typed REST APIs and a low-latency duplex WebSocket connection.

---

## 📡 REST API Contracts

### Authentication Endpoints

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "player@chesselite.com",
  "password": "SecurePassword123!"
}

Response (200 OK):
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "d7a8f9...",
  "user": {
    "id": "u_1029",
    "username": "GrandmasterX",
    "ratingRapid": 1540
  }
}
```

```http
POST /api/v1/auth/guest
Response (200 OK):
{
  "token": "guest_jwt_token...",
  "user": {
    "id": "guest_8921",
    "username": "Grandmaster_8921",
    "isGuest": true
  }
}
```

### Matchmaking Endpoints

```http
POST /api/v1/matchmaking/queue
Authorization: Bearer <token>

{
  "timeControlId": "rapid_10_0",
  "isRated": true
}

Response (200 OK):
{
  "ticketId": "ticket_772",
  "status": "QUEUED",
  "estimatedWaitSec": 3
}
```

---

## ⚡ WebSocket Real-time Event Specification

### Client-to-Server Events

| Event Type | Payload | Description |
| :--- | :--- | :--- |
| `MOVE_MADE` | `{"gameId": "g_1", "uci": "e2e4", "moveSequence": 1}` | Submits a move in UCI notation |
| `DRAW_OFFERED` | `{"gameId": "g_1"}` | Proposes a draw to opponent |
| `DRAW_ACCEPTED` | `{"gameId": "g_1"}` | Accepts an active draw offer |
| `DRAW_DECLINED` | `{"gameId": "g_1"}` | Declines a draw offer |
| `PLAYER_RESIGNED`| `{"gameId": "g_1"}` | Forfeits match |
| `PING` | `{"timestamp": "2026-08-31T18:00:00Z"}` | Heartbeat latency ping |

### Server-to-Client Events

| Event Type | Payload | Description |
| :--- | :--- | :--- |
| `GAME_START` | `{"gameId": "g_1", "fen": "...", "whiteTimeMs": 600000, "blackTimeMs": 600000}` | Begins match |
| `MOVE_MADE` | `{"move": {...}, "fen": "...", "whiteTimeMs": 598200, "isCheck": false}` | Broadcasts validated move |
| `CLOCK_SYNC` | `{"whiteTimeMs": 595000, "blackTimeMs": 600000}` | Periodically syncs clocks |
| `GAME_OVER` | `{"result": "checkmate", "winner": "white", "reason": "Checkmate: WHITE wins!"}` | Concludes match |
| `PONG` | `{"latencyMs": 42}` | Heartbeat response |
