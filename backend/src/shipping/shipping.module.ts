import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { GHNModule } from '../ghn/ghn.module';
import { ShippingService } from './shipping.service';
import { ShippingController } from './shipping.controller';

@Module({
  imports: [PrismaModule, GHNModule],
  controllers: [ShippingController],
  providers: [ShippingService],
  exports: [ShippingService],
})
export class ShippingModule {}
