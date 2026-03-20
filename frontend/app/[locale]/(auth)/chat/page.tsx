'use client';

import { useState, useEffect, useRef } from 'react';
import { useParams } from 'next/navigation';
import { chatService, Conversation, Message } from '@/services/chat.service';
import type { MessageType } from '@/services/chat.service';
import { getChatSocket } from '@/lib/socket';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { ScrollArea } from '@/components/ui/scroll-area';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';

export default function ChatPage() {
  const { locale } = useParams();
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [selectedConversation, setSelectedConversation] = useState<Conversation | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [newMessage, setNewMessage] = useState('');
  const [loading, setLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const socket = getChatSocket();

  useEffect(() => {
    loadConversations();
  }, []);

  useEffect(() => {
    if (selectedConversation) {
      loadMessages(selectedConversation.id);
    }
  }, [selectedConversation]);

  useEffect(() => {
    socket.on('message', (message: Message) => {
      if (message.conversationId === selectedConversation?.id) {
        setMessages(prev => [...prev, message]);
      }
    });

    return () => {
      socket.off('message');
    };
  }, [selectedConversation]);

  const loadConversations = async () => {
    try {
      const convs = await chatService.listConversations();
      setConversations(convs);
    } catch (error) {
      console.error('Failed to load conversations:', error);
    }
  };

  const loadMessages = async (conversationId: string) => {
    try {
      const { items } = await chatService.getMessages({ conversationId, take: 50 });
      setMessages(items.reverse());
    } catch (error) {
      console.error('Failed to load messages:', error);
    }
  };

  const createAIConversation = async (type: 'CUSTOMER_AI' | 'ADMIN_AI') => {
    try {
      const conv = await chatService.createConversation({ type });
      setConversations(prev => [conv, ...prev]);
      setSelectedConversation(conv);
    } catch (error) {
      console.error('Failed to create conversation:', error);
    }
  };

  const sendMessage = async () => {
    if (!selectedConversation || !newMessage.trim()) return;

    setLoading(true);
    try {
      const { message, aiMessage } = await chatService.sendMessage({
        conversationId: selectedConversation.id,
        type: 'TEXT',
        content: { text: newMessage },
      });

      setMessages(prev => [...prev, message]);
      if (aiMessage) {
        setMessages(prev => [...prev, aiMessage]);
      }
      setNewMessage('');
    } catch (error) {
      console.error('Failed to send message:', error);
    } finally {
      setLoading(false);
    }
  };

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  return (
    <div className="flex h-screen">
      {/* Sidebar */}
      <div className="w-80 border-r bg-gray-50 p-4">
        <h2 className="text-lg font-semibold mb-4">Conversations</h2>
        <div className="space-y-2 mb-4">
          <Button onClick={() => createAIConversation('CUSTOMER_AI')} className="w-full">
            New AI Consultant Chat
          </Button>
          <Button onClick={() => createAIConversation('ADMIN_AI')} variant="outline" className="w-full">
            New Marketing Assistant Chat
          </Button>
        </div>
        <ScrollArea className="h-[calc(100vh-200px)]">
          {conversations.map((conv) => (
            <Card
              key={conv.id}
              className={`cursor-pointer mb-2 ${selectedConversation?.id === conv.id ? 'border-blue-500' : ''}`}
              onClick={() => setSelectedConversation(conv)}
            >
              <CardContent className="p-3">
                <div className="flex justify-between items-center">
                  <span className="font-medium">{conv.type}</span>
                  <Badge variant="secondary">{conv.participants?.length} participants</Badge>
                </div>
                <p className="text-sm text-gray-500 mt-1">
                  {conv.messages?.[0]?.content?.text?.slice(0, 50) || 'No messages'}
                </p>
              </CardContent>
            </Card>
          ))}
        </ScrollArea>
      </div>

      {/* Chat Area */}
      <div className="flex-1 flex flex-col">
        {selectedConversation ? (
          <>
            <div className="p-4 border-b">
              <h3 className="text-lg font-semibold">{selectedConversation.type}</h3>
            </div>
            <ScrollArea className="flex-1 p-4">
              <div className="space-y-4">
                {messages.map((msg) => (
                  <div key={msg.id} className={`flex ${msg.senderType === 'USER' ? 'justify-end' : 'justify-start'}`}>
                    <div className={`max-w-xs lg:max-w-md px-4 py-2 rounded-lg ${msg.senderType === 'USER'
                      ? 'bg-blue-500 text-white'
                      : msg.senderType === 'AI'
                        ? 'bg-green-500 text-white'
                        : 'bg-gray-200'
                      }`}>
                      {msg.type === 'TEXT' && (
                        <p>{(msg.content as any)?.text}</p>
                      )}
                      {msg.type === 'AI_RECOMMENDATION' && (
                        <div>
                          <p>{(msg.content as any)?.text}</p>
                          {(msg.content as any)?.recommendations?.map((rec: any) => (
                            <Card key={rec.productId} className="mt-2">
                              <CardContent className="p-2">
                                <p className="font-medium">{rec.name}</p>
                                <p className="text-sm text-gray-600">{rec.reason}</p>
                                {rec.price && <p className="text-sm font-semibold">{rec.price.toLocaleString()} VND</p>}
                              </CardContent>
                            </Card>
                          ))}
                        </div>
                      )}
                    </div>
                  </div>
                ))}
                <div ref={messagesEndRef} />
              </div>
            </ScrollArea>
            <div className="p-4 border-t">
              <div className="flex space-x-2">
                <Input
                  value={newMessage}
                  onChange={(e) => setNewMessage(e.target.value)}
                  placeholder="Type your message..."
                  onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
                  disabled={loading}
                />
                <Button onClick={sendMessage} disabled={loading || !newMessage.trim()}>
                  Send
                </Button>
              </div>
            </div>
          </>
        ) : (
          <div className="flex-1 flex items-center justify-center">
            <p className="text-gray-500">Select a conversation to start chatting</p>
          </div>
        )}
      </div>
    </div>
  );
}