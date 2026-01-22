import { Module } from '@nestjs/common';
import { ProductsService } from './products.service';
import { ProductsController } from './products.controller';
import { AdminProductsController } from './admin-products.controller';
import { RolesGuard } from '../auth/roles.guard';

@Module({
  controllers: [ProductsController, AdminProductsController],
  providers: [ProductsService, RolesGuard],
  exports: [ProductsService],
})
export class ProductsModule {}



