-- CreateTable
CREATE TABLE "DailyClosing" (
    "id" TEXT NOT NULL,
    "closingDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "systemTotal" DOUBLE PRECISION NOT NULL,
    "systemCash" DOUBLE PRECISION NOT NULL,
    "systemTransfer" DOUBLE PRECISION NOT NULL,
    "actualCash" DOUBLE PRECISION NOT NULL,
    "difference" DOUBLE PRECISION NOT NULL,
    "note" TEXT,
    "orderCount" INTEGER NOT NULL,
    "staffId" TEXT NOT NULL,
    "storeId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "DailyClosing_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "DailyClosing_storeId_closingDate_idx" ON "DailyClosing"("storeId", "closingDate");

-- AddForeignKey
ALTER TABLE "DailyClosing" ADD CONSTRAINT "DailyClosing_staffId_fkey" FOREIGN KEY ("staffId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DailyClosing" ADD CONSTRAINT "DailyClosing_storeId_fkey" FOREIGN KEY ("storeId") REFERENCES "Store"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
