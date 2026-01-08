-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles table (extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE NOT NULL,
  avatar_url TEXT,
  bio TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Movies table (cached from TMDB)
CREATE TABLE IF NOT EXISTS movies (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  overview TEXT,
  poster_path TEXT,
  backdrop_path TEXT,
  release_date DATE,
  vote_average DECIMAL(3,1),
  vote_count INTEGER,
  popularity DECIMAL(10,3),
  genres JSONB,
  runtime INTEGER,
  cached_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Watchlist items
CREATE TABLE IF NOT EXISTS watchlist_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  movie_id INTEGER NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, movie_id)
);

-- User ratings
CREATE TABLE IF NOT EXISTS ratings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  movie_id INTEGER NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
  rating DECIMAL(2,1) NOT NULL CHECK (rating >= 0 AND rating <= 10),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, movie_id)
);

-- User reviews
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  movie_id INTEGER NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  likes_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Review likes
CREATE TABLE IF NOT EXISTS review_likes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, review_id)
);

-- Friendships
CREATE TABLE IF NOT EXISTS friendships (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  friend_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status TEXT NOT NULL CHECK (status IN ('pending', 'accepted', 'blocked')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, friend_id),
  CHECK (user_id != friend_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_watchlist_user_id ON watchlist_items(user_id);
CREATE INDEX IF NOT EXISTS idx_watchlist_movie_id ON watchlist_items(movie_id);
CREATE INDEX IF NOT EXISTS idx_ratings_user_id ON ratings(user_id);
CREATE INDEX IF NOT EXISTS idx_ratings_movie_id ON ratings(movie_id);
CREATE INDEX IF NOT EXISTS idx_reviews_movie_id ON reviews(movie_id);
CREATE INDEX IF NOT EXISTS idx_friendships_user_id ON friendships(user_id);
CREATE INDEX IF NOT EXISTS idx_friendships_friend_id ON friendships(friend_id);

-- Row Level Security (RLS) Policies

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE watchlist_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE friendships ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Public profiles are viewable by everyone"
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Watchlist policies
CREATE POLICY "Users can view own watchlist"
  ON watchlist_items FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert into own watchlist"
  ON watchlist_items FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete from own watchlist"
  ON watchlist_items FOR DELETE
  USING (auth.uid() = user_id);

-- Ratings policies
CREATE POLICY "Ratings are viewable by everyone"
  ON ratings FOR SELECT
  USING (true);

CREATE POLICY "Users can insert own ratings"
  ON ratings FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own ratings"
  ON ratings FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own ratings"
  ON ratings FOR DELETE
  USING (auth.uid() = user_id);

-- Reviews policies
CREATE POLICY "Reviews are viewable by everyone"
  ON reviews FOR SELECT
  USING (true);

CREATE POLICY "Users can insert own reviews"
  ON reviews FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reviews"
  ON reviews FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own reviews"
  ON reviews FOR DELETE
  USING (auth.uid() = user_id);

-- Review likes policies
CREATE POLICY "Review likes are viewable by everyone"
  ON review_likes FOR SELECT
  USING (true);

CREATE POLICY "Users can like reviews"
  ON review_likes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unlike reviews"
  ON review_likes FOR DELETE
  USING (auth.uid() = user_id);

-- Friendships policies
CREATE POLICY "Users can view own friendships"
  ON friendships FOR SELECT
  USING (auth.uid() = user_id OR auth.uid() = friend_id);

CREATE POLICY "Users can create friendship requests"
  ON friendships FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update friendship status"
  ON friendships FOR UPDATE
  USING (auth.uid() = friend_id);

CREATE POLICY "Users can delete friendships"
  ON friendships FOR DELETE
  USING (auth.uid() = user_id OR auth.uid() = friend_id);

-- Functions

-- Function to get average rating for a movie
CREATE OR REPLACE FUNCTION get_average_rating(movie_id_param INTEGER)
RETURNS DECIMAL AS $$
BEGIN
  RETURN (
    SELECT COALESCE(AVG(rating), 0)
    FROM ratings
    WHERE movie_id = movie_id_param
  );
END;
$$ LANGUAGE plpgsql;

-- Function to update review likes count
CREATE OR REPLACE FUNCTION update_review_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE reviews
    SET likes_count = likes_count + 1
    WHERE id = NEW.review_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE reviews
    SET likes_count = likes_count - 1
    WHERE id = OLD.review_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update review likes count
CREATE TRIGGER review_likes_count_trigger
  AFTER INSERT OR DELETE ON review_likes
  FOR EACH ROW
  EXECUTE FUNCTION update_review_likes_count();

-- Function to create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', 'user_' || substring(NEW.id::text from 1 for 8)),
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on user signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Storage Buckets
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'avatars') THEN
    INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'review-images') THEN
    INSERT INTO storage.buckets (id, name, public) VALUES ('review-images', 'review-images', true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'posters') THEN
    INSERT INTO storage.buckets (id, name, public) VALUES ('posters', 'posters', true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'backdrops') THEN
    INSERT INTO storage.buckets (id, name, public) VALUES ('backdrops', 'backdrops', true);
  END IF;

  -- Optional: set mime types and size limits if columns exist
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='storage' AND table_name='buckets' AND column_name='allowed_mime_types'
  ) THEN
    UPDATE storage.buckets
      SET allowed_mime_types = ARRAY['image/png','image/jpeg','image/webp','image/gif']
      WHERE id IN ('avatars','review-images');
    UPDATE storage.buckets
      SET allowed_mime_types = ARRAY['image/png','image/jpeg','image/webp']
      WHERE id IN ('posters','backdrops');
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='storage' AND table_name='buckets' AND column_name='file_size_limit'
  ) THEN
    UPDATE storage.buckets SET file_size_limit = (5*1024*1024)::bigint WHERE id = 'avatars';
    UPDATE storage.buckets SET file_size_limit = (10*1024*1024)::bigint WHERE id IN ('review-images','posters');
    UPDATE storage.buckets SET file_size_limit = (15*1024*1024)::bigint WHERE id = 'backdrops';
  END IF;
