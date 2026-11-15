import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { assertRouting, assertPlatform, routingForPlatform, riotGet, encode } from './riot.js';

const app = express();
const port = Number(process.env.PORT || 3000);
const origins = (process.env.CORS_ORIGINS || '').split(',').map(x => x.trim()).filter(Boolean);
app.use(cors(origins.length ? { origin: origins } : {}));
app.use(express.json({ limit: '32kb' }));

app.get('/health', (_req, res) => res.json({ ok: true, service: 'RiftScope Riot API proxy', riotKeyConfigured: Boolean(process.env.RIOT_API_KEY) }));

app.get('/api/account/:routing/:gameName/:tagLine', async (req, res, next) => {
  try {
    const { routing, gameName, tagLine } = req.params;
    assertRouting(routing);
    const account = await riotGet(routing, `/riot/account/v1/accounts/by-riot-id/${encode(gameName)}/${encode(tagLine)}`, 60_000);
    res.json(account);
  } catch (e) { next(e); }
});

app.get('/api/summoner/:platform/:puuid', async (req, res, next) => {
  try {
    const { platform, puuid } = req.params;
    assertPlatform(platform);
    const data = await riotGet(platform, `/lol/summoner/v4/summoners/by-puuid/${encode(puuid)}`, 60_000);
    res.json(data);
  } catch (e) { next(e); }
});

app.get('/api/league/:platform/:puuid', async (req, res, next) => {
  try {
    const { platform, puuid } = req.params;
    assertPlatform(platform);
    const data = await riotGet(platform, `/lol/league/v4/entries/by-puuid/${encode(puuid)}`, 60_000);
    res.json(data);
  } catch (e) { next(e); }
});

app.get('/api/matches/:routing/:puuid', async (req, res, next) => {
  try {
    const { routing, puuid } = req.params;
    assertRouting(routing);
    const start = Math.max(0, Number.parseInt(req.query.start ?? '0', 10) || 0);
    const count = Math.min(20, Math.max(1, Number.parseInt(req.query.count ?? '10', 10) || 10));
    const data = await riotGet(routing, `/lol/match/v5/matches/by-puuid/${encode(puuid)}/ids?start=${start}&count=${count}`, 30_000);
    res.json(data);
  } catch (e) { next(e); }
});

app.get('/api/match/:routing/:matchId', async (req, res, next) => {
  try {
    const { routing, matchId } = req.params;
    assertRouting(routing);
    const data = await riotGet(routing, `/lol/match/v5/matches/${encode(matchId)}`, 5 * 60_000);
    res.json(data);
  } catch (e) { next(e); }
});

app.get('/api/live/:platform/:puuid', async (req, res, next) => {
  try {
    const { platform, puuid } = req.params;
    assertPlatform(platform);
    const data = await riotGet(platform, `/lol/spectator/v5/active-games/by-summoner/${encode(puuid)}`, 10_000);
    res.json(data);
  } catch (e) { next(e); }
});

app.use((req, res) => res.status(404).json({ error: 'RiftScope endpoint not found.' }));
app.use((err, _req, res, _next) => {
  const status = err.status || 500;
  if (status >= 500 && status !== 503) console.error(err);
  if (err.retryAfter) res.setHeader('Retry-After', err.retryAfter);
  res.status(status).json({ error: err.message || 'Unexpected server error.' });
});

app.listen(port, '0.0.0.0', () => console.log(`RiftScope backend listening on port ${port}`));
