import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import axios from 'axios';
import { ConversationType } from '@prisma/client';

export interface AiTextReply {
  text: string;
}

export interface AiProductRecommendation {
  productId: string;
  name: string;
  reason: string;
  price?: number;
}

@Injectable()
export class AiService {
  private readonly apiKey: string;
  private readonly model: string;

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
  ) {
    this.apiKey = this.config.get<string>('GEMINI_API_KEY', '');
    this.model = this.config.get<string>('GEMINI_MODEL', 'gemini-3.0-flash');
  }

  private buildPerfumeConsultPrompt(message: string) {
    return `Bạn là chuyên gia tư vấn nước hoa của PerfumeGPT.
Khách đang hỏi/tâm sự: "${message}".

Hãy:
- Trả lời thân thiện bằng tiếng Việt.
- Nếu phù hợp, gợi ý 2–3 phong cách mùi hương (không cần ID sản phẩm thật).

Định dạng JSON như sau, không thêm chữ nào ngoài JSON:
{
  "text": "câu trả lời tự nhiên bằng tiếng Việt",
  "recommendations": [
    { "productId": "virtual-1", "name": "Gợi ý 1", "reason": "Lý do ..." }
  ]
}`;
  }

  private buildMarketingPrompt(message: string) {
    return `Bạn là trợ lý marketing nước hoa của PerfumeGPT.
Admin hỏi: "${message}".

Hãy trả lời bằng tiếng Việt, tập trung vào:
- insight khách hàng nước hoa,
- gợi ý chiến dịch,
- ý tưởng nội dung.

Định dạng JSON, không thêm chữ nào ngoài JSON:
{
  "text": "phân tích & gợi ý chiến lược bằng tiếng Việt"
}`;
  }

  private async callGemini(prompt: string): Promise<string> {
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${this.model}:generateContent?key=${this.apiKey}`;

    try {
      const res = await axios.post(
        url,
        {
          contents: [{ parts: [{ text: prompt }] }],
          generationConfig: {
            temperature: 0.7,
            maxOutputTokens: 1024,
          },
        },
        { timeout: 15000 },
      );

      return res.data?.candidates?.[0]?.content?.parts?.[0]?.text ?? '';
    } catch (err: any) {
      const message = err?.response?.data?.error?.message ?? err.message;
      throw new InternalServerErrorException(`AI request failed: ${message}`);
    }
  }

  private extractJson(raw: string): any {
    try {
      let jsonStr = raw.trim();
      const match = raw.match(/```(?:json)?\s*([\s\S]*?)```/);
      if (match) jsonStr = match[1].trim();
      return JSON.parse(jsonStr);
    } catch {
      return null;
    }
  }

  async replyForConversation(
    conversationId: string,
    type: ConversationType,
    lastUserMessage: string,
    userId?: string,
  ): Promise<{ text: string; recommendations?: AiProductRecommendation[]; raw: string }> {
    const prompt =
      type === ConversationType.CUSTOMER_AI
        ? this.buildPerfumeConsultPrompt(lastUserMessage)
        : this.buildMarketingPrompt(lastUserMessage);

    const raw = await this.callGemini(prompt);
    const parsed = this.extractJson(raw) ?? {};

    const text: string = parsed.text ?? lastUserMessage;
    const recommendations: AiProductRecommendation[] | undefined = Array.isArray(
      parsed.recommendations,
    )
      ? parsed.recommendations.map((r: any) => ({
          productId: r.productId ?? '',
          name: r.name ?? '',
          reason: r.reason ?? '',
          price: typeof r.price === 'number' ? r.price : undefined,
        }))
      : undefined;

    // Log
    await this.prisma.aiRequestLog.create({
      data: {
        userId: userId ?? null,
        type: type === ConversationType.CUSTOMER_AI ? 'CHAT_CUSTOMER_AI' : 'CHAT_ADMIN_AI',
        request: prompt,
        response: raw,
        status: 'SUCCESS',
      },
    });

    return { text, recommendations, raw };
  }
}

