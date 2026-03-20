import { IsEnum, IsObject, IsOptional, IsString } from 'class-validator';
import { MessageType } from '@prisma/client';

export class SendMessageDto {
  @IsString()
  conversationId: string;

  @IsEnum(MessageType)
  type: MessageType;

  /**
   * Message content is stored as JSON to support product cards & structured payloads.
   * For TEXT messages, frontend can send: { "text": "..." }.
   */
  @IsObject()
  content: Record<string, unknown>;

  /** Optional client-generated id for optimistic UI (not persisted yet). */
  @IsOptional()
  @IsString()
  clientMessageId?: string;
}

