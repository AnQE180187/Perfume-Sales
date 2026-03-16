import { IsEnum, IsOptional, IsString } from 'class-validator';
import { ConversationType } from '@prisma/client';

export class CreateConversationDto {
  @IsEnum(ConversationType)
  type: ConversationType;

  /**
   * Optional: when creating 1:1 chats, specify the other participant userId.
   * - CUSTOMER_ADMIN: customer creates with an admin (optional, can be assigned later)
   * - ADMIN_STAFF: admin creates with staffId
   */
  @IsOptional()
  @IsString()
  otherUserId?: string;
}

