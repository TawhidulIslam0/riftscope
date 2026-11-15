import { platformToRouting, validRouting, validPlatforms } from './regions.js';

const API_KEY = process.env.RIOT_API_KEY;
const cache = new Map();

function cached(key, ttlMs) {
  const item = cache.get(key);
  if (!item || Date.now() > item.expires) return null;
  return item.value;
}
function put(key, value, ttlMs) {
  cache.set(key, { value, expires: Date.now() + ttlMs });
  if (cache.size > 1500) {
    const oldest = cache.keys().next().value;
    cache.delete(oldest);
  }
}
function requireKey() {
  if (!API_KEY) {
    const error = new Error('Riot API key is not configured. Add RIOT_API_KEY to backend/.env and restart the backend.');
    error.status = 503;
    throw error;
  }
}
export function assertRouting(region) {
  if (!validRouting.has(region)) {
    const error = new Error('Invalid Riot regional routing value.');
    error.status = 400;
    throw error;
  }
}
export function assertPlatform(platform) {
  if (!validPlatforms.has(platform)) {
    const error = new Error('Invalid Riot platform region.');
    error.status = 400;
    throw error;
  }
}
export function routingForPlatform(platform) {
  assertPlatform(platform);
  return platformToRouting[platform];
}
export async function riotGet(host, path, ttlMs = 0) {
  requireKey();
  const url = `https://${host}.api.riotgames.com${path}`;
  const key = `${host}:${path}`;
  if (ttlMs) {
    const hit = cached(key, ttlMs);
    if (hit) return hit;
  }
  const response = await fetch(url, { headers: { 'X-Riot-Token': API_KEY } });
  if (response.status === 429) {
    const error = new Error(`Riot API rate limit reached. Retry after ${response.headers.get('Retry-After') || 'a short wait'} seconds.`);
    error.status = 429;
    error.retryAfter = response.headers.get('Retry-After');
    throw error;
  }
  if (!response.ok) {
    const map = { 400: 'Riot rejected the request.', 401: 'Riot API key is invalid or expired.', 403: 'Riot denied access to this API.', 404: 'Player or game data was not found.', 415: 'Riot rejected the request format.', 500: 'Riot API internal error.', 503: 'Riot API is temporarily unavailable.' };
    const error = new Error(map[response.status] || `Riot API request failed (${response.status}).`);
    error.status = response.status;
    throw error;
  }
  const data = await response.json();
  if (ttlMs) put(key, data, ttlMs);
  return data;
}
export function encode(value) { return encodeURIComponent(value); }
