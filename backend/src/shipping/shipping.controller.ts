import { Body, Controller, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ShippingService } from './shipping.service';

@Controller('shipping')
export class ShippingController {
  constructor(private readonly shipping: ShippingService) {}

  @Post('orders/:orderId/create-ghn')
  @UseGuards(JwtAuthGuard)
  async createGhnShipment(@Param('orderId') orderId: string, @Req() req: any) {
    const userId = req.user?.userId ?? req.user?.sub;
    return this.shipping.createGhnShipmentForUser(userId, orderId);
  }

  @Post('ghn/webhook')
  async ghnWebhook(@Body() body: any) {
    await this.shipping.handleGhnWebhook(body);
    return { code: 200, message: 'Success' };
  }

  @Get('orders/:orderId')
  @UseGuards(JwtAuthGuard)
  async getByOrderId(@Param('orderId') orderId: string, @Req() req: any) {
    const userId = req.user?.userId ?? req.user?.sub;
    return this.shipping.getShipmentsForUserOrder(userId, orderId);
  }
}
