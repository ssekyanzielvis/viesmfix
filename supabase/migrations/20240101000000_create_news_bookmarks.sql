-- =====================================================
-- News Bookmarks Database Schema
-- =====================================================
-- Optional: Use this for server-side bookmark storage
-- Alternative: Local storage with SharedPreferences
-- =====================================================

-- Create news_bookmarks table
CREATE TABLE IF NOT EXISTS news_bookmarks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  article_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  url TEXT NOT NULL,
  image_url TEXT,
  source_name TEXT NOT NULL,
  source_id TEXT,
  author TEXT,
  published_at TIMESTAMP WITH TIME ZONE NOT NULL,
  bookmarked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  category TEXT,
  
  -- Constraints
  CONSTRAINT unique_user_article UNIQUE(user_id, article_id),
  CONSTRAINT valid_url CHECK (url ~ '^https?://'),
  CONSTRAINT valid_article_id CHECK (length(article_id) > 0)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_news_bookmarks_user_id 
  ON news_bookmarks(user_id);

CREATE INDEX IF NOT EXISTS idx_news_bookmarks_bookmarked_at 
  ON news_bookmarks(bookmarked_at DESC);

CREATE INDEX IF NOT EXISTS idx_news_bookmarks_user_bookmarked 
  ON news_bookmarks(user_id, bookmarked_at DESC);

CREATE INDEX IF NOT EXISTS idx_news_bookmarks_category 
  ON news_bookmarks(category) 
  WHERE category IS NOT NULL;

-- Enable Row Level Security
ALTER TABLE news_bookmarks ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own bookmarks" ON news_bookmarks;
DROP POLICY IF EXISTS "Users can create own bookmarks" ON news_bookmarks;
DROP POLICY IF EXISTS "Users can delete own bookmarks" ON news_bookmarks;
DROP POLICY IF EXISTS "Users can update own bookmarks" ON news_bookmarks;

-- RLS Policy: Users can only see their own bookmarks
CREATE POLICY "Users can view own bookmarks"
  ON news_bookmarks
  FOR SELECT
  USING (auth.uid() = user_id);

-- RLS Policy: Users can create their own bookmarks
CREATE POLICY "Users can create own bookmarks"
  ON news_bookmarks
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can delete their own bookmarks
CREATE POLICY "Users can delete own bookmarks"
  ON news_bookmarks
  FOR DELETE
  USING (auth.uid() = user_id);

-- RLS Policy: Users can update their own bookmarks (optional)
CREATE POLICY "Users can update own bookmarks"
  ON news_bookmarks
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- =====================================================
-- Helper Functions
-- =====================================================

