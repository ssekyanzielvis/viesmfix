// @ts-nocheck
// Supabase Edge Function for periodic sports data sync
// This function should be triggered by a cron job to update live scores and match statuses

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const SPORTS_API_KEY = Deno.env.get('SPORTS_API_KEY')
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || ''
const SUPABASE_SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''

// API Configuration - using TheSportsDB as example
const SPORTS_API_BASE_URL = 'https://www.thesportsdb.com/api/v1/json'

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY)

interface SyncResult {
  updated: number
  errors: number
  duration: number
}

async function fetchLiveEventsFromAPI(): Promise<any[]> {
  try {
    // This is an example - replace with your actual sports API
    const response = await fetch(
      `${SPORTS_API_BASE_URL}/${SPORTS_API_KEY}/livescore.php`
    )
    
    if (!response.ok) {
      throw new Error(`API error: ${response.status}`)
    }

    const data = await response.json()
    return data.events || []
  } catch (error) {
    console.error('API fetch error:', error)
    return []
  }
}

async function updateEventInDatabase(event: any): Promise<boolean> {
  try {
    const eventData = {
      external_api_id: event.idEvent,
      home_team: event.strHomeTeam,
      away_team: event.strAwayTeam,
      home_team_logo: event.strHomeTeamBadge,
      away_team_logo: event.strAwayTeamBadge,
      home_score: parseInt(event.intHomeScore || '0'),
      away_score: parseInt(event.intAwayScore || '0'),
      status: event.strStatus === 'Match Finished' ? 'finished' : 
              event.strStatus === 'Halftime' ? 'halftime' :
              event.strProgress ? 'live' : 'upcoming',
      period: event.strProgress,
      time_in_period: event.strProgress,
      last_synced_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    }

    const { error } = await supabase
      .from('sport_events')
      .upsert(eventData, { onConflict: 'external_api_id' })

    if (error) {
      console.error('Database update error:', error)
      return false
    }

    return true
  } catch (error) {
    console.error('Event update error:', error)
    return false
  }
}

async function updateLiveMatches(): Promise<SyncResult> {
  const startTime = Date.now()
  let updated = 0
  let errors = 0

  try {
    // Fetch live events from API
    const apiEvents = await fetchLiveEventsFromAPI()

    // Update each event in database
    for (const event of apiEvents) {
      const success = await updateEventInDatabase(event)
      if (success) {
        updated++
      } else {
        errors++
      }
    }

    // Mark events as finished if they're no longer in live feed
    const liveEventIds = apiEvents.map(e => e.idEvent)
    
    if (liveEventIds.length > 0) {
      // Get currently live events from database
      const { data: dbLiveEvents } = await supabase
        .from('sport_events')
        .select('id, external_api_id')
        .eq('status', 'live')

      if (dbLiveEvents) {
        for (const dbEvent of dbLiveEvents) {
          if (!liveEventIds.includes(dbEvent.external_api_id)) {
            // Event is no longer live, mark as finished
            await supabase
              .from('sport_events')
              .update({
                status: 'finished',
                updated_at: new Date().toISOString(),
              })
              .eq('id', dbEvent.id)
          }
        }
      }
    }

  } catch (error) {
    console.error('Sync error:', error)
    errors++
  }

  const duration = Date.now() - startTime

  return { updated, errors, duration }
}

async function cleanExpiredCache(): Promise<number> {
  try {
    const { error, count } = await supabase
      .from('sports_api_cache')
      .delete()
      .lt('expires_at', new Date().toISOString())

    if (error) {
      console.error('Cache cleanup error:', error)
      return 0
    }

    return count || 0
  } catch (error) {
    console.error('Cache cleanup error:', error)
    return 0
  }
}

async function sendMatchNotifications(): Promise<number> {
  let sent = 0

  try {
    // Get matches starting in the next 15 minutes
    const fifteenMinutesFromNow = new Date(Date.now() + 15 * 60 * 1000)
    const fiveMinutesFromNow = new Date(Date.now() + 5 * 60 * 1000)

    const { data: upcomingEvents } = await supabase
      .from('sport_events')
      .select(`
        *,
        league:leagues(name),
        notifications:user_sport_notifications(user_id, notify_on_start)
      `)
      .eq('status', 'upcoming')
      .gte('start_time', fiveMinutesFromNow.toISOString())
      .lte('start_time', fifteenMinutesFromNow.toISOString())

    // This is a placeholder - actual notification sending would require
    // integration with a push notification service (Firebase, OneSignal, etc.)
    console.log(`Found ${upcomingEvents?.length || 0} matches starting soon`)
    
    // TODO: Send push notifications to users who have enabled notifications

  } catch (error) {
    console.error('Notification error:', error)
  }

  return sent
}

serve(async (req) => {
  try {
    const { pathname } = new URL(req.url)

    // Sync live matches
    if (pathname.endsWith('/sync-live')) {
      const result = await updateLiveMatches()
      
      return new Response(
        JSON.stringify({
          status: 'success',
          message: 'Live matches synced',
          ...result,
        }),
        { 
          status: 200,
          headers: { 'Content-Type': 'application/json' }
        }
      )
    }

    // Clean expired cache
    if (pathname.endsWith('/clean-cache')) {
      const cleaned = await cleanExpiredCache()
      
      return new Response(
        JSON.stringify({
          status: 'success',
          message: 'Cache cleaned',
          cleaned,
        }),
        { 
          status: 200,
          headers: { 'Content-Type': 'application/json' }
        }
      )
    }

    // Send notifications
    if (pathname.endsWith('/send-notifications')) {
      const sent = await sendMatchNotifications()
      
      return new Response(
        JSON.stringify({
          status: 'success',
          message: 'Notifications sent',
          sent,
        }),
        { 
          status: 200,
          headers: { 'Content-Type': 'application/json' }
        }
      )
    }

    // Run all tasks (for cron job)
    if (pathname.endsWith('/cron')) {
      const syncResult = await updateLiveMatches()
      const cleaned = await cleanExpiredCache()
      const sent = await sendMatchNotifications()
      
      return new Response(
        JSON.stringify({
          status: 'success',
          message: 'All tasks completed',
          sync: syncResult,
          cacheEntries: cleaned,
          notificationsSent: sent,
        }),
        { 
          status: 200,
          headers: { 'Content-Type': 'application/json' }
        }
      )
    }

    return new Response(
      JSON.stringify({ 
        status: 'error', 
        message: 'Unknown endpoint',
        availableEndpoints: [
          '/sync-live - Sync live matches',
          '/clean-cache - Clean expired cache',
          '/send-notifications - Send match notifications',
          '/cron - Run all tasks (for scheduled cron job)'
        ]
      }),
      { status: 404, headers: { 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Sync function error:', error)
    return new Response(
      JSON.stringify({ 
        status: 'error', 
        message: error.message || 'Internal server error' 
      }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
