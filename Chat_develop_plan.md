# Chat System Development Plan

**Project:** AI-Powered Perfume Sales & Personalized Consultation System
**Module:** Realtime Chat + AI Consultation
**Target Stack:** NestJS + PostgreSQL + Prisma + WebSocket + AI API

---

# 1. Overview

The Chat System enables communication between different roles in the system and integrates AI consultation capabilities.

### Supported Chat Types

| Chat Type        | Participants                  | Purpose                                  |
| ---------------- | ----------------------------- | ---------------------------------------- |
| Customer ↔ Admin | Customer, Admin               | Customer support, product questions      |
| Customer ↔ AI    | Customer, AI Consultant       | Perfume consultation and recommendations |
| Admin ↔ Staff    | Admin, Staff                  | Internal communication                   |
| Admin ↔ AI       | Admin, AI Marketing Assistant | Marketing insights and strategy          |

### Key Capabilities

* Realtime messaging
* Role-based chat access
* AI consultation
* AI marketing advisor
* Product recommendation messages
* Chat history storage
* Conversation management

---

# 2. Development Strategy

The feature will be developed in **6 phases**:

1. Chat Domain & Database Design
2. Backend Chat Infrastructure
3. Realtime Messaging (WebSocket Gateway)
4. AI Chat Integration
5. Frontend Chat UI
6. Testing & Optimization

---

# 3. Phase 1 — Database & Domain Design

## 3.1 Entities

The chat system will use three core entities:

* Conversation
* ConversationParticipant
* Message

### Conversation

Represents a chat session.

Fields:

| Field     | Type     | Description       |
| --------- | -------- | ----------------- |
| id        | string   | primary key       |
| type      | enum     | conversation type |
| createdAt | datetime | creation time     |
| updatedAt | datetime | last activity     |

Conversation Types:

```
CUSTOMER_ADMIN
CUSTOMER_AI
ADMIN_STAFF
ADMIN_AI
```

---

### ConversationParticipant

Defines which users belong to a conversation.

| Field          | Type     |
| -------------- | -------- |
| id             | string   |
| conversationId | string   |
| userId         | string   |
| role           | enum     |
| joinedAt       | datetime |

Role enum:

```
CUSTOMER
ADMIN
STAFF
AI
```

---

### Message

Stores messages in conversations.

| Field          | Type     | Description     |
| -------------- | -------- | --------------- |
| id             | string   | message id      |
| conversationId | string   | conversation    |
| senderId       | string   | sender user     |
| senderType     | enum     | USER or AI      |
| content        | json     | message content |
| type           | enum     | message type    |
| createdAt      | datetime | timestamp       |

Message Types:

```
TEXT
PRODUCT_CARD
SYSTEM
AI_RECOMMENDATION
```

---

## 3.2 Prisma Schema Example

```
model Conversation {
  id            String   @id @default(cuid())
  type          ConversationType
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt

  participants  ConversationParticipant[]
  messages      Message[]
}

model ConversationParticipant {
  id             String   @id @default(cuid())
  conversationId String
  userId         String
  role           UserRole
  joinedAt       DateTime @default(now())

  conversation Conversation @relation(fields: [conversationId], references: [id])
}

model Message {
  id             String   @id @default(cuid())
  conversationId String
  senderId       String?
  senderType     SenderType
  content        Json
  type           MessageType
  createdAt      DateTime @default(now())

  conversation Conversation @relation(fields: [conversationId], references: [id])
}
```

Enums:

```
enum ConversationType {
  CUSTOMER_ADMIN
  CUSTOMER_AI
  ADMIN_STAFF
  ADMIN_AI
}

enum SenderType {
  USER
  AI
}

enum MessageType {
  TEXT
  PRODUCT_CARD
  SYSTEM
  AI_RECOMMENDATION
}
```

---

# 4. Phase 2 — Backend Chat Module

## 4.1 Module Structure

```
src/modules/chat
    chat.module.ts
    chat.service.ts
    chat.gateway.ts
    chat.controller.ts

    dto/
        send-message.dto.ts
        create-conversation.dto.ts

    services/
        conversation.service.ts
        message.service.ts
```

---

## 4.2 Responsibilities

### Chat Service

Handles:

* create conversation
* fetch conversations
* send message
* store messages
* call AI service when required

---

### Conversation Service

Responsibilities:

* create conversation
* add participants
* fetch user conversations

---

### Message Service

Responsibilities:

* save messages
* fetch message history
* pagination
* message formatting

---

# 5. Phase 3 — Realtime Messaging

## 5.1 WebSocket Gateway

Using NestJS WebSocket Gateway.

