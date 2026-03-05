import {
  Body,
  Controller,
  Get,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { StaffInventoryService } from './staff-inventory.service';

@Controller('staff/inventory')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('STAFF', 'ADMIN')
export class StaffInventoryController {
  constructor(
    private readonly staffInventoryService: StaffInventoryService,
  ) {}

  @Get()
  listOverview() {
    return this.staffInventoryService.listOverview();
  }

  @Post('import')
  importStock(
    @Req() req: any,
    @Body()
    body: {
      variantId: string;
      quantity: number;
      reason?: string;
    },
  ) {
    const user = req.user as { userId: string };
    return this.staffInventoryService.importStock(
      user.userId,
      body.variantId,
      body.quantity,
      body.reason,
    );
  }

  @Post('adjust')
  adjustStock(
    @Req() req: any,
    @Body()
    body: {
      variantId: string;
      delta: number;
      reason: string;
    },
  ) {
    const user = req.user as { userId: string };
    return this.staffInventoryService.adjustStock(
      user.userId,
      body.variantId,
      body.delta,
      body.reason,
    );
  }

  @Get('logs')
  getLogs(
    @Query()
    query: {
      variantId?: string;
      from?: string;
      to?: string;
    },
  ) {
    return this.staffInventoryService.getLogs(query);
  }
}

