import { BadRequestException, ForbiddenException, Injectable } from '@nestjs/common';
import {
  ConversationParticipantRole,
  ConversationType,
  MessageType,
  SenderType,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateConversationDto } from './dto/create-conversation.dto';
import { SendMessageDto } from './dto/send-message.dto';
import { Prisma } from '@prisma/client';
import { AiService } from '../ai/ai.service';
import { UserRoleEnum } from '@prisma/client';

function roleToParticipantRole(role: string): ConversationParticipantRole {
  if (role === 'ADMIN') return ConversationParticipantRole.ADMIN;
  if (role === 'STAFF') return ConversationParticipantRole.STAFF;
  return ConversationParticipantRole.CUSTOMER;
}

@Injectable()
export class ChatService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly aiService: AiService,
  ) {}

  async listConversations(userId: string) {
    return this.prisma.conversation.findMany({
      where: { participants: { some: { userId } } },
      orderBy: { updatedAt: 'desc' },
      include: {
        participants: {
          include: { user: { select: { id: true, email: true, fullName: true, role: true } } },
        },
        messages: {
          orderBy: { createdAt: 'desc' },
          take: 1,
        },
      },
    });
  }

  async listContacts(me: { userId: string; role: string }, search?: string, take?: number) {
    const limit = Math.min(Math.max(take ?? 20, 1), 50);
    const meRole = (me.role as UserRoleEnum) ?? UserRoleEnum.CUSTOMER;

    const allowedRoles: UserRoleEnum[] =
      meRole === UserRoleEnum.ADMIN
        ? [UserRoleEnum.CUSTOMER, UserRoleEnum.STAFF]
        : [UserRoleEnum.ADMIN];

    const q = (search ?? '').trim();

    return this.prisma.user.findMany({
      where: {
        id: { not: me.userId },
        isActive: true,
        role: { in: allowedRoles },
        ...(q
          ? {
              OR: [
                { email: { contains: q, mode: 'insensitive' } },
                { fullName: { contains: q, mode: 'insensitive' } },
                { phone: { contains: q, mode: 'insensitive' } },
              ],
            }
          : {}),
      },
      select: {
        id: true,
        email: true,
        fullName: true,
        role: true,
      },
      orderBy: [{ fullName: 'asc' }, { email: 'asc' }],
      take: limit,
    });
  }

  async createConversation(dto: CreateConversationDto, me: { userId: string; role: string }) {
    const myParticipantRole = roleToParticipantRole(me.role);

    // Permission checks for conversation types (basic)
    const allowedByType: Record<ConversationType, ConversationParticipantRole[]> = {
      CUSTOMER_ADMIN: [ConversationParticipantRole.CUSTOMER, ConversationParticipantRole.ADMIN],
      CUSTOMER_AI: [ConversationParticipantRole.CUSTOMER],
      ADMIN_STAFF: [ConversationParticipantRole.ADMIN, ConversationParticipantRole.STAFF],
      ADMIN_AI: [ConversationParticipantRole.ADMIN],
    };
    const allowed = allowedByType[dto.type] ?? [];
    if (!allowed.includes(myParticipantRole)) {
      throw new ForbiddenException('Not allowed to create this conversation type');
    }

    // Try to reuse existing 1:1 conversation
    if (dto.type !== ConversationType.CUSTOMER_AI && dto.type !== ConversationType.ADMIN_AI) {
      if (!dto.otherUserId) {
        throw new BadRequestException('otherUserId is required for this conversation type');
      }

      const existing = await this.prisma.conversation.findFirst({
        where: {
          type: dto.type,
          AND: [
            { participants: { some: { userId: me.userId } } },
            { participants: { some: { userId: dto.otherUserId } } },
          ],
        },
      });
      if (existing) return existing;
    } else {
      // Reuse existing AI conversation per user
      const existingAi = await this.prisma.conversation.findFirst({
        where: { type: dto.type, participants: { some: { userId: me.userId } } },
      });
      if (existingAi) return existingAi;
    }

    const participants =
      dto.type === ConversationType.CUSTOMER_AI || dto.type === ConversationType.ADMIN_AI
        ? [
            { userId: me.userId, role: myParticipantRole },
            { userId: null, role: ConversationParticipantRole.AI },
          ]
        : [
            { userId: me.userId, role: myParticipantRole },
            {
              userId: dto.otherUserId!,
              role:
                dto.type === ConversationType.ADMIN_STAFF
                  ? ConversationParticipantRole.STAFF
                  : ConversationParticipantRole.ADMIN,
            },
          ];

    return this.prisma.conversation.create({
      data: {
        type: dto.type,
        participants: { create: participants },
      },
    });
  }

  async assertCanAccessConversation(conversationId: string, userId: string) {
    const belongs = await this.prisma.conversationParticipant.findFirst({
      where: { conversationId, userId },
      select: { id: true },
    });
    if (!belongs) throw new ForbiddenException('You do not have access to this conversation');
  }

  async getMessages(params: { conversationId: string; userId: string; cursor?: string; take?: number }) {
    const take = Math.min(Math.max(params.take ?? 30, 1), 100);
    await this.assertCanAccessConversation(params.conversationId, params.userId);

    const items = await this.prisma.message.findMany({
      where: { conversationId: params.conversationId },
      orderBy: { createdAt: 'desc' },
      take,
      ...(params.cursor
        ? {
            skip: 1,
            cursor: { id: params.cursor },
          }
        : {}),
    });

    const nextCursor = items.length === take ? items[items.length - 1]?.id : null;
    return { items, nextCursor };
  }

  async sendMessage(dto: SendMessageDto, me: { userId: string; role: string }) {
    await this.assertCanAccessConversation(dto.conversationId, me.userId);

    const message = await this.prisma.message.create({
      data: {
        conversationId: dto.conversationId,
        senderId: me.userId,
        senderType: SenderType.USER,
        type: dto.type as MessageType,
        content: dto.content as Prisma.InputJsonValue,
      },
    });

    await this.prisma.conversation.update({
      where: { id: dto.conversationId },
      data: { updatedAt: new Date() },
    });

    // Optionally trigger AI reply for AI conversations
    const conversation = await this.prisma.conversation.findUnique({
      where: { id: dto.conversationId },
      select: { type: true },
    });

    let aiMessage: any = null;
    if (
      conversation &&
      (conversation.type === ConversationType.CUSTOMER_AI ||
        conversation.type === ConversationType.ADMIN_AI) &&
      dto.type === MessageType.TEXT &&
      typeof dto.content === 'object' &&
      dto.content !== null &&
      typeof (dto.content as any).text === 'string'
    ) {
      const ai = await this.aiService.replyForConversation(
        dto.conversationId,
        conversation.type,
        (dto.content as any).text,
        me.userId,
      );

      aiMessage = await this.prisma.message.create({
        data: {
          conversationId: dto.conversationId,
          senderId: null,
          senderType: SenderType.AI,
          type: ai.recommendations && ai.recommendations.length > 0 ? MessageType.AI_RECOMMENDATION : MessageType.TEXT,
          content: {
            text: ai.text,
            recommendations: ai.recommendations ?? [],
          } as unknown as Prisma.InputJsonValue,
        },
      });
    }

    return { message, aiMessage };
  }
}

