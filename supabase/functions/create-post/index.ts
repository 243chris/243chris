import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const { content, mediaUrls, mediaType } = await req.json()
    const authHeader = req.headers.get('Authorization')!
    
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } }
    )
    
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 })
    }
    
    // Moderation check with OpenAI
    if (content) {
      const moderation = await fetch('https://api.openai.com/v1/moderations', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${Deno.env.get('OPENAI_API_KEY')}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ input: content }),
      })
      const moderationData = await moderation.json()
      if (moderationData.results[0].flagged) {
        return new Response(JSON.stringify({ error: 'Contenu inapproprié' }), { status: 400 })
      }
    }
    
    const { data: post, error } = await supabase
      .from('posts')
      .insert({
        user_id: user.id,
        content,
        media_urls: mediaUrls,
        media_type: mediaType,
      })
      .select()
      .single()
    
    if (error) throw error
    
    return new Response(JSON.stringify(post), { status: 201 })
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500 })
  }
})