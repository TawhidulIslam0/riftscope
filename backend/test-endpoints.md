# Backend endpoint smoke test

After configuring `backend/.env` and running `npm run dev`:

- `GET http://localhost:3000/health`
- `GET http://localhost:3000/api/account/americas/GameName/TagLine`
- `GET http://localhost:3000/api/summoner/na1/PUUID`
- `GET http://localhost:3000/api/league/na1/PUUID`
- `GET http://localhost:3000/api/matches/americas/PUUID?start=0&count=10`
- `GET http://localhost:3000/api/match/americas/MATCH_ID`
- `GET http://localhost:3000/api/live/na1/PUUID`

Use actual Riot IDs and PUUIDs. A 404 for a nonexistent player/match is expected; a 401 usually means the key is invalid or expired.
