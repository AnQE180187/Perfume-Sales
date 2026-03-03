import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { StaffOrdersService } from './staff-orders.service';
import { StaffOrdersController } from './staff-orders.controller';

@Module({
  imports: [PrismaModule],
  providers: [StaffOrdersService],
  controllers: [StaffOrdersController],
})
export class StaffOrdersModule {}

