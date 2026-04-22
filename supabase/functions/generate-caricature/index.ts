import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const { imageUrl } = await req.json()
    const replicateToken = Deno.env.get('REPLICATE_API_TOKEN')
    
    if (!imageUrl || !replicateToken) {
      return new Response(JSON.stringify({ error: 'Missing parameters' }), { status: 400 })
    }
    
    // Start prediction with Replicate
    const prediction = await fetch('https://api.replicate.com/v1/predictions', {
      method: 'POST',
      headers: {
        'Authorization': `Token ${replicateToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        version: 'caricature-model-version',
        input: { image: imageUrl, style: 'caricature' },
      }),
    })
    
    if (prediction.status !== 201) {
      throw new Error('Failed to start generation')
    }
    
    const predictionData = await prediction.json()
    const getUrl = predictionData.urls.get
    
    // Poll for result
    let result = null
    let attempts = 0
    const maxAttempts = 30
    
    while (!result && attempts < maxAttempts) {
      await new Promise(resolve => setTimeout(resolve, 2000))
      
      const statusRes = await fetch(getUrl, {
        headers: { 'Authorization': `Token ${replicateToken}` },
      })
      const status = await statusRes.json()
      
      if (status.status === 'succeeded') {
        result = status.output
        break
      } else if (status.status === 'failed') {
        throw new Error('Generation failed')
      }
      attempts++
    }
    
    if (!result) {
      return new Response(JSON.stringify({ error: 'Timeout' }), { status: 504 })
    }
    
    return new Response(JSON.stringify({ caricatureUrl: result }))
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500 })
  }
})