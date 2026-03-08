import { Module } from '@nestjs/common';
import { StaffPosController } from './staff-pos.controller';
import { StaffPosService } from './staff-pos.service';
import { PrismaModule } from '../prisma/prisma.module';
import { PaymentsModule } from '../payments/payments.module';
import { StoresModule } from '../stores/stores.module';

@Module({
  imports: [PrismaModule, PaymentsModule, StoresModule],
  controllers: [StaffPosController],
  providers: [StaffPosService],
})
export class StaffPosModule {}
