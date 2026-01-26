import { Module } from '@nestjs/common';
import { CatalogService } from './catalog.service';
import { AdminBrandsController } from './admin-brands.controller';
import { AdminCategoriesController } from './admin-categories.controller';
import { RolesGuard } from '../auth/roles.guard';
import { AdminScentFamiliesController } from './admin-scent-families.controller';
import { CatalogController } from './catalog.controller';

@Module({
  controllers: [
    CatalogController,
    AdminBrandsController,
    AdminCategoriesController,
    AdminScentFamiliesController,
  ],
  providers: [CatalogService, RolesGuard],
  exports: [CatalogService],
})
export class CatalogModule { }
