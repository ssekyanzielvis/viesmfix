-- =====================================================
-- News Cache Table for Server-Side Caching
-- =====================================================
-- This table stores cached NewsAPI responses in the Edge Function
-- to reduce API calls and improve performance
-- =====================================================

-- Create news_cache table
CREATE TABLE IF NOT EXISTS news_cache (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  cache_key TEXT NOT NULL UNIQUE,
  data JSONB NOT NULL,
  timestamp BIGINT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  
  -- Constraints
  CONSTRAINT valid_cache_key CHECK (length(cache_key) > 0),
  CONSTRAINT valid_timestamp CHECK (timestamp > 0)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_news_cache_key 
  ON news_cache(cache_key);

CREATE INDEX IF NOT EXISTS idx_news_cache_timestamp 
  ON news_cache(timestamp DESC);

CREATE INDEX IF NOT EXISTS idx_news_cache_created_at 
  ON news_cache(created_at DESC);

-- Enable Row Level Security (optional - if you want client access)
ALTER TABLE news_cache ENABLE ROW LEVEL SECURITY;

-- Policy: Allow service role full access (for Edge Functions)
CREATE POLICY "Service role has full access to cache"
  ON news_cache
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- =====================================================
-- Automatic Cache Cleanup Function
-- =====================================================

-- Function to automatically clean old cache entries
CREATE OR REPLACE FUNCTION cleanup_old_news_cache()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  deleted_count INTEGER;
  cutoff_timestamp BIGINT;
BEGIN
  -- Calculate cutoff (24 hours ago in milliseconds)
  cutoff_timestamp := EXTRACT(EPOCH FROM NOW() - INTERVAL '24 hours')::BIGINT * 1000;
  
  -- Delete old cache entries
  DELETE FROM news_cache
  WHERE timestamp < cutoff_timestamp;
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  
  RETURN deleted_count;
END;
$$;

-- =====================================================
-- Scheduled Cache Cleanup (requires pg_cron extension)
-- =====================================================

-- Enable pg_cron extension if not already enabled
-- CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule cleanup to run every hour
-- SELECT cron.schedule(
--   'cleanup-news-cache',
--   '0 * * * *',  -- Every hour at minute 0
--   $$SELECT cleanup_old_news_cache();$$
-- );

-- =====================================================
-- Helper Functions
-- =====================================================

-- Function to get cache statistics
CREATE OR REPLACE FUNCTION get_news_cache_stats()
RETURNS TABLE (
  total_entries BIGINT,
  total_size_mb NUMERIC,
  oldest_entry TIMESTAMP WITH TIME ZONE,
  newest_entry TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*)::BIGINT as total_entries,
    ROUND(pg_total_relation_size('news_cache')::NUMERIC / 1024 / 1024, 2) as total_size_mb,
    MIN(created_at) as oldest_entry,
    MAX(created_at) as newest_entry
  FROM news_cache;
END;
$$;

-- Function to clear cache by pattern
CREATE OR REPLACE FUNCTION clear_news_cache_by_pattern(pattern TEXT)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM news_cache
  WHERE cache_key LIKE pattern;
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  
  RETURN deleted_count;
END;
$$;

-- Function to get cache entry by key
CREATE OR REPLACE FUNCTION get_cache_entry(key TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  cache_data JSONB;
BEGIN
  SELECT data INTO cache_data
  FROM news_cache
  WHERE cache_key = key;
  
  RETURN cache_data;
END;
$$;

-- =====================================================
-- Views for Monitoring
-- =====================================================

-- View: Cache entries by age
CREATE OR REPLACE VIEW cache_entries_by_age AS
SELECT 
  cache_key,
  ROUND((EXTRACT(EPOCH FROM NOW())::BIGINT * 1000 - timestamp)::NUMERIC / 1000 / 60, 2) as age_minutes,
  created_at,
  pg_size_pretty(pg_column_size(data)) as data_size
FROM news_cache
ORDER BY age_minutes ASC;

-- View: Cache hit analysis (would need actual hit tracking)
CREATE OR REPLACE VIEW cache_key_distribution AS
SELECT 
  SPLIT_PART(cache_key, '_', 1) as cache_type,
  COUNT(*) as entry_count,
  pg_size_pretty(SUM(pg_column_size(data))::BIGINT) as total_size
FROM news_cache
GROUP BY cache_type
ORDER BY entry_count DESC;

-- =====================================================
-- Sample Data (for testing only - remove in production)
-- =====================================================

-- Uncomment to insert sample cache entry
/*
INSERT INTO news_cache (cache_key, data, timestamp)
VALUES (
  'test_headlines_technology_us_1_20',
  '{"status": "ok", "articles": []}'::JSONB,
  EXTRACT(EPOCH FROM NOW())::BIGINT * 1000
);
*/

-- =====================================================
-- Verification Queries
-- =====================================================

-- Get cache statistics
-- SELECT * FROM get_news_cache_stats();

-- View all cache entries
-- SELECT * FROM news_cache ORDER BY created_at DESC;

-- View cache distribution
-- SELECT * FROM cache_key_distribution;

-- View cache by age
-- SELECT * FROM cache_entries_by_age;

-- Clear old cache manually
-- SELECT cleanup_old_news_cache();

-- Clear specific category cache
-- SELECT clear_news_cache_by_pattern('headlines_technology%');

-- Get specific cache entry
-- SELECT get_cache_entry('headlines_technology_us_1_20');

-- =====================================================
-- Performance Optimization
-- =====================================================

-- Analyze table for query optimization
ANALYZE news_cache;

-- Set table storage parameters for better performance
ALTER TABLE news_cache SET (
  autovacuum_vacuum_scale_factor = 0.1,
  autovacuum_analyze_scale_factor = 0.05
);

-- =====================================================
-- Cleanup (optional - removes all cache infrastructure)
-- =====================================================

-- Uncomment to completely remove news cache
/*
DROP VIEW IF EXISTS cache_entries_by_age;
DROP VIEW IF EXISTS cache_key_distribution;
DROP FUNCTION IF EXISTS cleanup_old_news_cache();
DROP FUNCTION IF EXISTS get_news_cache_stats();
DROP FUNCTION IF EXISTS clear_news_cache_by_pattern(TEXT);
DROP FUNCTION IF EXISTS get_cache_entry(TEXT);
DROP POLICY IF EXISTS "Service role has full access to cache" ON news_cache;
DROP TABLE IF EXISTS news_cache CASCADE;
*/
