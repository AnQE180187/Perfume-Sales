import { NextResponse } from 'next/server';
import { AIService } from '@/lib/services/ai-service';

export async function POST(req: Request) {
    try {
        const { answers } = await req.json();
        const result = await AIService.processQuiz(answers);
        return NextResponse.json(result);
    } catch (error: any) {
        return NextResponse.json({ error: error.message }, { status: 500 });
    }
}
