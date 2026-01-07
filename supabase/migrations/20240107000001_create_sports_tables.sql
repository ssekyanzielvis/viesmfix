-- Sports Feature Database Migration
-- Creates tables for leagues, sport events, streaming providers, and broadcasting rights

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create enum types
CREATE TYPE sport_type AS ENUM (
  'football', 'netball', 'volleyball', 'racing', 'swimming',
  'basketball', 'tennis', 'cricket', 'rugby', 'hockey'
);

CREATE TYPE event_status AS ENUM (
  'upcoming', 'live', 'halftime', 'finished', 'postponed', 'cancelled'
);

CREATE TYPE provider_type AS ENUM (
  'subscription', 'free_to_air', 'pay_per_view', 'cable'
);

CREATE TYPE streaming_type AS ENUM (
  'live', 'replay', 'highlights'
);

-- =====================================================
-- LEAGUES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.leagues (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  sport_type sport_type NOT NULL,
  logo TEXT,
  country TEXT,
  region TEXT,
  external_api_id TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_leagues_sport_type ON public.leagues(sport_type);
CREATE INDEX idx_leagues_country ON public.leagues(country);
CREATE INDEX idx_leagues_external_api_id ON public.leagues(external_api_id);

-- =====================================================
-- STREAMING PROVIDERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.streaming_providers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  type provider_type DEFAULT 'subscription',
  logo TEXT,
  app_store_url TEXT,
  play_store_url TEXT,
  web_url TEXT,
  deep_link_scheme TEXT, -- e.g., 'peacocktv://', 'espn://'
  available_regions TEXT[] DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_providers_type ON public.streaming_providers(type);
CREATE INDEX idx_providers_name ON public.streaming_providers(name);

-- =====================================================
-- SPORT EVENTS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.sport_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  external_api_id TEXT UNIQUE,
  home_team TEXT NOT NULL,
  away_team TEXT NOT NULL,
  home_team_logo TEXT,
  away_team_logo TEXT,
  league_id UUID REFERENCES public.leagues(id) ON DELETE CASCADE,
  sport_type sport_type NOT NULL,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  status event_status DEFAULT 'upcoming',
  home_score INTEGER DEFAULT 0,
  away_score INTEGER DEFAULT 0,
  period TEXT, -- e.g., "1st Half", "Q3"
  time_in_period TEXT, -- e.g., "45:00", "10:23"
  venue TEXT,
  region TEXT,
  metadata JSONB DEFAULT '{}', -- For additional flexible data
  last_synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_events_status ON public.sport_events(status);
CREATE INDEX idx_events_sport_type ON public.sport_events(sport_type);
CREATE INDEX idx_events_league_id ON public.sport_events(league_id);
CREATE INDEX idx_events_start_time ON public.sport_events(start_time);
CREATE INDEX idx_events_external_api_id ON public.sport_events(external_api_id);
CREATE INDEX idx_events_live ON public.sport_events(status) WHERE status = 'live';

-- =====================================================
-- BROADCASTING RIGHTS TABLE
-- Maps events to streaming providers (many-to-many)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.broadcasting_rights (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID REFERENCES public.sport_events(id) ON DELETE CASCADE,
  provider_id UUID REFERENCES public.streaming_providers(id) ON DELETE CASCADE,
  deep_link TEXT, -- Specific deep link for this event
  web_link TEXT, -- Web link for this event
  requires_subscription BOOLEAN DEFAULT true,
  subscription_price DECIMAL(10, 2),
  available_regions TEXT[] DEFAULT '{}',
  type streaming_type DEFAULT 'live',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(event_id, provider_id, type)
);

CREATE INDEX idx_broadcasting_event_id ON public.broadcasting_rights(event_id);
CREATE INDEX idx_broadcasting_provider_id ON public.broadcasting_rights(provider_id);
CREATE INDEX idx_broadcasting_regions ON public.broadcasting_rights USING GIN(available_regions);

-- =====================================================
-- USER BOOKMARKS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.user_sport_bookmarks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL, -- Will link to auth.users when auth is implemented
  event_id UUID REFERENCES public.sport_events(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, event_id)
);

CREATE INDEX idx_bookmarks_user_id ON public.user_sport_bookmarks(user_id);
CREATE INDEX idx_bookmarks_event_id ON public.user_sport_bookmarks(event_id);

-- =====================================================
-- USER NOTIFICATIONS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.user_sport_notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  event_id UUID REFERENCES public.sport_events(id) ON DELETE CASCADE,
  notify_on_start BOOLEAN DEFAULT true,
  notify_on_score_update BOOLEAN DEFAULT false,
  notify_on_stream_available BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, event_id)
);

CREATE INDEX idx_notifications_user_id ON public.user_sport_notifications(user_id);
CREATE INDEX idx_notifications_event_id ON public.user_sport_notifications(event_id);

