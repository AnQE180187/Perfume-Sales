# 2. Installation Guides

## 2.1 System Requirements

This section outlines the baseline minimum and recommended computational resources along with the core software dependencies required to successfully host, develop, and test the PerfumeGPT ecosystem.

### 2.1.1 Hardware Requirements
*   **Processor (CPU):** Minimum 2.0 GHz dual-core CPU (Intel Core i5, Apple M1, or equivalent).
*   **Memory (RAM):** Minimum 8 GB. However, 16 GB is highly recommended for concurrent full-stack development (running Database, NestJS, Next.js, and an Android Emulator simultaneously).
*   **Storage Space:** At least 20 GB of free space (Solid State Drive (SSD) is strongly recommended for faster build/compilation caching).
*   **Networking:** Required for accessing external webhook systems, LLM tools (xAI), and initial NPM dependency fetching.

### 2.1.2 Software Prerequisites
Ensure the local development machine or production VM contains the following pre-installed configurations:
*   **Developer OS:** Windows 10/11, macOS 12+ (Monterey+), or Ubuntu Linux (20.04 LTS+).
*   **Node.js:** Version 18.x or 20.x LTS (Long Term Support).
*   **Package Manager:** NPM (v9+) or Yarn.
*   **Database Engine:** PostgreSQL Version 14.x or higher with PgAdmin installed for local visual management.
*   **Mobile SDKs:** Flutter SDK Release (v3.22+), Dart SDK (v3.4+), bundled via Android Studio (for Android) or Xcode (for iOS).
*   **Code Manager:** Git (v2.30+).

---

## 2.2 Installation Instruction

Follow the chronological steps below to appropriately bootstrap the database architecture and instantiate all application client nodes.

### Step 1: Database Initialization
1. Ensure your PostgreSQL server is active on `localhost` (default port 5432).
2. Create an empty database globally named `perfume_sales` associated with your PostgreSQL user.
3. Keep the PostgreSQL connection string handy. It conventionally follows the format: 
   `postgresql://db_user:db_password@localhost:5432/perfume_sales?schema=public`

### Step 2: Core Backend Construction (NestJS API)
The backend acts as the gateway coordinating database calls and exposing REST endpoints.
1. Open a terminal instance and navigate into the `backend/` directory:
   ```bash
   cd backend
   ```
2. Clone the `.env.example` file to create a live `.env` file, placing your PostgreSQL string into `DATABASE_URL`. Provide a JWT secret standard string.
3. Install strict API dependencies:
   ```bash
   npm install
   ```
4. Propagate the Prisma Schema ORM into your physical database and generate the Prisma Client:
   ```bash
   npx prisma generate
   npx prisma db push
   ```
   *(During a production staging deployment, run `npx prisma migrate deploy` locally instead of `db push` to apply safe relational changes).*
5. Initiate the backend server loop:
   ```bash
   npm run start:dev
   ```
   *The Core API endpoints are now exposed natively over `http://localhost:3000`.*

### Step 3: Web App Construction (Next.js)
The SSR (Server Side Rendering) web node handles Admin configurations and Customer online shopping sessions.
1. Open a new terminal instance and enter the `frontend/` directory:
   ```bash
   cd frontend
   ```
2. Verify that the `.env` variable for backend targeting holds `NEXT_PUBLIC_API_URL="http://localhost:3000"`.
3. Fetch dynamic web dependencies:
   ```bash
   npm install
   ```
4. Boot the client-facing UI server:
   ```bash
   npm run dev
   ```
   *The responsive Web Portal becomes accessible immediately via arbitrary browsers at `http://localhost:3001` (or whichever port Next.js automatically assigns if 3000 is occupied).*

### Step 4: Mobile Ecosystem Setup (Flutter)
Provides offline POS configurations and native tracking environments for Customers.
1. Navigate into your dedicated `mobile/` or Flutter directory space.
2. Download dependent Dart libraries:
   ```bash
   flutter pub get
   ```
3. Provision your workspace target either by connecting a physical smartphone via USB debugging or running an Android/iOS emulator image.
4. Compile and launch the application natively:
   ```bash
   flutter run
   ```
