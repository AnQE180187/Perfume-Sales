import { NextResponse } from 'next/server';
import { ProductService } from '@/lib/services/product-service';

export async function GET(
    req: Request,
    { params }: { params: { slug: string } }
) {
    const slug = params.slug;

    try {
        const collection = await ProductService.getCollectionDetail(slug);
        return NextResponse.json(collection);
    } catch (error: any) {
        return NextResponse.json({ error: error.message }, { status: 500 });
    }
}
