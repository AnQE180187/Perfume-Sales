import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { StaffInventoryService } from './staff-inventory.service';
import { StaffInventoryController } from './staff-inventory.controller';

@Module({
  imports: [PrismaModule],
  providers: [StaffInventoryService],
  controllers: [StaffInventoryController],
})
export class StaffInventoryModule {}

