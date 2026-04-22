-- Database Functions for Supabase
-- Run these in Supabase Dashboard > SQL Editor AFTER schema.sql

-- Get algorithmic feed
CREATE OR REPLACE FUNCTION get_algorithmic_feed(p_user_id UUID, limit_int INT DEFAULT 20)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  content TEXT,
  media_urls TEXT[],
  media_type TEXT,
  likes_count INT,
  comments_count INT,
  shares_count INT,
  created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.user_id,
    p.content,
    p.media_urls,
    p.media_type,
    p.likes_count,
    p.comments_count,
    p.shares_count,
    p.created_at
  FROM posts p
  WHERE p.is_repost = false
  ORDER BY 
    (COALESCE(p.likes_count, 0) * 1 + COALESCE(p.comments_count, 0) * 2 + COALESCE(p.shares_count, 0) * 3) DESC,
    p.created_at DESC
  LIMIT limit_int;
END;
$$;

-- Get total likes for user
CREATE OR REPLACE FUNCTION get_user_total_likes(p_user_id UUID)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  total_likes INT;
BEGIN
  SELECT COALESCE(SUM(likes_count), 0)::INT
  INTO total_likes
  FROM posts
  WHERE user_id = p_user_id;
  
  RETURN total_likes;
END;
$$;

-- Get total comments for user
CREATE OR REPLACE FUNCTION get_user_total_comments(p_user_id UUID)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  total_comments INT;
BEGIN
  SELECT COALESCE(SUM(comments_count), 0)::INT
  INTO total_comments
  FROM posts
  WHERE user_id = p_user_id;
  
  RETURN total_comments;
END;
$$;

-- Get post region stats
CREATE OR REPLACE FUNCTION get_post_region_stats(p_post_id UUID)
RETURNS TABLE (
  region TEXT,
  views INT,
  unique_viewers INT
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    pa.region,
    COALESCE(SUM(pa.views), 0)::INT,
    COALESCE(SUM(pa.unique_viewers), 0)::INT
  FROM post_analytics pa
  WHERE pa.post_id = p_post_id
  GROUP BY pa.region;
END;
$$;