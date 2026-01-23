import { apiClient } from '../api-client';

export const AIService = {
    // 1. General Consultation Chat
    async chat(messages: any[], userId?: string, sessionId?: string) {
        // Fetch relevant context (Products) to feed the AI
        const productsResponse = await apiClient.getProducts();
        const products = productsResponse.data || [];
        
        const limitedProducts = products.slice(0, 10).map((p: any) => ({
            name: p.name,
            brand: p.brand?.name,
            description: p.description,
            scentNotes: p.scentNotes,
            variants: p.variants?.map((v: any) => ({ price: v.price, volumeMl: v.volumeMl }))
        }));

        const systemPrompt = `You are a professional perfume consultant for PerfumeGPT. 
    Use the following product catalog to provide personalized recommendations: ${JSON.stringify(limitedProducts)}.
    Always be helpful, elegant, and provide reasoning for your suggestions.`;

        const response = await fetch('https://api.x.ai/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${process.env.NEXT_PUBLIC_XAI_API_KEY || process.env.XAI_API_KEY}`
            },
            body: JSON.stringify({
                messages: [{ role: 'system', content: systemPrompt }, ...messages],
                model: 'grok-beta',
                temperature: 0.7
            })
        });

        const aiData = await response.json();
        const content = aiData.choices[0]?.message?.content || 'Sorry, I could not generate a response.';

        // TODO: Log message to database via backend API
        // if (sessionId) {
        //     await apiClient.logChatMessage(sessionId, 'ai', content);
        // }

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
                'Authorization': `Bearer ${process.env.NEXT_PUBLIC_XAI_API_KEY || process.env.XAI_API_KEY}`
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
        // TODO: Get reviews from backend API
        // For now, return placeholder
        return "Review summarization feature will be available soon.";
    }
};
