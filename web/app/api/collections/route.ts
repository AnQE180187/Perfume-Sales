import { NextResponse } from 'next/server';
import { ProductService } from '@/lib/services/product-service';

export async function GET() {
    try {
        const collections = await ProductService.getCollections();
        return NextResponse.json(collections);
    } catch (error: any) {
        return NextResponse.json({ error: error.message }, { status: 500 });
    }
}