Gateway responsibilities:

* manage socket connections
* handle message events
* broadcast messages to participants
* typing indicator
* read status

### Events

Client → Server

```
joinConversation
sendMessage
typing
markAsRead
```

Server → Client

```
messageReceived
conversationUpdated
userTyping
messageRead
```

---

## 5.2 Socket Flow

Example: Send Message

```
Client
   │
sendMessage
   │
ChatGateway
   │
ChatService
   │
Save message in database
   │
Broadcast message
   │
Clients receive update
```

---

# 6. Phase 4 — AI Chat Integration

Two AI modes will be implemented.

---

## 6.1 AI Mode 1 — Perfume Consultant

Used for:

Customer ↔ AI

Responsibilities:

* analyze user message
* understand preferences
* recommend perfumes

Expected AI response format:

```
{
  "recommendations": [
    {
      "productId": "...",
      "name": "...",
      "reason": "...",
      "price": ...
    }
  ]
}
```

The backend converts this to a **PRODUCT_CARD message**.

---

## 6.2 AI Mode 2 — Marketing Advisor

Used for:

Admin ↔ AI

Capabilities:

* marketing strategy suggestions
* perfume trend analysis
* campaign ideas
* sales insights

Example prompts:

```
Top perfume trends this month

Which perfumes should be promoted for summer?

What scent types are trending among female customers age 20-30?
```

---

## 6.3 AI Service Structure

```
src/modules/ai

ai.service.ts
perfume-consultant.service.ts
marketing-advisor.service.ts
```

Responsibilities:

Perfume Consultant

* analyze message
* retrieve candidate perfumes
* generate recommendation

Marketing Advisor

* provide insights
* generate strategy suggestions

---

# 7. Phase 5 — Frontend Chat UI

Three chat interfaces will be implemented.

---

## 7.1 Customer App

Features:

* chat with AI
* chat with admin
* product recommendation cards
* quick reply buttons

---

## 7.2 Admin Dashboard

Inbox structure:

```
Inbox
 ├ Customer chats
 ├ Staff chats
 └ AI Marketing Assistant
```

Admin capabilities:

* reply to customers
* communicate with staff
* ask AI for marketing insights

---

## 7.3 Staff App

Features:

```
Chat with Admin
```

Use cases:

* request help
* report issues
* order handling

---

# 8. Phase 6 — Security & Permissions

Permission rules:

| Role     | Customer | Admin | Staff | AI   |
| -------- | -------- | ----- | ----- | ---- |
| Customer | —        | chat  | —     | chat |
| Admin    | chat     | —     | chat  | chat |
| Staff    | —        | chat  | —     | —    |

Backend must validate:

* user belongs to conversation
* role is allowed for conversation type

---

# 9. Performance & Scalability

Recommended enhancements:

### Redis (optional)

For:

* WebSocket scaling
* message queue
* pub/sub

### Pagination

Messages should be loaded with pagination:

```
GET /messages?conversationId=...&cursor=...
```

### Message caching

Recent messages cached for fast loading.

---

# 10. AI Agent Development Tasks (for Codex)

These tasks can be assigned sequentially to an AI coding agent.

### Task 1

Generate Prisma schema for:

* Conversation
* ConversationParticipant
* Message

---

### Task 2

Generate NestJS Chat Module:

* ChatModule
* ChatService
* ChatController

---

### Task 3

Implement WebSocket Gateway:

* joinConversation
* sendMessage
* broadcast messages

---

### Task 4

Implement Message persistence using Prisma.

---

### Task 5

Implement Conversation management APIs:

```
GET /conversations
POST /conversations
GET /messages
```

---

### Task 6

Integrate AI service:

* perfume consultation
* marketing advisor

---

### Task 7

Implement message types:

* TEXT
* PRODUCT_CARD
* AI_RECOMMENDATION

---

### Task 8

Implement permission middleware for chat roles.

---

### Task 9

Add typing indicator and read receipts.

---

### Task 10

Optimize message fetching and caching.

---

# 11. Estimated Development Timeline

| Phase                       | Duration |
| --------------------------- | -------- |
| Database Design             | 1 day    |
| Backend Chat Infrastructure | 2 days   |
| Realtime WebSocket          | 2 days   |
| AI Integration              | 2 days   |
| Frontend UI                 | 3–4 days |
| Testing & Optimization      | 2 days   |

Total estimated time: **10–13 days**

---

# 12. Future Improvements

Potential enhancements:

* Voice chat with AI
* AI sentiment detection
* AI upselling recommendations
* Chat analytics dashboard
* Auto-response bot for common questions
* Conversation summarization
* Multilingual AI support
