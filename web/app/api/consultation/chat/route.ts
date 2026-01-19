import { NextResponse } from 'next/server';
import { AIService } from '@/lib/services/ai-service';

export async function POST(req: Request) {
    try {
        const { messages, userId, sessionId } = await req.json();
        const aiResponse = await AIService.chat(messages, userId, sessionId);
        return NextResponse.json({ content: aiResponse });
    } catch (error: any) {
        return NextResponse.json({ error: error.message }, { status: 500 });
    }
}
