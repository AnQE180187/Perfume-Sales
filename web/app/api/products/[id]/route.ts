import { NextResponse } from 'next/server';
import { ProductService } from '@/lib/services/product-service';

export async function GET(
    req: Request,
    { params }: { params: { id: string } }
) {
    const id = params.id;

    try {
        const product = await ProductService.getProductDetail(id);
        return NextResponse.json(product);
    } catch (error: any) {
        return NextResponse.json({ error: error.message }, { status: 500 });
    }
}
