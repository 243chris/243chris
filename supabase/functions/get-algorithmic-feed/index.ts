import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const url = new URL(req.url)
    const userId = url.searchParams.get('user_id')
    const limit = parseInt(url.searchParams.get('limit') || '20')
    const offset = parseInt(url.searchParams.get('offset') || '0')
    
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!
    )
    
    // Get user's followings
    let followingIds: string[] = []
    if (userId) {
      const { data: follows } = await supabase
        .from('followers')
        .select('following_id')
        .eq('follower_id', userId)
      
      followingIds = follows?.map(f => f.following_id) || []
    }
    
    // Get posts from followed users + popular posts
    let query = supabase
      .from('posts')
      .select('*, profiles(*)')
      .order('created_at', ascending: false)
      .limit(limit)
      .offset(offset)
    
    if (userId) {
      // Include posts from followed users first, then popular
      query = query.or(`user_id.in.(${followingIds.join(',')}),shares_count.gt.10`)
    }
    
    const { data: posts, error } = await query
    
    if (error) throw error
    
    // Reorder by engagement score
    const scoredPosts = posts?.map(post => {
      const engagement = (post.likes_count || 0) * 1 + 
                      (post.comments_count || 0) * 2 + 
                      (post.shares_count || 0) * 3
      return { ...post, engagement_score: engagement }
    }) || []
    
    scoredPosts.sort((a, b) => b.engagement_score - a.engagement_score)
    
    return new Response(JSON.stringify(scoredPosts))
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500 })
  }
})