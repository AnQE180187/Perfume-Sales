import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { GHNService } from './ghn.service';
import { GHNController } from './ghn.controller';

@Module({
  imports: [ConfigModule],
  controllers: [GHNController],
  providers: [GHNService],
  exports: [GHNService],
})
export class GHNModule {}
