import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { StaffPosService } from './staff-pos.service';

@Controller('staff/pos')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('STAFF', 'ADMIN')
export class StaffPosController {
  constructor(private readonly staffPosService: StaffPosService) {}

  @Get('products')
  searchProducts(@Req() req: any) {
    const { q } = req.query as { q?: string };
    return this.staffPosService.searchProducts(q ?? '');
  }

  @Post('orders')
  createDraftOrder(@Req() req: any) {
    const user = req.user as { userId: string };
    return this.staffPosService.createDraftOrder(user.userId);
  }

  @Patch('orders/:id/items')
  upsertItem(
    @Req() req: any,
    @Param('id') orderId: string,
    @Body()
    body: {
      variantId: string;
      quantity: number;
    },
  ) {
    const user = req.user as { userId: string };
    return this.staffPosService.upsertItem(
      user.userId,
      orderId,
      body.variantId,
      body.quantity,
    );
  }

  @Post('orders/:id/pay/cash')
  payCash(@Req() req: any, @Param('id') orderId: string) {
    const user = req.user as { userId: string };
    return this.staffPosService.payCash(user.userId, orderId);
  }

  @Post('orders/:id/pay/qr')
  payQr(@Req() req: any, @Param('id') orderId: string) {
    const user = req.user as { userId: string };
    return this.staffPosService.createQrPayment(user.userId, orderId);
  }
}