-- Function to get bookmark count per user
CREATE OR REPLACE FUNCTION get_user_bookmark_count(user_uuid UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  bookmark_count INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO bookmark_count
  FROM news_bookmarks
  WHERE user_id = user_uuid;
  
  RETURN bookmark_count;
END;
$$;

-- Function to get bookmarks by category
CREATE OR REPLACE FUNCTION get_bookmarks_by_category(user_uuid UUID, category_name TEXT)
RETURNS TABLE (
  id UUID,
  article_id TEXT,
  title TEXT,
  description TEXT,
  url TEXT,
  image_url TEXT,
  source_name TEXT,
  published_at TIMESTAMP WITH TIME ZONE,
  bookmarked_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    nb.id,
    nb.article_id,
    nb.title,
    nb.description,
    nb.url,
    nb.image_url,
    nb.source_name,
    nb.published_at,
    nb.bookmarked_at
  FROM news_bookmarks nb
  WHERE nb.user_id = user_uuid
    AND nb.category = category_name
  ORDER BY nb.bookmarked_at DESC;
END;
$$;

-- Function to clean old bookmarks (run periodically)
CREATE OR REPLACE FUNCTION clean_old_bookmarks(days_to_keep INTEGER DEFAULT 90)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM news_bookmarks
  WHERE bookmarked_at < NOW() - INTERVAL '1 day' * days_to_keep;
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$;

-- =====================================================
-- Views
-- =====================================================

-- View: Recent bookmarks across all users (for admin)
CREATE OR REPLACE VIEW recent_bookmarks AS
SELECT 
  nb.id,
  nb.user_id,
  nb.article_id,
  nb.title,
  nb.source_name,
  nb.category,
  nb.bookmarked_at
FROM news_bookmarks nb
ORDER BY nb.bookmarked_at DESC
LIMIT 100;

-- View: Popular bookmarked articles
CREATE OR REPLACE VIEW popular_bookmarked_articles AS
SELECT 
  article_id,
  title,
  source_name,
  url,
  image_url,
  category,
  COUNT(*) as bookmark_count,
  MAX(bookmarked_at) as last_bookmarked
FROM news_bookmarks
GROUP BY article_id, title, source_name, url, image_url, category
HAVING COUNT(*) > 1
ORDER BY bookmark_count DESC, last_bookmarked DESC
LIMIT 50;

-- =====================================================
-- Triggers
-- =====================================================

-- Trigger: Update timestamp on bookmark update
CREATE OR REPLACE FUNCTION update_bookmark_timestamp()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.bookmarked_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER set_bookmark_timestamp
  BEFORE UPDATE ON news_bookmarks
  FOR EACH ROW
  EXECUTE FUNCTION update_bookmark_timestamp();

-- =====================================================
-- Sample Data (for testing only - remove in production)
-- =====================================================

-- Uncomment to insert sample data
/*
INSERT INTO news_bookmarks (user_id, article_id, title, description, url, source_name, published_at, category)
VALUES 
  (auth.uid(), 'sample-1', 'Sample Tech Article', 'Description here', 'https://example.com/1', 'TechNews', NOW() - INTERVAL '1 day', 'technology'),
  (auth.uid(), 'sample-2', 'Sample Sports Article', 'Description here', 'https://example.com/2', 'SportNews', NOW() - INTERVAL '2 days', 'sports'),
  (auth.uid(), 'sample-3', 'Sample Business Article', 'Description here', 'https://example.com/3', 'BizNews', NOW() - INTERVAL '3 days', 'business');
*/

-- =====================================================
-- Cleanup (optional - removes all policies and table)
-- =====================================================

-- Uncomment to completely remove news bookmarks
/*
DROP POLICY IF EXISTS "Users can view own bookmarks" ON news_bookmarks;
DROP POLICY IF EXISTS "Users can create own bookmarks" ON news_bookmarks;
DROP POLICY IF EXISTS "Users can delete own bookmarks" ON news_bookmarks;
DROP POLICY IF EXISTS "Users can update own bookmarks" ON news_bookmarks;
DROP TRIGGER IF EXISTS set_bookmark_timestamp ON news_bookmarks;
DROP FUNCTION IF EXISTS update_bookmark_timestamp();
DROP FUNCTION IF EXISTS get_user_bookmark_count(UUID);
DROP FUNCTION IF EXISTS get_bookmarks_by_category(UUID, TEXT);
DROP FUNCTION IF EXISTS clean_old_bookmarks(INTEGER);
DROP VIEW IF EXISTS recent_bookmarks;
DROP VIEW IF EXISTS popular_bookmarked_articles;
DROP TABLE IF EXISTS news_bookmarks CASCADE;
*/

-- =====================================================
-- Verification Queries
-- =====================================================

-- Verify table was created
-- SELECT * FROM news_bookmarks LIMIT 1;

-- Check policies
-- SELECT * FROM pg_policies WHERE tablename = 'news_bookmarks';

-- Check indexes
-- SELECT * FROM pg_indexes WHERE tablename = 'news_bookmarks';

-- Test bookmark count function
-- SELECT get_user_bookmark_count(auth.uid());

-- View popular articles
-- SELECT * FROM popular_bookmarked_articles;
