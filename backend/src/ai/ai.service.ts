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

  private async getUserProfile(userId: string) {
    return this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        gender: true,
        budgetMin: true,
        budgetMax: true,
        preferences: {
          select: {
            scentFamily: { select: { name: true } },
            note: { select: { name: true, type: true } },
          },
        },
        quizResults: {
          select: { gender: true, occasion: true, preferredFamily: true },
          orderBy: { createdAt: 'desc' },
          take: 1,
        },
      },
    });
  }

  private async searchProducts(query: string, filters: any = {}) {
    // Simple search based on name, description, scent family
    const products = await this.prisma.product.findMany({
      where: {
        isActive: true,
        AND: [
          {
            OR: [
              { name: { contains: query, mode: 'insensitive' } },
              { description: { contains: query, mode: 'insensitive' } },
              { scentFamily: { name: { contains: query, mode: 'insensitive' } } },
              { notes: { some: { note: { name: { contains: query, mode: 'insensitive' } } } } },
            ],
          },
          filters.budgetMax ? { variants: { some: { price: { lte: filters.budgetMax } } } } : {},
          filters.budgetMin ? { variants: { some: { price: { gte: filters.budgetMin } } } } : {},
          filters.gender ? { gender: filters.gender } : {},
          filters.scentFamily ? { scentFamily: { name: { contains: filters.scentFamily, mode: 'insensitive' } } } : {},
        ],
      },
      select: {
        id: true,
        name: true,
        gender: true,
        scentFamily: { select: { name: true } },
        notes: {
          select: {
            note: { select: { name: true, type: true } },
          },
        },
        variants: {
          select: { price: true },
          orderBy: { price: 'asc' },
          take: 1,
        },
      },
      take: 10,
    });
    return products.map(p => ({
      ...p,
      price: p.variants[0]?.price || 0,
    }));
  }

  private async getTrendData() {
    // Scent family trends
    const trends = await this.prisma.product.groupBy({
      by: ['scentFamilyId'],
      _count: { id: true },
      where: { isActive: true },
    });

    const families = await this.prisma.scentFamily.findMany({
      where: { id: { in: trends.map(t => t.scentFamilyId).filter(id => id !== null) as number[] } },
      select: { id: true, name: true },
    });

    return trends.map(t => {
      const fam = families.find(f => f.id === t.scentFamilyId);
      return { scentFamily: fam?.name || 'Unknown', count: t._count.id };
    });
  }

  private buildPerfumeConsultPrompt(message: string, userProfile: any, products: any[], memory: any) {
    const profileStr = userProfile
      ? `Thông tin khách hàng: Giới tính ${userProfile.gender || 'không rõ'}, ngân sách ${userProfile.budgetMin || 0} - ${userProfile.budgetMax || 'không giới hạn'}, sở thích mùi hương: ${userProfile.preferences?.map((p: any) => p.scentFamily?.name || p.note?.name).join(', ') || 'không rõ'}.`
      : '';

    const memoryStr = Object.keys(memory).length
      ? `Lịch sử trò chuyện: Sở thích trước đó: ${Object.entries(memory).map(([k, v]) => `${k}: ${v}`).join(', ')}.`
      : '';

    const productsStr = products.length > 0
      ? products
        .map(
          (p) =>
            `ID: ${p.id}, Tên: ${p.name}, Giá: ${p.price}, Giới tính: ${p.gender}, Mùi hương: ${p.scentFamily?.name}, Ghi chú: ${p.notes?.map((n: any) => n.note.name).join(', ')}`,
        )
        .join('\n')
      : 'Không có sản phẩm phù hợp trong database.';

    return `Bạn là chuyên gia tư vấn nước hoa của PerfumeGPT.
Khách đang hỏi: "${message}".

${profileStr}

${memoryStr}

Danh sách sản phẩm phù hợp từ database:
${productsStr}

Hãy trả lời thân thiện bằng tiếng Việt và gợi ý tối đa 3 sản phẩm từ danh sách nếu có.

Trả về JSON:
{
  "text": "câu trả lời tự nhiên",
  "recommendations": [{"productId": "id", "name": "tên", "reason": "lý do", "price": 100000}]
}`;
  }

  private async getSalesData() {
    // Top selling products this month
    const startOfMonth = new Date();
    startOfMonth.setDate(1);
    startOfMonth.setHours(0, 0, 0, 0);

    const topProducts = await this.prisma.orderItem.groupBy({
      by: ['variantId'],
      where: {
        order: {
          createdAt: { gte: startOfMonth },
          status: 'COMPLETED',
        },
      },
      _sum: { quantity: true },
      orderBy: { _sum: { quantity: 'desc' } },
      take: 10,
    });

    const variants = await this.prisma.productVariant.findMany({
      where: { id: { in: topProducts.map(p => p.variantId) } },
      select: { id: true, product: { select: { id: true, name: true, scentFamily: { select: { name: true } } } } },
    });

    return topProducts.map(tp => {
      const variant = variants.find(v => v.id === tp.variantId);
      return {
        productId: variant?.product?.id || '',
        name: variant?.product?.name || 'Unknown',
        scentFamily: variant?.product?.scentFamily?.name || 'Unknown',
        quantitySold: tp._sum?.quantity || 0,
      };
    });
  }

  private async getConversationMemory(conversationId: string) {
    // Simple memory: extract from recent messages
    const messages = await this.prisma.message.findMany({
      where: { conversationId },
      orderBy: { createdAt: 'desc' },
      take: 10,
      select: { content: true, senderType: true },
    });

    const memory: any = {};
    for (const msg of messages.reverse()) {
      if (msg.senderType === 'USER' && typeof msg.content === 'object' && msg.content) {
        const text = (msg.content as any).text;
        if (text) {
          // Extract preferences (simple keyword matching)
          if (text.toLowerCase().includes('sweet')) memory.preferredScent = 'sweet';
          if (text.toLowerCase().includes('woody')) memory.preferredScent = 'woody';
          if (text.toLowerCase().includes('floral')) memory.preferredScent = 'floral';
          if (text.toLowerCase().includes('citrus') || text.toLowerCase().includes('fresh')) memory.preferredScent = 'fresh';
          if (text.toLowerCase().includes('under') || text.toLowerCase().includes('budget')) {
            const match = text.match(/under (\d+)/i);
            if (match) memory.budgetMax = parseInt(match[1]) * 1000; // assume VND
          }
        }
      }
    }
    return memory;
  }

  private buildMarketingPrompt(message: string, salesData: any[], trends: any[]) {
    const salesStr = salesData
      .map(s => `Sản phẩm: ${s.name}, Mùi hương: ${s.scentFamily}, Bán được: ${s.quantitySold}`)
      .join('\n');

    const trendsStr = trends
      .map(t => `${t.scentFamily}: ${t.count} sản phẩm`)
      .join('\n');

    return `Bạn là trợ lý marketing nước hoa của PerfumeGPT.
Admin hỏi: "${message}".

Dữ liệu bán hàng tháng này:
${salesStr}

Xu hướng mùi hương:
${trendsStr}

Hãy trả lời bằng tiếng Việt, tập trung vào:
- Phân tích xu hướng bán hàng.
- Gợi ý chiến dịch marketing.
- Ý tưởng khuyến mãi.

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
      // Try direct JSON
      return JSON.parse(raw.trim());
    } catch {
      // Try extract from markdown
      const match = raw.match(/```(?:json)?\s*([\s\S]*?)```/);
      if (match) {
        try {
          return JSON.parse(match[1].trim());
        } catch { }
      }
      // Try find JSON in text
      const jsonMatch = raw.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        try {
          return JSON.parse(jsonMatch[0]);
        } catch { }
      }
      return null;
    }
  }

  async replyForConversation(
    conversationId: string,
    type: ConversationType,
    lastUserMessage: string,
    userId?: string,
  ): Promise<{ text: string; recommendations?: AiProductRecommendation[]; raw: string }> {
    let prompt: string;
    let products: any[] = [];
    let salesData: any[] = [];
    let trends: any[] = [];

    if (type === ConversationType.CUSTOMER_AI) {
      // Fetch user profile, memory, and search products
      const userProfile = userId ? await this.getUserProfile(userId) : null;
      const memory = await this.getConversationMemory(conversationId);
      products = await this.searchProducts(lastUserMessage, {
        budgetMax: userProfile?.budgetMax || memory.budgetMax,
        budgetMin: userProfile?.budgetMin,
        gender: userProfile?.gender,
        scentFamily: memory.preferredScent,
      });
      prompt = this.buildPerfumeConsultPrompt(lastUserMessage, userProfile, products, memory);
    } else if (type === ConversationType.ADMIN_AI) {
      // Fetch sales and trend data
      salesData = await this.getSalesData();
      trends = await this.getTrendData();
      prompt = this.buildMarketingPrompt(lastUserMessage, salesData, trends);
    } else {
      throw new InternalServerErrorException('Unsupported conversation type');
    }

    const raw = await this.callGemini(prompt);
    console.log('AI Raw Response:', raw); // Debug log
    const parsed = this.extractJson(raw) ?? {};
    console.log('Parsed:', parsed); // Debug log

    const text: string = parsed.text ?? raw;
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

