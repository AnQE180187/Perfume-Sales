import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { StoresService } from './stores.service';
import { CreateStoreDto } from './dto/create-store.dto';
import { UpdateStoreDto } from './dto/update-store.dto';

@Controller('stores')
export class StoresController {
  constructor(private readonly storesService: StoresService) {}

  /** Staff & Admin: list stores available to me (admin: all, staff: assigned) */
  @Get('my-stores')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('STAFF', 'ADMIN')
  getMyStores(@Req() req: any) {
    const user = req.user as { userId: string; role: string };
    return this.storesService.getStoresForUser(user.userId, user.role);
  }

  /** Admin: list all stores with staff and counts */
  @Get()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  list() {
    return this.storesService.list();
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  create(@Body() dto: CreateStoreDto) {
    return this.storesService.create(dto);
  }

  @Get('stock/overview')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  getStockOverview(@Query('storeId') storeId?: string) {
    return this.storesService.getStockOverview(storeId || undefined);
  }

  @Post('stock/import')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  adminImportStock(
    @Req() req: any,
    @Body()
    body: { storeId: string; variantId: string; quantity: number; reason?: string },
  ) {
    const user = req.user as { userId: string };
    return this.storesService.adminImportStock(
      body.storeId,
      body.variantId,
      body.quantity,
      user.userId,
      body.reason,
    );
  }

  @Post('stock/transfer')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  transferStock(
    @Req() req: any,
    @Body()
    body: {
      fromStoreId: string;
      toStoreId: string;
      variantId: string;
      quantity: number;
      reason?: string;
    },
  ) {
    const user = req.user as { userId: string };
    return this.storesService.transferStock(
      body.fromStoreId,
      body.toStoreId,
      body.variantId,
      body.quantity,
      user.userId,
      body.reason,
    );
  }

  @Get(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  getById(@Param('id') id: string) {
    return this.storesService.getById(id);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  update(@Param('id') id: string, @Body() dto: UpdateStoreDto) {
    return this.storesService.update(id, dto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  remove(@Param('id') id: string) {
    return this.storesService.remove(id);
  }

  @Post(':id/staff/:userId')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  assignStaff(@Param('id') id: string, @Param('userId') userId: string) {
    return this.storesService.assignStaff(id, userId);
  }

  @Delete(':id/staff/:userId')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  unassignStaff(@Param('id') id: string, @Param('userId') userId: string) {
    return this.storesService.unassignStaff(id, userId);
  }
}
