# PerfumeGPT: AI-Powered Perfume Sales & Personalized Consultation System

![TypeScript](https://img.shields.io/badge/typescript-%23007ACC.svg?style=for-the-badge&logo=typescript&logoColor=white)
![NestJS](https://img.shields.io/badge/nestjs-%23E0234E.svg?style=for-the-badge&logo=nestjs&logoColor=white)
![Next JS](https://img.shields.io/badge/Next-black?style=for-the-badge&logo=next.js&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/postgresql-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white)
![Prisma](https://img.shields.io/badge/Prisma-3982CE?style=for-the-badge&logo=Prisma&logoColor=white)
![TailwindCSS](https://img.shields.io/badge/tailwindcss-%2338B2AC.svg?style=for-the-badge&logo=tailwind-css&logoColor=white)

**PerfumeGPT** (Capstone Project SP26SE04209) is a comprehensive, omnichannel e-commerce and retail management platform designed specifically for the fragrance industry. It leverages artificial intelligence to provide highly personalized perfume recommendations, bridging the gap between expert in-store consultation and digital retail convenience.

## 🌟 Key Features

### 🤖 AI-Powered Perfume Consultation
*   **Natural Language Chatbot**: Acts as a virtual fragrance expert, providing 3-5 matching products with detailed reasoning based on user input.
*   **Interactive Scent Quiz**: A guided 5-question quiz (analyzing gender, occasion, budget, preferred scent family, and longevity) to rank top recommendations.
*   **Review Summarization & Insights**: Automatically summarizes hundreds of customer reviews to extract pros, cons, and sentiment using Gemini AI.
*   **Semantic Search**: Allows users to search using natural language (e.g., "sweet women's perfume under 1.5 million VND").

### 🛍️ Omnichannel Sales & Management
*   **E-Commerce Web Portal**: A luxurious, responsive Next.js frontend for online shopping.
*   **In-Store POS (Point of Sale)**: Dedicated staff dashboard with barcode scanning, quick checkout, and receipt generation.
*   **Inventory Management**: Real-time stock tracking across multiple store locations, low-stock alerts, and import/adjustment workflows.
*   **Multi-Platform Ecosystem**: Includes a Flutter-based Mobile App for customers and a integrated Zalo Mini App.

### 💳 Payments & Shipping Integration
*   **Local Payment Gateways**: Integrated with PayOS, VNPay, Momo, and Cash-on-Delivery (COD).
*   **Logistics Partners**: Automated shipping requests and status synchronization with Giao Hàng Nhanh (GHN) and Giao Hàng Tiết Kiệm (GHTK).

### 📊 CRM & Advanced Analytics
*   **Loyalty Program**: Automated points accumulation and redemption system.
*   **Admin Dashboard**: Real-time visualization of revenue, inventory levels, top-selling products, and the "AI Conversion/Acceptance Rate".
*   **Promotions Engine**: Support for discount codes, combo deals, and targeted marketing campaigns.

---

## 🏗️ Architecture & Technology Stack

This repository is structured as a **Monorepo** containing multiple applications:

### 1. Backend (`/backend`)
A robust RESTful and WebSocket API serving all client applications.
*   **Framework**: NestJS 11
*   **Database**: PostgreSQL with Prisma ORM 6
*   **AI Integration**: Google Gemini API (`@google/genai`)
*   **Authentication**: JWT, Passport.js (Google/Facebook OAuth)
*   **Realtime**: Socket.io for chat and notifications

### 2. Frontend Web (`/frontend`)
The main e-commerce storefront and administrative/staff portals.
*   **Framework**: Next.js 15 (App Router)
*   **Language**: TypeScript, React 19
*   **Styling**: Tailwind CSS 4, Radix UI Primitives, Framer Motion
*   **State Management**: Zustand
*   **Internationalization**: `next-intl`
*   **Data Visualization**: Recharts

### 3. Mobile App (`/mobile`)
A cross-platform mobile application for customers on the go.
*   **Framework**: Flutter
*   **Language**: Dart
*   **State Management**: Riverpod
*   **Routing**: `go_router`

### 4. Zalo Mini App (`/ZaloApp`)
A lightweight, native-feeling application within the Zalo ecosystem for social commerce and seamless authentication.

---

## 🚀 Getting Started

### Prerequisites
*   Node.js (v20+ recommended)
*   PostgreSQL
*   Flutter SDK (for mobile development)

### Running the Backend
```bash
cd backend
npm install

# Set up your .env file with DATABASE_URL, JWT_SECRET, GEMINI_API_KEY, etc.
# Run Prisma migrations
npm run prisma:migrate

# Start the development server
npm run start:dev
```
*The API will be available at `http://localhost:3001` (or your configured port).*

### Running the Frontend
```bash
cd frontend
npm install

# Set up your .env.local file with NEXT_PUBLIC_API_URL, etc.
npm run dev
```
*The web app will be available at `http://localhost:3000`.*

### Running the Mobile App
```bash
cd mobile
flutter pub get

# Run on a connected device or emulator
flutter run
```

---

## 📁 Repository Structure

```text
.
├── backend/                # NestJS API Server & Prisma Database Schema
├── frontend/               # Next.js Web App (Customer, Admin, Staff Dashboards)
├── mobile/                 # Flutter Mobile Application
├── ZaloApp/                # Zalo Mini App Implementation
├── schema.dbml             # Database diagram definition
└── GEMINI.md               # AI Prompting guidelines & Project brief
```

---

## 🎓 About The Capstone Project
**Class:** SP26SE04209
**Duration:** 01/01/2026 - 30/04/2026
**Profession:** Software Engineer

This project is submitted in partial fulfillment of the requirements for the Software Engineering degree at FPT University. It demonstrates the practical application of modern full-stack development, cloud architecture, and artificial intelligence in solving real-world retail challenges.
