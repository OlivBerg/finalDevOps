import Redis from 'ioredis'

const API_KEY = process.env.WEATHER_API_KEY
const TEN_MINUTES_SECONDS = 60 * 10 // TTL in seconds for Redis

let redis: Redis | null = null

function getRedis(): Redis | null {
  if (!redis && process.env.REDIS_HOST && process.env.REDIS_KEY) {
    redis = new Redis({
      host: process.env.REDIS_HOST,
      port: parseInt(process.env.REDIS_PORT ?? '6380'),
      password: process.env.REDIS_KEY,
      tls: {},
    })
  }
  return redis
}

interface FetchWeatherDataParams {
  lat: number
  lon: number
  units: string
}
export async function fetchWeatherData({
  lat,
  lon,
  units,
}: FetchWeatherDataParams) {
  const baseURL = 'https://api.openweathermap.org/data/2.5/weather'
  const queryString = `lat=${lat}&lon=${lon}&units=${units}&appid=${API_KEY}`
  const cacheKey = `weather:${lat}:${lon}:${units}`

  const client = getRedis()
  if (client) {
    const cached = await client.get(cacheKey)
    if (cached) return JSON.parse(cached)
  }

  const response = await fetch(`${baseURL}?${queryString}`)
  const data = await response.json()

  if (client) {
    await client.set(cacheKey, JSON.stringify(data), 'EX', TEN_MINUTES_SECONDS)
  }

  return data
}

export async function getGeoCoordsForPostalCode(
  postalCode: string,
  countryCode: string,
) {
  const url = `http://api.openweathermap.org/geo/1.0/zip?zip=${postalCode},${countryCode}&appid=${API_KEY}`
  const response = await fetch(url)
  const data = response.json()
  return data
}