END$$;

-- Storage RLS policies
-- Public read for buckets; authenticated users manage only their own objects

-- Public read
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Public read avatars'
  ) THEN
    CREATE POLICY "Public read avatars" ON storage.objects
    FOR SELECT USING (bucket_id = 'avatars');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Public read review-images'
  ) THEN
    CREATE POLICY "Public read review-images" ON storage.objects
    FOR SELECT USING (bucket_id = 'review-images');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Public read posters'
  ) THEN
    CREATE POLICY "Public read posters" ON storage.objects
    FOR SELECT USING (bucket_id = 'posters');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Public read backdrops'
  ) THEN
    CREATE POLICY "Public read backdrops" ON storage.objects
    FOR SELECT USING (bucket_id = 'backdrops');
  END IF;
END$$;

-- Authenticated write/update/delete own objects by owner or path prefix {auth.uid()}/
DO $$
BEGIN
  -- avatars
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Own avatars insert'
  ) THEN
    CREATE POLICY "Own avatars insert" ON storage.objects
    FOR INSERT TO authenticated
    WITH CHECK (
      bucket_id = 'avatars' AND (owner = auth.uid() OR split_part(name, '/', 1) = auth.uid()::text)
    );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Own avatars update'
  ) THEN
    CREATE POLICY "Own avatars update" ON storage.objects
    FOR UPDATE TO authenticated
    USING (
      bucket_id = 'avatars' AND (owner = auth.uid() OR split_part(name, '/', 1) = auth.uid()::text)
    )
    WITH CHECK (
      bucket_id = 'avatars' AND (owner = auth.uid() OR split_part(name, '/', 1) = auth.uid()::text)
    );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Own avatars delete'
  ) THEN
    CREATE POLICY "Own avatars delete" ON storage.objects
    FOR DELETE TO authenticated
    USING (
      bucket_id = 'avatars' AND (owner = auth.uid() OR split_part(name, '/', 1) = auth.uid()::text)
    );
  END IF;

  -- review-images
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Own review-images insert'
  ) THEN
    CREATE POLICY "Own review-images insert" ON storage.objects
    FOR INSERT TO authenticated
    WITH CHECK (
      bucket_id = 'review-images' AND (owner = auth.uid() OR split_part(name, '/', 1) = auth.uid()::text)
    );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Own review-images update'
  ) THEN
    CREATE POLICY "Own review-images update" ON storage.objects
    FOR UPDATE TO authenticated
    USING (
      bucket_id = 'review-images' AND (owner = auth.uid() OR split_part(name, '/', 1) = auth.uid()::text)
    )
    WITH CHECK (
      bucket_id = 'review-images' AND (owner = auth.uid() OR split_part(name, '/', 1) = auth.uid()::text)
    );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Own review-images delete'
  ) THEN
    CREATE POLICY "Own review-images delete" ON storage.objects
    FOR DELETE TO authenticated
    USING (
      bucket_id = 'review-images' AND (owner = auth.uid() OR split_part(name, '/', 1) = auth.uid()::text)
    );
  END IF;

  -- posters
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Own posters insert'
  ) THEN
    CREATE POLICY "Own posters insert" ON storage.objects
    FOR INSERT TO authenticated
    WITH CHECK (
      bucket_id = 'posters' AND (owner = auth.uid() OR split_part(name, '/', 1) = auth.uid()::text)
    );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Own posters update'
  ) THEN
    CREATE POLICY "Own posters update" ON storage.objects
    FOR UPDATE TO authenticated
    USING (
      bucket_id = 'posters' AND (owner = auth.uid() OR split_part(name, '/', 1) = auth.uid()::text)
    )
    WITH CHECK (
      bucket_id = 'posters' AND (owner = auth.uid() OR split_part(name, '/', 1) = auth.uid()::text)
    );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Own posters delete'
  ) THEN
    CREATE POLICY "Own posters delete" ON storage.objects
    FOR DELETE TO authenticated
    USING (
      bucket_id = 'posters' AND (owner = auth.uid() OR split_part(name, '/', 1) = auth.uid()::text)
    );
  END IF;

  -- backdrops
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Own backdrops insert'
  ) THEN
    CREATE POLICY "Own backdrops insert" ON storage.objects
    FOR INSERT TO authenticated
    WITH CHECK (
      bucket_id = 'backdrops' AND (owner = auth.uid() OR split_part(name, '/', 1) = auth.uid()::text)
    );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Own backdrops update'
  ) THEN
    CREATE POLICY "Own backdrops update" ON storage.objects
    FOR UPDATE TO authenticated
    USING (
      bucket_id = 'backdrops' AND (owner = auth.uid() OR split_part(name, '/', 1) = auth.uid()::text)
    )
    WITH CHECK (
      bucket_id = 'backdrops' AND (owner = auth.uid() OR split_part(name, '/', 1) = auth.uid()::text)
    );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Own backdrops delete'
  ) THEN
    CREATE POLICY "Own backdrops delete" ON storage.objects
    FOR DELETE TO authenticated
    USING (
      bucket_id = 'backdrops' AND (owner = auth.uid() OR split_part(name, '/', 1) = auth.uid()::text)
    );
  END IF;
END$$;

-- Recommended upload paths:
-- avatars:        avatars/{auth.uid()}/profile.png
-- review-images:  review-images/{auth.uid()}/<uuid>.png
-- posters:        posters/<tmdb_id>.jpg
-- backdrops:      backdrops/<tmdb_id>.jpg
