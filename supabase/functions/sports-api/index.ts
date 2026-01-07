// @ts-nocheck
// Supabase Edge Function for Sports API with caching and real-time updates
// This function acts as a proxy and aggregator for sports data APIs

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { corsHeaders } from "../_shared/cors.ts"

// Environment variables for API keys
const SPORTS_API_KEY = Deno.env.get('SPORTS_API_KEY') // TheSportsDB or Sportmonks API key
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || ''
const SUPABASE_SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''

// API Configuration
// Using TheSportsDB free tier as example (replace with your preferred API)
const SPORTS_API_BASE_URL = 'https://www.thesportsdb.com/api/v1/json'
const CACHE_DURATION_MINUTES = 5 // Shorter cache for live events

// Initialize Supabase client
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY)

async function getCachedResponse(cacheKey: string): Promise<any | null> {
  try {
    const expiresAt = new Date()
    
    const { data, error } = await supabase
      .from('sports_api_cache')
      .select('cache_data, expires_at')
      .eq('cache_key', cacheKey)
      .gt('expires_at', new Date().toISOString())
      .single()

    if (error || !data) {
      return null
    }

    return data.cache_data
  } catch (error) {
    console.error('Cache retrieval error:', error)
    return null
  }
}

async function setCachedResponse(
  cacheKey: string,
  responseData: any,
  cacheType: string,
  sportType?: string
): Promise<void> {
  try {
    const expiresAt = new Date(Date.now() + CACHE_DURATION_MINUTES * 60 * 1000)
    
    await supabase
      .from('sports_api_cache')
      .upsert({
        cache_key: cacheKey,
        cache_data: responseData,
        cache_type: cacheType,
        sport_type: sportType,
        expires_at: expiresAt.toISOString(),
      })
  } catch (error) {
    console.error('Cache storage error:', error)
  }
}

async function getEventsFromDatabase(
  status: string,
  sportType?: string,
  leagueId?: string,
  region?: string
): Promise<any[]> {
  try {
    let query = supabase
      .from('sport_events')
      .select(`
        *,
        league:leagues(*),
        streaming_options:broadcasting_rights(
          *,
          provider:streaming_providers(*)
        )
      `)
      .eq('status', status)

    if (sportType) {
      query = query.eq('sport_type', sportType)
    }

    if (leagueId) {
      query = query.eq('league_id', leagueId)
    }

    if (region) {
      query = query.or(`region.eq.${region},region.is.null`)
    }

    const { data, error } = await query.order('start_time', { ascending: true })

    if (error) {
      console.error('Database query error:', error)
      return []
    }

    return data || []
  } catch (error) {
    console.error('Database error:', error)
    return []
  }
}

