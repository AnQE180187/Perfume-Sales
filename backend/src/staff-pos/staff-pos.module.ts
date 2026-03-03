import { Module } from '@nestjs/common';
import { StaffPosController } from './staff-pos.controller';
import { StaffPosService } from './staff-pos.service';
import { PrismaModule } from '../prisma/prisma.module';
import { PaymentsModule } from '../payments/payments.module';

@Module({
  imports: [PrismaModule, PaymentsModule],
  controllers: [StaffPosController],
  providers: [StaffPosService],
})
export class StaffPosModule {}
