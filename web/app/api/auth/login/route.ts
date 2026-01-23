import { NextResponse } from 'next/server';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api/v1';

export async function POST(request: Request) {
    try {
        const { email, password } = await request.json();

        if (!email || !password) {
            return NextResponse.json(
                { error: 'Email and password are required' },
                { status: 400 }
            );
        }

        // Call backend login API
        const response = await fetch(`${API_BASE_URL}/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password }),
        });

        const data = await response.json();

        if (!response.ok) {
            return NextResponse.json(
                { error: data.message || data.error || 'Login failed' },
                { status: response.status }
            );
        }

        // Get user profile
        const profileResponse = await fetch(`${API_BASE_URL}/users/me`, {
            headers: {
                'Authorization': `Bearer ${data.accessToken}`,
            },
        });

        let user = null;
        if (profileResponse.ok) {
            const profileData = await profileResponse.json();
            user = profileData;
        }

        return NextResponse.json({
            message: 'Login successful',
            accessToken: data.accessToken,
            refreshToken: data.refreshToken,
            user: user || { email },
        });
    } catch (err: any) {
        console.error('Login API error:', err);
        return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
    }
}
