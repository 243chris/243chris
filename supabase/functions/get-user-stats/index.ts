import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const url = new URL(req.url)
    const userId = url.searchParams.get('user_id')
    
    if (!userId) {
      return new Response(JSON.stringify({ error: 'user_id required' }), { status: 400 })
    }
    
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )
    
    // Get posts count
    const { count: postsCount } = await supabase
      .from('posts')
      .select('id', { count: 'exact', head: true })
      .eq('user_id', userId)
    
    // Get total likes on user's posts
    const { data: posts } = await supabase
      .from('posts')
      .select('likes_count, comments_count, shares_count')
      .eq('user_id', userId)
    
    let totalLikes = 0
    let totalComments = 0
    let totalShares = 0
    
    posts?.forEach(post => {
      totalLikes += post.likes_count || 0
      totalComments += post.comments_count || 0
      totalShares += post.shares_count || 0
    })
    
    // Get followers count
    const { count: followersCount } = await supabase
      .from('followers')
      .select('id', { count: 'exact', head: true })
      .eq('following_id', userId)
    
    // Get following count
    const { count: followingCount } = await supabase
      .from('followers')
      .select('id', { count: 'exact', head: true })
      .eq('follower_id', userId)
    
    return new Response(JSON.stringify({
      posts: postsCount || 0,
      likes: totalLikes,
      comments: totalComments,
      shares: totalShares,
      followers: followersCount || 0,
      following: followingCount || 0,
    }))
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500 })
  }
})