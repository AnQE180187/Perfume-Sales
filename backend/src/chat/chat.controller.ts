import { Controller, Get, Post, Body, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { ChatService } from './chat.service';
import { CreateConversationDto } from './dto/create-conversation.dto';
import { SendMessageDto } from './dto/send-message.dto';

@Controller('chat')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Get('contacts')
  listContacts(
    @Req() req: any,
    @Query('search') search?: string,
    @Query('take') take?: string,
  ) {
    const user = req.user as { userId: string; role: string };
    return this.chatService.listContacts(user, search, take ? Number(take) : undefined);
  }

  @Get('conversations')
  listConversations(@Req() req: any) {
    const user = req.user as { userId: string };
    return this.chatService.listConversations(user.userId);
  }

  @Post('conversations')
  createConversation(@Req() req: any, @Body() dto: CreateConversationDto) {
    const user = req.user as { userId: string; role: string };
    return this.chatService.createConversation(dto, user);
  }

  @Get('messages')
  getMessages(
    @Req() req: any,
    @Query('conversationId') conversationId: string,
    @Query('cursor') cursor?: string,
    @Query('take') take?: string,
  ) {
    const user = req.user as { userId: string };
    return this.chatService.getMessages({
      conversationId,
      userId: user.userId,
      cursor,
      take: take ? Number(take) : undefined,
    });
  }

  @Post('messages')
  sendMessage(@Req() req: any, @Body() dto: SendMessageDto) {
    const user = req.user as { userId: string; role: string };
    return this.chatService.sendMessage(dto, user);
  }
}

