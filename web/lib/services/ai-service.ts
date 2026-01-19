import { supabaseAdmin } from '../supabaseAdmin';

export const AIService = {
    // 1. General Consultation Chat
    async chat(messages: any[], userId?: string, sessionId?: string) {
        // Fetch relevant context (Products) to feed the AI
        const { data: products } = await supabaseAdmin
            .from('products')
            .select('name, brand:brands(name), description, scent_notes, variants:product_variants(price, volume_ml)')
            .eq('is_active', true)
            .limit(10); // Simplified context for prompt

        const systemPrompt = `You are a professional perfume consultant for PerfumeGPT. 
    Use the following product catalog to provide personalized recommendations: ${JSON.stringify(products)}.
    Always be helpful, elegant, and provide reasoning for your suggestions.`;

        const response = await fetch('https://api.x.ai/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${process.env.XAI_API_KEY}`
            },
            body: JSON.stringify({
                messages: [{ role: 'system', content: systemPrompt }, ...messages],
                model: 'grok-beta',
                temperature: 0.7
            })
        });

        const aiData = await response.json();
        const content = aiData.choices[0].message.content;

        // Optional: Log message to database
        if (sessionId) {
            await supabaseAdmin.from('chat_messages').insert({
                session_id: sessionId,
                role: 'ai',
                content: content
            });
        }

        return content;
    },

    // 2. Interactive Quiz Result Analysis
    async processQuiz(answers: any) {
        // Logic to translate quiz answers into a search query or direct suggestions
        // e.g., answers = { gender: 'female', occasion: 'work', scent_family: 'Floral' }

        const prompt = `Based on these user preferences: ${JSON.stringify(answers)}, 
    suggest the top 3 matching perfumes from our catalog. Return only a JSON array of product suggestions with reasons.`;

        const response = await fetch('https://api.x.ai/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${process.env.XAI_API_KEY}`
            },
            body: JSON.stringify({
                messages: [{ role: 'user', content: prompt }],
                model: 'grok-beta',
                response_format: { type: 'json_object' }
            })
        });

        return await response.json();
    },

    // 3. AI Review Summarization
    async summarizeReviews(productId: string) {
        const { data: reviews } = await supabaseAdmin
            .from('reviews')
            .select('comment, rating')
            .eq('product_id', productId)
            .limit(50);

        if (!reviews?.length) return "No reviews yet.";

        const prompt = `Summarize these customer reviews for a perfume. Highlight pros, cons, and overall sentiment: 
    ${reviews.map(r => `[Rating: ${r.rating}/5] ${r.comment}`).join('\n')}`;

        const response = await fetch('https://api.x.ai/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${process.env.XAI_API_KEY}`
            },
            body: JSON.stringify({
                messages: [{ role: 'user', content: prompt }],
                model: 'grok-beta'
            })
        });

        const res = await response.json();
        return res.choices[0].message.content;
    }
};
