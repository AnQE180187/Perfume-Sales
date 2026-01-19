import { NextResponse } from 'next/server';
import { ProductService } from '@/lib/services/product-service';

export async function GET(req: Request) {
    const { searchParams } = new URL(req.url);
    const gender = searchParams.get('gender') || undefined;
    const brandId = searchParams.get('brand_id') || undefined;

    try {
        const products = await ProductService.getProducts({ gender, brand_id: brandId });
        return NextResponse.json(products);
    } catch (error: any) {
        return NextResponse.json({ error: error.message }, { status: 500 });
    }
}