async function syncEventToDatabase(eventData: any): Promise<void> {
  try {
    // Map external API data to database schema
    const event = {
      external_api_id: eventData.id || eventData.idEvent,
      home_team: eventData.home_team || eventData.strHomeTeam,
      away_team: eventData.away_team || eventData.strAwayTeam,
      home_team_logo: eventData.home_team_logo || eventData.strHomeTeamBadge,
      away_team_logo: eventData.away_team_logo || eventData.strAwayTeamBadge,
      sport_type: eventData.sport_type || 'football',
      start_time: eventData.start_time || eventData.dateEvent,
      status: eventData.status || 'upcoming',
      home_score: parseInt(eventData.home_score || eventData.intHomeScore || '0'),
      away_score: parseInt(eventData.away_score || eventData.intAwayScore || '0'),
      venue: eventData.venue || eventData.strVenue,
      last_synced_at: new Date().toISOString(),
    }

    await supabase
      .from('sport_events')
      .upsert(event, { onConflict: 'external_api_id' })

  } catch (error) {
    console.error('Event sync error:', error)
  }
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { pathname } = new URL(req.url)
    const requestBody = await req.json().catch(() => ({}))

    // Route: Get live matches
    if (pathname.endsWith('/live')) {
      const { sport_type, league_id, region } = requestBody
      const cacheKey = `live_${sport_type || 'all'}_${league_id || 'all'}_${region || 'all'}`

      // Check cache first
      const cached = await getCachedResponse(cacheKey)
      if (cached) {
        return new Response(
          JSON.stringify({ status: 'success', events: cached, source: 'cache' }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json', 'X-Cache': 'HIT' } }
        )
      }

      // Get from database
      const events = await getEventsFromDatabase('live', sport_type, league_id, region)

      // Cache the response
      await setCachedResponse(cacheKey, events, 'live', sport_type)

      return new Response(
        JSON.stringify({ status: 'success', events, source: 'database' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json', 'X-Cache': 'MISS' } }
      )
    }

    // Route: Get upcoming matches
    if (pathname.endsWith('/upcoming')) {
      const { sport_type, league_id, region, from_date, to_date, page = 1, page_size = 20 } = requestBody
      const cacheKey = `upcoming_${sport_type || 'all'}_${league_id || 'all'}_${page}`

      // Check cache
      const cached = await getCachedResponse(cacheKey)
      if (cached) {
        return new Response(
          JSON.stringify({ status: 'success', events: cached, source: 'cache' }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json', 'X-Cache': 'HIT' } }
        )
      }

      // Get from database
      let query = supabase
        .from('sport_events')
        .select(`
          *,
          league:leagues(*),
          streaming_options:broadcasting_rights(
            *,
            provider:streaming_providers(*)
          )
        `)
        .in('status', ['upcoming', 'live'])

      if (sport_type) {
        query = query.eq('sport_type', sport_type)
      }

      if (league_id) {
        query = query.eq('league_id', league_id)
      }

      if (from_date) {
        query = query.gte('start_time', from_date)
      }

      if (to_date) {
        query = query.lte('start_time', to_date)
      }

      const { data: events, error } = await query
        .order('start_time', { ascending: true })
        .range((page - 1) * page_size, page * page_size - 1)

      if (error) {
        throw error
      }

      // Cache the response
      await setCachedResponse(cacheKey, events || [], 'upcoming', sport_type)

      return new Response(
        JSON.stringify({ status: 'success', events: events || [], source: 'database' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json', 'X-Cache': 'MISS' } }
      )
    }

    // Route: Get match details
    if (pathname.includes('/match/')) {
      const matchId = pathname.split('/').pop()
      
      const { data: event, error } = await supabase
        .from('sport_events')
        .select(`
          *,
          league:leagues(*),
          streaming_options:broadcasting_rights(
            *,
            provider:streaming_providers(*)
          )
        `)
        .eq('id', matchId)
        .single()

      if (error || !event) {
        return new Response(
          JSON.stringify({ status: 'error', message: 'Match not found' }),
          { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      return new Response(
        JSON.stringify({ status: 'success', event }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Route: Search matches
    if (pathname.endsWith('/search')) {
      const { query: searchQuery, sport_type, status, from_date, to_date } = requestBody

      if (!searchQuery) {
        return new Response(
          JSON.stringify({ status: 'error', message: 'Query parameter is required' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      let dbQuery = supabase
        .from('sport_events')
        .select(`
          *,
          league:leagues(*),
          streaming_options:broadcasting_rights(
            *,
            provider:streaming_providers(*)
          )
        `)
        .or(`home_team.ilike.%${searchQuery}%,away_team.ilike.%${searchQuery}%`)

      if (sport_type) {
        dbQuery = dbQuery.eq('sport_type', sport_type)
      }

      if (status) {
        dbQuery = dbQuery.eq('status', status)
      }

      if (from_date) {
        dbQuery = dbQuery.gte('start_time', from_date)
      }

      if (to_date) {
        dbQuery = dbQuery.lte('start_time', to_date)
      }

      const { data: events, error } = await dbQuery
        .order('start_time', { ascending: true })
        .limit(50)

      if (error) {
        throw error
      }

      return new Response(
        JSON.stringify({ status: 'success', events: events || [] }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Route: Get leagues
    if (pathname.endsWith('/leagues')) {
      const { sport_type, country } = requestBody
      const cacheKey = `leagues_${sport_type || 'all'}_${country || 'all'}`

      const cached = await getCachedResponse(cacheKey)
      if (cached) {
        return new Response(
          JSON.stringify({ status: 'success', leagues: cached }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json', 'X-Cache': 'HIT' } }
        )
      }

      let query = supabase.from('leagues').select('*').eq('is_active', true)

      if (sport_type) {
        query = query.eq('sport_type', sport_type)
      }

      if (country) {
        query = query.eq('country', country)
      }

      const { data: leagues, error } = await query.order('name')

      if (error) {
        throw error
      }

      await setCachedResponse(cacheKey, leagues || [], 'leagues', sport_type)

      return new Response(
        JSON.stringify({ status: 'success', leagues: leagues || [] }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json', 'X-Cache': 'MISS' } }
      )
    }

    // Route: Get streaming providers
    if (pathname.endsWith('/providers')) {
      const { region } = requestBody
      const cacheKey = `providers_${region || 'all'}`

      const cached = await getCachedResponse(cacheKey)
      if (cached) {
        return new Response(
          JSON.stringify({ status: 'success', providers: cached }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json', 'X-Cache': 'HIT' } }
        )
      }

      let query = supabase.from('streaming_providers').select('*').eq('is_active', true)

      if (region) {
        query = query.contains('available_regions', [region])
      }

      const { data: providers, error } = await query.order('name')

      if (error) {
        throw error
      }

      await setCachedResponse(cacheKey, providers || [], 'providers')

      return new Response(
        JSON.stringify({ status: 'success', providers: providers || [] }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json', 'X-Cache': 'MISS' } }
      )
    }

    // Route: Get streaming options for a match
    if (pathname.includes('/streaming/')) {
      const matchId = pathname.split('/').pop()
      const { region } = requestBody

      let query = supabase
        .from('broadcasting_rights')
        .select(`
          *,
          provider:streaming_providers(*)
        `)
        .eq('event_id', matchId)
        .eq('is_active', true)

      if (region) {
        query = query.or(`available_regions.cs.{${region}},available_regions.is.null`)
      }

      const { data: options, error } = await query

      if (error) {
        throw error
      }

      return new Response(
        JSON.stringify({ status: 'success', options: options || [] }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Default response for unknown routes
    return new Response(
      JSON.stringify({ 
        status: 'error', 
        message: 'Unknown endpoint',
        availableEndpoints: [
          '/live - Get live matches',
          '/upcoming - Get upcoming matches',
          '/match/:id - Get match details',
          '/search - Search matches',
          '/leagues - Get leagues',
          '/providers - Get streaming providers',
          '/streaming/:matchId - Get streaming options for match'
        ]
      }),
      { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Edge function error:', error)
    return new Response(
      JSON.stringify({ 
        status: 'error', 
        message: error.message || 'Internal server error' 
      }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
