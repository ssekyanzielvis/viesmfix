// @ts-nocheck
// Supabase Edge Function for NewsAPI.org proxy with caching
// This function acts as a secure proxy between the Flutter app and NewsAPI.org
// to keep the API key hidden from the client and implements server-side caching

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { corsHeaders } from "../_shared/cors.ts"

const NEWS_API_KEY = Deno.env.get('NEWS_API_KEY')
const NEWS_API_BASE_URL = 'https://newsapi.org/v2'
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || ''
const SUPABASE_SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''

// Cache duration in minutes
const CACHE_DURATION_MINUTES = 15

// Initialize Supabase client for caching
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY)

interface CacheEntry {
  data: any
  timestamp: number
  cache_key: string
}

async function getCachedResponse(cacheKey: string): Promise<any | null> {
  try {
    const { data, error } = await supabase
      .from('news_cache')
      .select('data, timestamp')
      .eq('cache_key', cacheKey)
      .single()

    if (error || !data) {
      return null
    }

    // Check if cache is still valid
    const cacheAge = Date.now() - data.timestamp
    const maxAge = CACHE_DURATION_MINUTES * 60 * 1000

    if (cacheAge > maxAge) {
      // Cache expired, delete it
      await supabase.from('news_cache').delete().eq('cache_key', cacheKey)
      return null
    }

    return data.data
  } catch (error) {
    console.error('Cache retrieval error:', error)
    return null
  }
}

async function setCachedResponse(cacheKey: string, responseData: any): Promise<void> {
  try {
    await supabase
      .from('news_cache')
      .upsert({
        cache_key: cacheKey,
        data: responseData,
        timestamp: Date.now(),
      })
  } catch (error) {
    console.error('Cache storage error:', error)
  }
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { pathname } = new URL(req.url)
    const requestBody = await req.json()

    let endpoint = ''
    let params = new URLSearchParams()
    let cacheKey = ''

    // Route to appropriate NewsAPI endpoint
    if (pathname.endsWith('/top-headlines')) {
      endpoint = '/top-headlines'
      
      const category = requestBody.category || 'general'
      const country = requestBody.country || 'us'
      const page = requestBody.page || 1
      const pageSize = requestBody.pageSize || 20

      cacheKey = `headlines_${category}_${country}_${page}_${pageSize}`
      
      if (requestBody.category) {
        params.append('category', requestBody.category)
      }
      if (requestBody.country) {
        params.append('country', country)
      }
      if (requestBody.page) {
        params.append('page', page.toString())
      }
      if (requestBody.pageSize) {
        params.append('pageSize', pageSize.toString())
      }
    } else if (pathname.endsWith('/search')) {
      endpoint = '/everything'
      
      if (!requestBody.q) {
        return new Response(
          JSON.stringify({ status: 'error', message: 'Query parameter is required' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
      
      const query = requestBody.q
      const page = requestBody.page || 1
      const sortBy = requestBody.sortBy || 'publishedAt'

      cacheKey = `search_${query}_${page}_${sortBy}`
      
      params.append('q', query)
      if (requestBody.from) {
        params.append('from', requestBody.from)
        cacheKey += `_${requestBody.from}`
      }
      if (requestBody.to) {
        params.append('to', requestBody.to)
        cacheKey += `_${requestBody.to}`
      }
      if (requestBody.sortBy) {
        params.append('sortBy', sortBy)
      }
      if (requestBody.page) {
        params.append('page', page.toString())
      }
      if (requestBody.pageSize) {
        params.append('pageSize', (requestBody.pageSize || 20).toString())
      }
    } else if (pathname.endsWith('/sources')) {
      endpoint = '/top-headlines/sources'
      
      const category = requestBody.category || 'all'
      cacheKey = `sources_${category}`
      
      if (requestBody.category) {
        params.append('category', requestBody.category)
      }
      if (requestBody.language) {
        params.append('language', requestBody.language)
      }
      if (requestBody.country) {
        params.append('country', requestBody.country)
      }
    } else if (pathname.endsWith('/clear-cache')) {
      // Clear all cache entries older than cache duration
      const cutoffTime = Date.now() - (CACHE_DURATION_MINUTES * 60 * 1000)
      await supabase.from('news_cache').delete().lt('timestamp', cutoffTime)
      
      return new Response(
        JSON.stringify({ status: 'ok', message: 'Cache cleared successfully' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    } else {
      return new Response(
        JSON.stringify({ status: 'error', message: 'Invalid endpoint' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Try to get cached response
    const cachedData = await getCachedResponse(cacheKey)
    if (cachedData) {
      console.log(`Cache hit for key: ${cacheKey}`)
      return new Response(
        JSON.stringify(cachedData),
        { 
          status: 200,
          headers: { 
            ...corsHeaders, 
            'Content-Type': 'application/json',
            'X-Cache': 'HIT'
          } 
        }
      )
    }

    console.log(`Cache miss for key: ${cacheKey}`)

    // Make request to NewsAPI
    const newsApiUrl = `${NEWS_API_BASE_URL}${endpoint}?${params.toString()}`
    const response = await fetch(newsApiUrl, {
      headers: {
        'X-Api-Key': NEWS_API_KEY || '',
      },
    })

    const data = await response.json()

    // Cache successful responses
    if (response.status === 200 && data.status === 'ok') {
      await setCachedResponse(cacheKey, data)
    }

    // Return the response
    return new Response(
      JSON.stringify(data),
      { 
        status: response.status,
        headers: { 
          ...corsHeaders, 
          'Content-Type': 'application/json',
          'X-Cache': 'MISS'
        } 
      }
    )
  } catch (error) {
    console.error('Edge Function error:', error)
    return new Response(
      JSON.stringify({ 
        status: 'error', 
        message: error.message || 'Internal server error',
        code: 'EDGE_FUNCTION_ERROR'
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})
