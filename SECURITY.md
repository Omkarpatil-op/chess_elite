# Security & Anti-Cheat Architecture

Security is treated as a first-class citizen across client and server interactions.

---

## 🔒 Token & Credential Management
* **Never Store Plaintext Secrets**: Auth tokens and sensitive sessions are persisted via `SecureStorageService`, utilizing platform-native Keystore (Android) and Keychain (iOS) interfaces with key hashing and salt protection.
* **No Hardcoded Keys**: Production API secrets, database passwords, and private signing keys are never compiled into the application bundle. Environment configuration is injected via `--dart-define`.
* **Automatic Log Redaction**: `AppLogger` automatically redacts Authorization Bearer tokens, passwords, and API keys before outputting debug diagnostics.

---

## 🛡️ Server-Authoritative Anti-Cheat
* **Zero Client Authority**: The mobile client has zero authority over game outcomes, clock times, or ELO calculations.
* **Full Move Validation**: Every submitted move is validated against full legal chess rules on the authoritative game server before state mutation.
* **Monotonic Sequence Numbers**: Event sequence numbers prevent stale, out-of-order, or duplicate packet replay attacks.
* **Account Deletion & Data Privacy**: Full user erasure wipes local storage, cached profiles, and tokens cleanly per GDPR/CCPA privacy standards.
