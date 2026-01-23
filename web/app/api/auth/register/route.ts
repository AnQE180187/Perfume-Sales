import { NextResponse } from 'next/server';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api/v1';

export async function POST(request: Request) {
    try {
        const { email, password, full_name, phone } = await request.json();

        if (!email || !password) {
            return NextResponse.json(
                { error: 'Email and password are required' },
                { status: 400 }
            );
        }

        // Call backend register API
        const response = await fetch(`${API_BASE_URL}/auth/register`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password, fullName: full_name, phone }),
        });

        const data = await response.json();

        if (!response.ok) {
            return NextResponse.json(
                { error: data.message || data.error || 'Registration failed' },
                { status: response.status }
            );
        }

        return NextResponse.json({
            message: 'Registration successful.',
            accessToken: data.accessToken,
            refreshToken: data.refreshToken,
            user: data,
        });
    } catch (err: any) {
        console.error('Register API error:', err);
        return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
    }
}
