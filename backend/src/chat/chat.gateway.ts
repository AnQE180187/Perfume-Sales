import { ConfigService } from '@nestjs/config';
import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { JwtService } from '@nestjs/jwt';
import { Server, Socket } from 'socket.io';
import { ChatService } from './chat.service';
import { SendMessageDto } from './dto/send-message.dto';

type AuthedSocket = Socket & { user?: { userId: string; role: string } };

@WebSocketGateway({
  namespace: '/chat',
  cors: { origin: true, credentials: true },
})
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  constructor(
    private readonly chatService: ChatService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async handleConnection(client: AuthedSocket) {
    try {
      const token =
        (typeof client.handshake.auth?.token === 'string' && client.handshake.auth.token) ||
        (typeof client.handshake.headers?.authorization === 'string'
          ? client.handshake.headers.authorization.replace(/^Bearer\s+/i, '')
          : null);

      if (!token) return client.disconnect(true);

      const payload = await this.jwtService.verifyAsync<{ sub: string; role: string; email: string }>(
        token,
        { secret: this.configService.getOrThrow<string>('JWT_ACCESS_SECRET') },
      );

      client.user = { userId: payload.sub, role: payload.role };
    } catch {
      client.disconnect(true);
    }
  }

  handleDisconnect(_client: AuthedSocket) {}

  @SubscribeMessage('joinConversation')
  async joinConversation(
    @ConnectedSocket() client: AuthedSocket,
    @MessageBody() body: { conversationId: string },
  ) {
    if (!client.user?.userId) return;
    await this.chatService.assertCanAccessConversation(body.conversationId, client.user.userId);
    await client.join(`conversation:${body.conversationId}`);
    client.emit('conversationUpdated', { conversationId: body.conversationId, joined: true });
  }

  @SubscribeMessage('sendMessage')
  async sendMessage(@ConnectedSocket() client: AuthedSocket, @MessageBody() dto: SendMessageDto) {
    if (!client.user) return;
    const { message, aiMessage } = await this.chatService.sendMessage(dto, client.user);
    this.server.to(`conversation:${dto.conversationId}`).emit('messageReceived', message);
    if (aiMessage) {
      this.server.to(`conversation:${dto.conversationId}`).emit('messageReceived', aiMessage);
    }
    return { message, aiMessage };
  }
}

