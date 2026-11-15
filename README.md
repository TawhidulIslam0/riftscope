# RiftScope — League of Legends Companion (Android)

A Flutter Android companion inspired by OP.GG and U.GG, backed by Riot's official API and Riot Data Dragon.

## Included
- Flutter Android app with Home, Summoner Search/Profile, Match History/Details, Champions, Items & Runes, and Live Game screens.
- Node.js/Express API proxy. Riot API key stays on the server and is never embedded in the APK.
- Riot account-v1, summoner-v4, league-v4, match-v5 and spectator-v5 integration.
- Live Data Dragon version discovery and champion/item/rune/spell data.
- Empty initial state: no fabricated players, matches, ranked stats, or demo accounts.
- Error states for missing API key, rate limits, unavailable players and network failures.

## Requirements
- Flutter stable (Dart SDK compatible with `pubspec.yaml`)
- Node.js 20+
- Riot Developer API key: https://developer.riotgames.com/

A Riot development key expires every 24 hours. Personal keys are for personal/private use and are rate-limited. A public release requires an approved production key. See Riot's developer portal and API terms before distributing the app.

## 1. Start the backend
```bash
cd backend
npm install
```
Copy `.env.example` to `.env`, then set `RIOT_API_KEY`.
```bash
npm run dev
```
Backend listens on `http://0.0.0.0:3000`.

For Android emulator, `10.0.2.2` reaches your development computer's localhost.
For a physical Android phone, use your computer's LAN IP and ensure both devices share the same network.

## 2. Run the Android app
From the project root:
```bash
flutter pub get
flutter run
```
The default API URL is `http://10.0.2.2:3000`. To override:
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```
For a physical device:
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000
```
Replace the example IP with your computer's LAN IP.

## Region routing
Select the player's platform region (NA, EUW, EUNE, KR, BR, JP, LAN, LAS, OCE, TR, RU, PH, SG, TH, TW, VN). The app maps it to Riot's regional routing cluster for account and match endpoints.

## Data accuracy notes
- Ranked tiers, LP, wins and losses are returned by Riot's League API.
- Match history and match details are returned by Riot Match-V5.
- Live game is returned by Riot Spectator-V5 and is only available while the player is in a supported active game.
- Champion/item/rune/spell content is loaded from Riot Data Dragon using the latest published Data Dragon version. Riot notes that Data Dragon updates can lag a game patch.
- Champion win rates, pick rates, tier lists and recommended builds are NOT provided by these official endpoints. The app does not invent them. Build information shown from match details is sourced from the actual recorded match.
- Riot API access is rate-limited. The backend respects `Retry-After` on 429 responses and returns a useful error.

## Important security and deployment notes
Never put a Riot API key in Flutter source code, app assets, `.env` shipped with the APK, or Git. The key belongs only in the backend environment. The included `.env` is ignored by Git.
For production, deploy the backend behind HTTPS, configure CORS to your app's actual clients, add caching/rate limiting and monitoring, and apply for a Riot production API key before public distribution.

## Build APK
```bash
flutter build apk --release
```
The APK is created at `build/app/outputs/flutter-apk/app-release.apk`.

## License / attribution
Unofficial fan-made companion. Not endorsed by Riot Games. League of Legends and Riot Games are trademarks or registered trademarks of Riot Games, Inc. Follow Riot's API Terms, branding rules and Data Dragon usage requirements.