-- =====================================================
-- USER PREFERENCES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.user_sport_preferences (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL,
  favorite_leagues UUID[] DEFAULT '{}',
  favorite_sports sport_type[] DEFAULT '{}',
  region TEXT,
  notify_on_match_start BOOLEAN DEFAULT true,
  notify_on_score_update BOOLEAN DEFAULT false,
  notify_on_free_stream BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_preferences_user_id ON public.user_sport_preferences(user_id);

-- =====================================================
-- API SYNC CACHE TABLE
-- Caches API responses to reduce external API calls
-- =====================================================
CREATE TABLE IF NOT EXISTS public.sports_api_cache (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cache_key TEXT UNIQUE NOT NULL,
  cache_data JSONB NOT NULL,
  sport_type sport_type,
  cache_type TEXT, -- 'live', 'upcoming', 'leagues', etc.
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_api_cache_key ON public.sports_api_cache(cache_key);
CREATE INDEX idx_api_cache_expires ON public.sports_api_cache(expires_at);
CREATE INDEX idx_api_cache_type ON public.sports_api_cache(cache_type);

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Function to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers
CREATE TRIGGER update_leagues_updated_at BEFORE UPDATE ON public.leagues
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_providers_updated_at BEFORE UPDATE ON public.streaming_providers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON public.sport_events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_broadcasting_updated_at BEFORE UPDATE ON public.broadcasting_rights
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_preferences_updated_at BEFORE UPDATE ON public.user_sport_preferences
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to clean up expired cache
CREATE OR REPLACE FUNCTION clean_expired_sports_cache()
RETURNS void AS $$
BEGIN
  DELETE FROM public.sports_api_cache WHERE expires_at < NOW();
END;
$$ LANGUAGE plpgsql;

-- Function to get live matches
CREATE OR REPLACE FUNCTION get_live_matches(
  p_sport_type sport_type DEFAULT NULL,
  p_league_id UUID DEFAULT NULL,
  p_region TEXT DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  home_team TEXT,
  away_team TEXT,
  home_team_logo TEXT,
  away_team_logo TEXT,
  league JSONB,
  sport_type sport_type,
  start_time TIMESTAMP WITH TIME ZONE,
  status event_status,
  score JSONB,
  venue TEXT,
  region TEXT,
  streaming_options JSONB
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    e.id,
    e.home_team,
    e.away_team,
    e.home_team_logo,
    e.away_team_logo,
    jsonb_build_object(
      'id', l.id,
      'name', l.name,
      'sport_type', l.sport_type,
      'logo', l.logo,
      'country', l.country
    ) AS league,
    e.sport_type,
    e.start_time,
    e.status,
    jsonb_build_object(
      'home_score', e.home_score,
      'away_score', e.away_score,
      'period', e.period,
      'time', e.time_in_period
    ) AS score,
    e.venue,
    e.region,
    COALESCE(
      (SELECT jsonb_agg(
        jsonb_build_object(
          'id', br.id,
          'provider', jsonb_build_object(
            'id', sp.id,
            'name', sp.name,
            'logo', sp.logo,
            'type', sp.type,
            'app_store_url', sp.app_store_url,
            'play_store_url', sp.play_store_url,
            'web_url', sp.web_url
          ),
          'deep_link', br.deep_link,
          'web_link', br.web_link,
          'requires_subscription', br.requires_subscription,
          'subscription_price', br.subscription_price,
          'available_regions', br.available_regions,
          'type', br.type
        )
      )
      FROM public.broadcasting_rights br
      JOIN public.streaming_providers sp ON br.provider_id = sp.id
      WHERE br.event_id = e.id
        AND br.is_active = true
        AND sp.is_active = true
        AND (p_region IS NULL OR p_region = ANY(br.available_regions) OR array_length(br.available_regions, 1) IS NULL)
      ),
      '[]'::jsonb
    ) AS streaming_options
  FROM public.sport_events e
  JOIN public.leagues l ON e.league_id = l.id
  WHERE e.status = 'live'
    AND (p_sport_type IS NULL OR e.sport_type = p_sport_type)
    AND (p_league_id IS NULL OR e.league_id = p_league_id)
    AND (p_region IS NULL OR e.region = p_region OR e.region IS NULL)
  ORDER BY e.start_time DESC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SEED DATA - Popular Streaming Providers
-- =====================================================
INSERT INTO public.streaming_providers (id, name, type, logo, app_store_url, play_store_url, web_url, deep_link_scheme, available_regions) VALUES
  (uuid_generate_v4(), 'ESPN+', 'subscription', NULL, 
   'https://apps.apple.com/app/espn/id317469184',
   'https://play.google.com/store/apps/details?id=com.espn.score_center',
   'https://www.espnplus.com', 'espn://', 
   ARRAY['US', 'CA']),
  (uuid_generate_v4(), 'Peacock', 'subscription', NULL,
   'https://apps.apple.com/app/peacock-tv/id1508186374',
   'https://play.google.com/store/apps/details?id=com.peacocktv.peacock',
   'https://www.peacocktv.com', 'peacocktv://',
   ARRAY['US']),
  (uuid_generate_v4(), 'Paramount+', 'subscription', NULL,
   'https://apps.apple.com/app/paramount/id530168168',
   'https://play.google.com/store/apps/details?id=com.cbs.ott',
   'https://www.paramountplus.com', 'paramount://',
   ARRAY['US', 'CA', 'AU']),
  (uuid_generate_v4(), 'DAZN', 'subscription', NULL,
   'https://apps.apple.com/app/dazn/id1129523589',
   'https://play.google.com/store/apps/details?id=com.dazn',
   'https://www.dazn.com', 'dazn://',
   ARRAY['US', 'CA', 'GB', 'DE', 'IT', 'ES', 'JP']),
  (uuid_generate_v4(), 'SuperSport', 'subscription', NULL,
   'https://apps.apple.com/app/dstv-now/id489362702',
   'https://play.google.com/store/apps/details?id=com.dstv.now',
   'https://www.supersport.com', 'dstv://',
   ARRAY['ZA', 'NG', 'KE']),
  (uuid_generate_v4(), 'NBC Sports', 'free_to_air', NULL,
   'https://apps.apple.com/app/nbc-sports/id542511235',
   'https://play.google.com/store/apps/details?id=com.nbcsports.liveextra',
   'https://www.nbcsports.com', 'nbcsports://',
   ARRAY['US']),
  (uuid_generate_v4(), 'fuboTV', 'subscription', NULL,
   'https://apps.apple.com/app/fubotv/id905401434',
   'https://play.google.com/store/apps/details?id=com.fubotv.android',
   'https://www.fubo.tv', 'fubotv://',
   ARRAY['US', 'CA', 'ES'])
ON CONFLICT DO NOTHING;

-- =====================================================
-- VIEWS FOR COMMON QUERIES
-- =====================================================

-- View for upcoming matches with streaming options
CREATE OR REPLACE VIEW upcoming_matches_with_streaming AS
SELECT 
  e.id,
  e.home_team,
  e.away_team,
  e.home_team_logo,
  e.away_team_logo,
  l.name AS league_name,
  l.sport_type,
  e.start_time,
  e.status,
  e.venue,
  e.region,
  COUNT(DISTINCT br.provider_id) AS provider_count,
  array_agg(DISTINCT sp.name) FILTER (WHERE sp.name IS NOT NULL) AS providers
FROM public.sport_events e
JOIN public.leagues l ON e.league_id = l.id
LEFT JOIN public.broadcasting_rights br ON e.id = br.event_id AND br.is_active = true
LEFT JOIN public.streaming_providers sp ON br.provider_id = sp.id AND sp.is_active = true
WHERE e.status IN ('upcoming', 'live')
  AND e.start_time > NOW() - INTERVAL '6 hours' -- Include matches from last 6 hours
GROUP BY e.id, e.home_team, e.away_team, e.home_team_logo, e.away_team_logo, 
         l.name, l.sport_type, e.start_time, e.status, e.venue, e.region
ORDER BY e.start_time ASC;

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- Enable when authentication is implemented
-- =====================================================
-- ALTER TABLE public.user_sport_bookmarks ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.user_sport_notifications ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.user_sport_preferences ENABLE ROW LEVEL SECURITY;

-- CREATE POLICY "Users can view their own bookmarks" ON public.user_sport_bookmarks
--   FOR SELECT USING (auth.uid() = user_id);

-- CREATE POLICY "Users can create their own bookmarks" ON public.user_sport_bookmarks
--   FOR INSERT WITH CHECK (auth.uid() = user_id);

-- CREATE POLICY "Users can delete their own bookmarks" ON public.user_sport_bookmarks
--   FOR DELETE USING (auth.uid() = user_id);

COMMENT ON TABLE public.leagues IS 'Sports leagues and competitions';
COMMENT ON TABLE public.streaming_providers IS 'Streaming service providers';
COMMENT ON TABLE public.sport_events IS 'Live and upcoming sports events';
COMMENT ON TABLE public.broadcasting_rights IS 'Maps events to streaming providers with regional availability';
COMMENT ON TABLE public.user_sport_bookmarks IS 'User bookmarked matches';
COMMENT ON TABLE public.user_sport_notifications IS 'User notification preferences for matches';
COMMENT ON TABLE public.user_sport_preferences IS 'User sports preferences and settings';
COMMENT ON TABLE public.sports_api_cache IS 'Cache for external API responses';
