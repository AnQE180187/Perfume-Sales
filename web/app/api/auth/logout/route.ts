import { NextResponse } from 'next/server';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api/v1';

export async function POST(request: Request) {
    try {
        // Get token from Authorization header
        const authHeader = request.headers.get('Authorization');
        
        if (authHeader) {
            // Call backend logout API (optional, since JWT is stateless)
            await fetch(`${API_BASE_URL}/auth/logout`, {
                method: 'POST',
                headers: {
                    'Authorization': authHeader,
                    'Content-Type': 'application/json',
                },
            });
        }

        return NextResponse.json({ message: 'Signed out successfully' });
    } catch (err: any) {
        console.error('Logout API error:', err);
        return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
    }
}
