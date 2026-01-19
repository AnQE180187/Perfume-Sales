import { NextResponse } from 'next/server';
import { OrderService } from '@/lib/services/order-service';

// Place Order
export async function POST(req: Request) {
    try {
        const body = await req.json();
        const order = await OrderService.createOrder(body);
        return NextResponse.json(order);
    } catch (error: any) {
        return NextResponse.json({ error: error.message }, { status: 400 });
    }
}

// Get user orders
export async function GET(req: Request) {
    const { searchParams } = new URL(req.url);
    const userId = searchParams.get('userId');

    if (!userId) {
        return NextResponse.json({ error: 'UserID required' }, { status: 400 });
    }

    try {
        const orders = await OrderService.getOrderHistory(userId);
        return NextResponse.json(orders);
    } catch (error: any) {
        return NextResponse.json({ error: error.message }, { status: 500 });
    }
}
