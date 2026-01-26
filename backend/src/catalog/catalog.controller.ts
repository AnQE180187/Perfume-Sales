import { Controller, Get, Param } from '@nestjs/common';
import { CatalogService } from './catalog.service';

@Controller('catalog')
export class CatalogController {
    constructor(private readonly catalogService: CatalogService) { }

    @Get('categories')
    listCategories() {
        return this.catalogService.listCategories();
    }

    @Get('categories/:id')
    getCategory(@Param('id') id: string) {
        return this.catalogService.getCategory(Number(id));
    }

    @Get('brands')
    listBrands() {
        return this.catalogService.listBrands();
    }

    @Get('brands/:id')
    getBrand(@Param('id') id: string) {
        return this.catalogService.getBrand(Number(id));
    }

    @Get('scent-families')
    listScentFamilies() {
        return this.catalogService.listScentFamilies();
    }
}
