# Supabase Setup Guide

## Prerequisites

1. Create a Supabase account at [supabase.com](https://supabase.com)
2. Create a new project
3. Note down your project URL and anon key

## Database Setup

1. Navigate to the SQL Editor in your Supabase dashboard
2. Copy and paste the contents of `schema.sql`
3. Run the SQL script to create all tables, indexes, and policies

## Environment Configuration

Add the following to your `.env` file or use `--dart-define`:

```
SUPABASE_URL=your_project_url
SUPABASE_ANON_KEY=your_anon_key
```

Update `lib/src/core/constants/environment.dart`:

```dart
static const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'your_project_url',
);

static const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'your_anon_key',
);
```

## Authentication Setup

### Email Authentication

1. In Supabase dashboard, go to Authentication > Settings
2. Enable Email provider
3. Configure email templates (optional)

### OAuth Providers (Optional)

To enable social login:

1. Go to Authentication > Providers
2. Enable desired providers (Google, Apple, GitHub, etc.)
3. Add OAuth credentials for each provider
4. Configure redirect URLs:
   - For mobile: `app://login-callback`
   - For web: `https://yourdomain.com/auth/callback`

## Storage Setup (For Profile Pictures)

1. Go to Storage in Supabase dashboard
2. Create a bucket named `avatars`
3. Set bucket to public
4. Add policy for authenticated users to upload:

```sql
CREATE POLICY "Users can upload own avatar"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);
```

## Real-time Setup

Real-time is enabled by default for tables with RLS policies. To test:

1. Go to Database > Replication
2. Ensure replication is enabled for your tables
3. Test with a simple watchlist add/remove action

## Testing the Setup

Run this SQL query to verify everything is set up correctly:

```sql
-- Check if all tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE';

-- Check if RLS is enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';

-- Check policies
SELECT tablename, policyname 
FROM pg_policies 
WHERE schemaname = 'public';
```

## Next Steps

1. Initialize Supabase in your app (see `main.dart`)
2. Test authentication flow
3. Test watchlist operations
4. Monitor real-time subscriptions in Supabase dashboard

## Troubleshooting

### Connection Issues

- Verify your Supabase URL and anon key are correct
- Check if your project is paused (free tier auto-pauses after inactivity)

### RLS Policy Issues

- Use the Supabase dashboard's RLS helper to test policies
- Check auth.uid() is correctly set in your requests

### Real-time Not Working

- Ensure replication is enabled for the table
- Check WebSocket connection in browser dev tools (web)
- Verify channel subscriptions are active
