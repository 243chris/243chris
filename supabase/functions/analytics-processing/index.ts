import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface RegionStats {
  region: string
  views: number
  unique_viewers: number
}

serve(async () => {
  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )
    
    // Get all posts
    const { data: posts } = await supabase.from('posts').select('id')
    
    if (!posts || posts.length === 0) {
      return new Response(JSON.stringify({ message: 'No posts to process' }))
    }
    
    let processedCount = 0
    
    for (const post of posts) {
      // Get post analytics (simulated - in production would use view_logs table)
      const { data: existingAnalytics } = await supabase
        .from('post_analytics')
        .select('region, views, unique_viewers')
        .eq('post_id', post.id)
        .eq('date', new Date().toISOString().split('T')[0])
      
      if (existingAnalytics && existingAnalytics.length > 0) {
        // Aggregate by region
        const regionMap = new Map<string, RegionStats>()
        
        for (const analytics of existingAnalytics) {
          const region = analytics.region || 'unknown'
          if (!regionMap.has(region)) {
            regionMap.set(region, { region, views: 0, unique_viewers: 0 })
          }
          const stat = regionMap.get(region)!
          stat.views += analytics.views || 0
          stat.unique_viewers += analytics.unique_viewers || 0
        }
        
        // Upsert aggregated data
        for (const stat of regionMap.values()) {
          await supabase.from('post_analytics').upsert({
            post_id: post.id,
            region: stat.region,
            views: stat.views,
            unique_viewers: stat.unique_viewers,
            date: new Date().toISOString().split('T')[0],
          })
        }
        processedCount++
      }
    }
    
    return new Response(JSON.stringify({ 
      message: 'Analytics processed',
      postsProcessed: processedCount 
    }))
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500 })
  }
})